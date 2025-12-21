/**
 * Production Service
 * Handles manufacturing workflow and worker assignment
 */

import { supabase } from './supabase';
import type { ProductionJob, ProductionJobStatus, Worker, ProductionStats } from '@/types/production';

export const productionService = {
    /**
     * Get jobs active in production
     */
    async getProductionJobs(): Promise<ProductionJob[]> {
        try {
            // Fetch jobs with status related to production
            const { data, error } = await supabase
                .from('jobs')
                .select('*')
                .or('status.eq.sent_to_production, status.eq.fabrication, status.eq.assembly, status.eq.ready_for_install')
                .order('created_at', { ascending: false });

            if (error) {
                console.error('Error fetching production jobs:', error);
                return [];
            }

            if (!data) return [];

            return data.map((job: any) => mapToProductionJob(job));
        } catch (error) {
            console.error('Error in getProductionJobs:', error);
            return [];
        }
    },

    /**
     * Get list of workers
     */
    async getWorkers(): Promise<Worker[]> {
        try {
            const { data, error } = await supabase
                .from('employee')
                .select('*')
                .in('role', ['fabricator', 'assembler', 'installer']);

            if (error) throw error;
            if (!data) return [];

            return data.map((w: any) => ({
                id: w.id,
                name: w.full_name,
                role: w.role, // Assuming simplified role mapping
                status: w.is_available ? 'available' : 'busy',
                skills: w.skills || [],
                currentJob: w.assigned_job // Assuming this field exists
            }));
        } catch (error) {
            console.error('Error fetching workers:', error);
            return [];
        }
    },

    /**
     * Get Dashboard Stats
     */
    async getStats(): Promise<ProductionStats> {
        // Mock implementation
        return {
            activeJobs: 8,
            availableWorkers: 3,
            completedToday: 2,
            delayedJobs: 1
        };
    },

    /**
     * Assign worker to a job
     */
    async assignWorker(jobId: string, workerId: string): Promise<boolean> {
        try {
            // Update job's assigned workers list (implementation depends on DB schema, assuming array or relation table)
            // For now, we'll assume a simplified update to a 'production' jsonb column

            // First fetch current assignments
            const { data: job } = await supabase.from('jobs').select('production').eq('id', jobId).single();
            const productionData = job?.production || {};
            const currentWorkers = productionData.assignedWorkers || [];

            if (!currentWorkers.includes(workerId)) {
                const newWorkers = [...currentWorkers, workerId];

                await supabase.from('jobs').update({
                    production: { ...productionData, assignedWorkers: newWorkers }
                }).eq('id', jobId);

                // Also update worker status
                await supabase.from('employee').update({
                    is_available: false,
                    assigned_job: jobId
                }).eq('id', workerId);
            }

            return true;
        } catch (error) {
            console.error('Error assigning worker:', error);
            return false;
        }
    },

    /**
     * Update Job Status
     */
    async updateStatus(jobId: string, status: ProductionJobStatus): Promise<boolean> {
        try {
            await supabase
                .from('jobs')
                .update({
                    status: mapToGlobalStatus(status),
                    updated_at: new Date().toISOString()
                })
                .eq('id', jobId);

            return true;
        } catch (error) {
            console.error('Error updating status:', error);
            return false;
        }
    }
};

// Mappers
function mapToProductionJob(row: any): ProductionJob {
    const receptionist = row.receptionist || {};
    const design = row.design || {};
    const production = row.production || {};

    return {
        id: row.id,
        jobCode: row.job_code || row.id,
        customerName: receptionist.customerName || 'Unknown',
        description: `Production for ${receptionist.shopName}`,
        status: mapToProductionStatus(row.status),
        deadline: receptionist.dateOfVisit, // Using visit date as strict deadline for now
        priority: 'medium',
        assignedWorkers: production.assignedWorkers || [],
        designProofUrl: design.drafts?.[0]?.url, // Use latest draft
        fabricationProgress: production.progress || 0,
        assemblyProgress: 0
    };
}

function mapToProductionStatus(status: string): ProductionJobStatus {
    switch (status) {
        case 'sent_to_production': return 'pending_production';
        case 'fabrication': return 'fabrication';
        case 'assembly': return 'assembly';
        case 'ready_for_install': return 'ready_for_install';
        case 'installed': return 'completed';
        default: return 'pending_production';
    }
}

function mapToGlobalStatus(status: ProductionJobStatus): string {
    switch (status) {
        case 'pending_production': return 'sent_to_production';
        case 'fabrication': return 'fabrication';
        case 'assembly': return 'assembly';
        case 'ready_for_install': return 'ready_for_install';
        case 'completed': return 'installed';
        default: return 'sent_to_production';
    }
}
