/**
 * Production Service
 * Handles manufacturing workflow with Supabase integration
 */

import { supabase } from './supabase';
import type { ProductionJob, ProductionJobStatus, Worker, ProductionStats } from '@/types/production';

export const productionService = {
    /**
     * Get jobs in production phase
     * Shows jobs where design is approved or production is in progress
     */
    async getProductionJobs(): Promise<ProductionJob[]> {
        try {
            const { data, error } = await supabase
                .from('jobs')
                .select('*')
                .select('*')
                // Jobs in production cycle: approved -> production -> printing -> framing -> complete
                .or('status.eq.design_approved,status.eq.production_started,status.eq.printing_queued,status.eq.printing_started,status.eq.printing_completed,status.eq.framing_started,status.eq.production_completed')
                .order('created_at', { ascending: false });

            if (error) {
                console.error('[Production Service] Error fetching jobs:', error);
                return [];
            }

            if (!data) return [];

            return data.map((job: any) => mapToProductionJob(job));
        } catch (error) {
            console.error('[Production Service] Error in getProductionJobs:', error);
            return [];
        }
    },

    /**
     * Get workers (employees with production-related roles)
     */
    async getWorkers(): Promise<Worker[]> {
        try {
            const { data, error } = await supabase
                .from('employee')
                .select('*')
                .in('role', ['fabricator', 'assembler', 'installer', 'production']);

            if (error) throw error;
            if (!data) return [];

            return data.map((w: any) => ({
                id: w.id,
                name: w.full_name,
                role: w.role,
                status: w.is_available ? 'available' : 'busy',
                currentJob: w.assigned_job?.[0] || undefined
            }));
        } catch (error) {
            console.error('[Production Service] Error fetching workers:', error);
            return [];
        }
    },

    /**
     * Get Dashboard Stats from real data
     */
    async getStats(): Promise<ProductionStats> {
        try {
            // Count pending jobs (design_approved, waiting for production)
            const { count: pendingCount } = await supabase
                .from('jobs')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'design_approved');

            // Count active jobs (In Production / Printing / Framing)
            const { count: activeCount } = await supabase
                .from('jobs')
                .select('*', { count: 'exact', head: true })
                .or('status.eq.production_started,status.eq.printing_queued,status.eq.printing_started,status.eq.printing_completed,status.eq.framing_started');

            // Count completed today
            const today = new Date().toISOString().split('T')[0];
            const { data: completedData } = await supabase
                .from('jobs')
                .select('production, updated_at')
                .eq('status', 'production_completed');

            // Filter jobs completed today based on update time or timeline
            const completedToday = (completedData || []).filter((job: any) => {
                const updated = job.updated_at?.startsWith(today);
                const timeline = job.production?.timeline || [];
                const completedEntry = timeline.find((t: any) => t.status === 'completed' || t.status === 'production_completed');
                const timelineDate = completedEntry?.timestamp?.startsWith(today);
                return updated || timelineDate;
            }).length;

            // Count available workers
            const { count: availableWorkers } = await supabase
                .from('employee')
                .select('*', { count: 'exact', head: true })
                .in('role', ['fabricator', 'assembler', 'installer', 'production'])
                .eq('is_available', true);

            return {
                pendingJobs: pendingCount || 0,
                activeJobs: activeCount || 0,
                completedToday: completedToday,
                availableWorkers: availableWorkers || 0
            };
        } catch (error) {
            console.error('[Production Service] Error getting stats:', error);
            return { pendingJobs: 0, activeJobs: 0, completedToday: 0, availableWorkers: 0 };
        }
    },

    /**
     * Start production on a job
     */
    async startProduction(jobId: string): Promise<boolean> {
        try {
            console.log('[Production Service] startProduction called:', { jobId });

            // Fetch current production data
            const { data: currentJob, error: fetchError } = await supabase
                .from('jobs')
                .select('production, status')
                .eq('id', jobId)
                .single();

            if (fetchError) {
                console.error('[Production Service] Fetch error:', fetchError);
                return false;
            }

            const currentProduction = currentJob?.production || {};
            const existingTimeline = Array.isArray(currentProduction.timeline) ? currentProduction.timeline : [];

            // Create timeline entry
            const timelineEntry = {
                status: 'in_progress',
                timestamp: new Date().toISOString(),
            };

            // Build updated production JSONB
            const updatedProduction = {
                ...currentProduction,
                status: 'in_progress',
                progress: 0,
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            // Update job
            const { error } = await supabase
                .from('jobs')
                .update({
                    production: updatedProduction,
                    status: 'production_started', // Update main status
                })
                .eq('id', jobId);

            if (error) {
                console.error('[Production Service] Update error:', error);
                return false;
            }

            console.log('[Production Service] Production started successfully');
            return true;
        } catch (error) {
            console.error('[Production Service] Error starting production:', error);
            return false;
        }
    },

    /**
     * Assign worker to a job
     */
    async assignWorker(jobId: string, workerId: string): Promise<boolean> {
        try {
            // Fetch current production data
            const { data: job } = await supabase
                .from('jobs')
                .select('production')
                .eq('id', jobId)
                .single();

            const productionData = job?.production || {};
            const currentWorkers = productionData.assignedWorkers || [];

            if (!currentWorkers.includes(workerId)) {
                const newWorkers = [...currentWorkers, workerId];

                await supabase
                    .from('jobs')
                    .update({
                        production: { ...productionData, assignedWorkers: newWorkers }
                    })
                    .eq('id', jobId);

                // Update worker status
                await supabase
                    .from('employee')
                    .update({
                        is_available: false,
                        assigned_job: [jobId] // Store as array
                    })
                    .eq('id', workerId);
            }

            return true;
        } catch (error) {
            console.error('[Production Service] Error assigning worker:', error);
            return false;
        }
    },

    /**
     * Remove worker from a job
     */
    async removeWorker(jobId: string, workerId: string): Promise<boolean> {
        try {
            const { data: job } = await supabase
                .from('jobs')
                .select('production')
                .eq('id', jobId)
                .single();

            const productionData = job?.production || {};
            const currentWorkers = productionData.assignedWorkers || [];
            const newWorkers = currentWorkers.filter((id: string) => id !== workerId);

            await supabase
                .from('jobs')
                .update({
                    production: { ...productionData, assignedWorkers: newWorkers }
                })
                .eq('id', jobId);

            // Update worker status
            await supabase
                .from('employee')
                .update({
                    is_available: true,
                    assigned_job: []
                })
                .eq('id', workerId);

            return true;
        } catch (error) {
            console.error('[Production Service] Error removing worker:', error);
            return false;
        }
    },

    /**
     * Update job progress
     */
    async updateProgress(jobId: string, progress: number): Promise<boolean> {
        try {
            const { data: job } = await supabase
                .from('jobs')
                .select('production')
                .eq('id', jobId)
                .single();

            const productionData = job?.production || {};

            await supabase
                .from('jobs')
                .update({
                    production: {
                        ...productionData,
                        progress: Math.min(100, Math.max(0, progress)),
                        lastUpdated: new Date().toISOString(),
                    }
                })
                .eq('id', jobId);

            return true;
        } catch (error) {
            console.error('[Production Service] Error updating progress:', error);
            return false;
        }
    },

    /**
     * Send job to printing queue
     */
    async sendToPrinting(jobId: string): Promise<boolean> {
        try {
            const { data: currentJob } = await supabase
                .from('jobs')
                .select('production')
                .eq('id', jobId)
                .single();

            const currentProduction = currentJob?.production || {};
            const existingTimeline = Array.isArray(currentProduction.timeline) ? currentProduction.timeline : [];

            const timelineEntry = {
                status: 'printing_queued',
                timestamp: new Date().toISOString(),
            };

            const updatedProduction = {
                ...currentProduction,
                status: 'printing_queued',
                progress: 50, // Approx progress
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            await supabase
                .from('jobs')
                .update({
                    production: updatedProduction,
                    status: 'printing_queued',
                })
                .eq('id', jobId);

            return true;
        } catch (error) {
            console.error('[Production Service] Error sending to printing:', error);
            return false;
        }
    },

    /**
     * Start Framing (Post-Printing)
     */
    async startFraming(jobId: string): Promise<boolean> {
        try {
            const { data: currentJob } = await supabase
                .from('jobs')
                .select('production')
                .eq('id', jobId)
                .single();

            const currentProduction = currentJob?.production || {};
            const existingTimeline = Array.isArray(currentProduction.timeline) ? currentProduction.timeline : [];

            const timelineEntry = {
                status: 'framing_started',
                timestamp: new Date().toISOString(),
            };

            const updatedProduction = {
                ...currentProduction,
                status: 'framing_started',
                progress: 75,
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            await supabase
                .from('jobs')
                .update({
                    production: updatedProduction,
                    status: 'framing_started',
                })
                .eq('id', jobId);

            return true;
        } catch (error) {
            console.error('[Production Service] Error starting framing:', error);
            return false;
        }
    },

    /**
     * Complete Production (Final Step)
     */
    async completeProduction(jobId: string): Promise<boolean> {
        try {
            const { data: currentJob } = await supabase
                .from('jobs')
                .select('production')
                .eq('id', jobId)
                .single();

            const currentProduction = currentJob?.production || {};
            const existingTimeline = Array.isArray(currentProduction.timeline) ? currentProduction.timeline : [];

            const timelineEntry = {
                status: 'production_completed',
                timestamp: new Date().toISOString(),
            };

            const updatedProduction = {
                ...currentProduction,
                status: 'production_completed',
                progress: 100,
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            // Release workers
            const assignedWorkers = currentProduction.assignedWorkers || [];
            for (const workerId of assignedWorkers) {
                await supabase
                    .from('employee')
                    .update({ is_available: true, assigned_job: [] })
                    .eq('id', workerId);
            }

            await supabase
                .from('jobs')
                .update({
                    production: updatedProduction,
                    status: 'production_completed',
                })
                .eq('id', jobId);

            return true;
        } catch (error) {
            console.error('[Production Service] Error completing production:', error);
            return false;
        }
    },
};

// Helper: Map Supabase row to ProductionJob
function mapToProductionJob(row: any): ProductionJob {
    const receptionist = row.receptionist || {};
    const production = row.production || {};
    const design = row.design || {};
    const salesperson = row.salesperson || {};

    // Get timeline and find production start date
    const timeline = Array.isArray(production.timeline) ? production.timeline : [];
    const startedEntry = timeline.find((t: any) => t.status === 'in_progress');

    return {
        id: row.id,
        jobCode: row.job_code || row.id,
        customerName: receptionist.customerName || 'Unknown',
        shopName: receptionist.shopName,
        description: salesperson.extraDetails || `Production for ${receptionist.shopName || 'Client'}`,
        status: mapToProductionStatus(row.status, production.status),
        priority: determinePriority(row),
        assignedWorkers: production.assignedWorkers || [],
        progress: production.progress || 0,
        timeline: timeline,
        productionStartedAt: startedEntry?.timestamp || null,
        designProofUrl: design.drafts?.[0]?.url,
        salespersonNotes: salesperson.extraDetails,
    };
}

// Map main status to production status
function mapToProductionStatus(mainStatus: string, productionStatus?: string): ProductionJobStatus {
    // Priority: Main Status for inter-departmental transitions (Printing/Framing)
    // We check these first because production.status might be stale (e.g., 'printing_queued')
    if (['printing_queued', 'printing_started', 'printing_completed', 'framing_started', 'production_completed'].includes(mainStatus)) {
        switch (mainStatus) {
            case 'printing_queued':
            case 'printing_started': return 'at_printing';
            case 'printing_completed': return 'ready_for_framing';
            case 'framing_started': return 'framing_in_progress';
            case 'production_completed': return 'completed';
        }
    }

    // Fallback: Use internal production status if available (e.g., for sub-steps within production if any)
    if (productionStatus === 'in_progress') {
        return 'in_progress';
    }

    // Default mapping
    switch (mainStatus) {
        case 'design_approved': return 'pending';
        case 'production_started': return 'in_progress';
        default: return 'pending';
    }
}

// Determine priority based on job data
function determinePriority(job: any): 'high' | 'medium' | 'low' {
    const receptionist = job.receptionist || {};
    const daysUntilDeadline = receptionist.dateOfVisit
        ? Math.ceil((new Date(receptionist.dateOfVisit).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
        : 30;

    if (daysUntilDeadline <= 2) return 'high';
    if (daysUntilDeadline <= 5) return 'medium';
    return 'low';
}
