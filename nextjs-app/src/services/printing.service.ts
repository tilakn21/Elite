/**
 * Printing Service
 * Handles interactions for the Printing Dashboard with Supabase
 */

import { supabase } from './supabase';
import type { PrintingJob, PrintingJobStatus, PrintingStats } from '@/types/printing';

export const printingService = {
    /**
     * Get printing jobs in queue and active
     */
    async getPrintingJobs(): Promise<PrintingJob[]> {
        try {
            const { data, error } = await supabase
                .from('jobs')
                .select('*')
                // Jobs ready for printing or currently printing or completed
                .or('status.eq.production_completed, status.eq.printing_started, status.eq.printing_completed')
                .order('created_at', { ascending: true }); // Oldest first for queue

            if (error) {
                console.error('[Printing Service] Error fetching jobs:', error);
                return [];
            }

            if (!data) return [];

            // Add queue numbers based on arrival order
            let queueNum = 1;
            return data.map((job: any) => {
                const mapped = mapToPrintingJob(job, queueNum);
                if (job.status === 'production_completed') queueNum++;
                return mapped;
            });
        } catch (error) {
            console.error('[Printing Service] Error in getPrintingJobs:', error);
            return [];
        }
    },

    /**
     * Get dashboard stats from real data
     */
    async getStats(): Promise<PrintingStats> {
        try {
            // Pending (production_completed, waiting for print)
            const { count: pendingCount } = await supabase
                .from('jobs')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'production_completed');

            // Active (printing_started)
            const { count: activeCount } = await supabase
                .from('jobs')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'printing_started');

            // Completed today
            const today = new Date().toISOString().split('T')[0];
            const { data: completedData } = await supabase
                .from('jobs')
                .select('printing')
                .eq('status', 'printing_completed');

            const completedToday = (completedData || []).filter((job: any) => {
                const timeline = job.printing?.timeline || [];
                const completedEntry = timeline.find((t: any) => t.status === 'print_completed');
                return completedEntry?.timestamp?.startsWith(today);
            }).length;

            return {
                pendingJobs: pendingCount || 0,
                activeJobs: activeCount || 0,
                completedToday: completedToday,
            };
        } catch (error) {
            console.error('[Printing Service] Error getting stats:', error);
            return { pendingJobs: 0, activeJobs: 0, completedToday: 0 };
        }
    },

    /**
     * Start printing a job
     */
    async startPrinting(jobId: string): Promise<boolean> {
        try {
            console.log('[Printing Service] startPrinting called:', { jobId });

            // Fetch current printing data
            const { data: currentJob, error: fetchError } = await supabase
                .from('jobs')
                .select('printing, status')
                .eq('id', jobId)
                .single();

            if (fetchError) {
                console.error('[Printing Service] Fetch error:', fetchError);
                return false;
            }

            const currentPrinting = currentJob?.printing || {};
            const existingTimeline = Array.isArray(currentPrinting.timeline) ? currentPrinting.timeline : [];

            // Create timeline entry
            const timelineEntry = {
                status: 'print_started',
                timestamp: new Date().toISOString(),
            };

            // Build updated printing JSONB
            const updatedPrinting = {
                ...currentPrinting,
                status: 'print_started',
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            // Update job
            const { error } = await supabase
                .from('jobs')
                .update({
                    printing: updatedPrinting,
                    status: 'printing_started', // Update main status
                })
                .eq('id', jobId);

            if (error) {
                console.error('[Printing Service] Update error:', error);
                return false;
            }

            console.log('[Printing Service] Printing started successfully');
            return true;
        } catch (error) {
            console.error('[Printing Service] Error starting printing:', error);
            return false;
        }
    },

    /**
     * Mark job as print completed
     */
    async markPrintCompleted(jobId: string): Promise<boolean> {
        try {
            const { data: currentJob } = await supabase
                .from('jobs')
                .select('printing')
                .eq('id', jobId)
                .single();

            const currentPrinting = currentJob?.printing || {};
            const existingTimeline = Array.isArray(currentPrinting.timeline) ? currentPrinting.timeline : [];

            // Add timeline entry
            const timelineEntry = {
                status: 'print_completed',
                timestamp: new Date().toISOString(),
            };

            const updatedPrinting = {
                ...currentPrinting,
                status: 'print_completed',
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            // Update job
            await supabase
                .from('jobs')
                .update({
                    printing: updatedPrinting,
                    status: 'printing_completed',
                })
                .eq('id', jobId);

            return true;
        } catch (error) {
            console.error('[Printing Service] Error marking print completed:', error);
            return false;
        }
    },
};

// Helper: Map Supabase row to PrintingJob
function mapToPrintingJob(row: any, queueNumber: number): PrintingJob {
    const receptionist = row.receptionist || {};
    const printing = row.printing || {};
    const design = row.design || {};
    const salesperson = row.salesperson || {};

    // Get timeline and find print start date
    const timeline = Array.isArray(printing.timeline) ? printing.timeline : [];
    const startedEntry = timeline.find((t: any) => t.status === 'print_started');

    // Get design image (first draft URL)
    const designImageUrl = design.drafts?.[0]?.url || null;

    return {
        id: row.id,
        jobCode: row.job_code || row.id,
        customerName: receptionist.customerName || 'Unknown',
        shopName: receptionist.shopName,
        description: salesperson.extraDetails,
        status: mapToPrintingStatus(row.status, printing.status),
        priority: determinePriority(row),
        queueNumber: queueNumber,
        designImageUrl: designImageUrl,
        timeline: timeline,
        printStartedAt: startedEntry?.timestamp || null,
        material: salesperson.material,
        dimensions: salesperson.measurements,
        createdAt: row.created_at,
    };
}

// Map main status to printing status
function mapToPrintingStatus(mainStatus: string, printingStatus?: string): PrintingJobStatus {
    // Priority: printing.status (JSONB) > main status
    if (printingStatus) {
        return printingStatus as PrintingJobStatus;
    }

    switch (mainStatus) {
        case 'production_completed': return 'pending';
        case 'printing_started': return 'print_started';
        case 'printing_completed': return 'print_completed';
        default: return 'pending';
    }
}

// Determine priority
function determinePriority(job: any): 'high' | 'medium' | 'low' {
    const receptionist = job.receptionist || {};
    const daysOld = receptionist.dateOfVisit
        ? Math.ceil((Date.now() - new Date(receptionist.dateOfVisit).getTime()) / (1000 * 60 * 60 * 24))
        : 0;

    if (daysOld >= 5) return 'high';
    if (daysOld >= 3) return 'medium';
    return 'low';
}
