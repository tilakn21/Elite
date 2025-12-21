/**
 * Design Service
 * Handles operations for the Design Dashboard
 */

import { supabase } from './supabase';
import type { DesignJob, DesignStats, DesignJobStatus } from '@/types/design';

export const designService = {
    /**
     * Get jobs assigned to design department
     * In a real scenario, we might filter by specific designer ID if needed.
     */
    async getDesignJobs(designerId?: string): Promise<DesignJob[]> {
        try {
            // Fetch jobs where status implies it's in design phase
            // Or explicitly assigned to design
            let query = supabase
                .from('jobs')
                .select('*')
                // Filter for jobs that are ready for design (e.g. salesperson completed)
                // or are already in design phase
                .or('status.eq.assigned_to_design, status.eq.design_in_progress, status.eq.design_review');

            if (designerId) {
                // If we had a mechanism to assign specific designers
                // query = query.eq('design->>assignedTo', designerId);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                console.error('Error fetching design jobs:', error);
                return [];
            }

            if (!data) return [];

            return data.map((job: Record<string, any>) => mapToDesignJob(job));
        } catch (error) {
            console.error('Error in getDesignJobs:', error);
            return [];
        }
    },

    /**
     * Get dashboard statistics
     */
    async getStats(_designerId?: string): Promise<DesignStats> {
        // Mocking stats for now as it requires complex aggregation queries
        // or a dedicated stats table/view
        return {
            pendingJobs: 12,
            approvedToday: 4,
            correctionsHere: 2,
            totalCompleted: 145
        };
    },

    /**
     * Update job status in design workflow
     */
    async updateStatus(jobId: string, status: DesignJobStatus): Promise<boolean> {
        try {
            const { error } = await supabase
                .from('jobs')
                .update({
                    status: mapToGlobalStatus(status),
                    updated_at: new Date().toISOString()
                })
                .eq('id', jobId);

            if (error) throw error;
            return true;
        } catch (error) {
            console.error('Error updating status:', error);
            return false;
        }
    },

    /**
     * Upload a design draft
     * Note: This assumes storage bucket 'designs' exists.
     * If not, we'll need to create it or use a general one.
     */
    async uploadDraft(jobId: string, file: File): Promise<string | null> {
        try {
            const fileExt = file.name.split('.').pop();
            const fileName = `${jobId}_${Date.now()}.${fileExt}`;
            const filePath = `${jobId}/${fileName}`;

            const { error: uploadError } = await supabase.storage
                .from('designs')
                .upload(filePath, file);

            if (uploadError) throw uploadError;

            const { data } = supabase.storage
                .from('designs')
                .getPublicUrl(filePath);

            return data.publicUrl;
        } catch (error) {
            console.error('Error uploading draft:', error);
            return null;
        }
    }
};

// Helper: Map Supabase DB row to DesignJob type
function mapToDesignJob(row: Record<string, any>): DesignJob {
    const receptionist = row.receptionist || {};
    const salesperson = row.salesperson || {};
    const design = row.design || {};

    return {
        id: row.id,
        jobCode: row.job_code || row.id,
        customerName: receptionist.customerName || 'Unknown',
        priority: determinePriority(row), // Logic to estimate priority
        status: mapToDesignStatus(row.status),
        assignedDate: row.created_at, // Approximate
        shopName: receptionist.shopName,
        description: `Signage for ${receptionist.shopName || 'Client'}`,
        salespersonImages: salesperson.images || [],
        drafts: design.drafts || []
    };
}

// Helper: Map global status string to DesignJobStatus
function mapToDesignStatus(status: string): DesignJobStatus {
    switch (status) {
        case 'assigned_to_design': return 'pending';
        case 'design_in_progress': return 'in_progress';
        case 'design_review': return 'draft_uploaded';
        case 'design_changes_requested': return 'changes_requested';
        case 'design_approved': return 'approved';
        case 'sent_to_production': return 'completed';
        default: return 'pending';
    }
}

// Helper: Map DesignJobStatus to global DB status
function mapToGlobalStatus(status: DesignJobStatus): string {
    switch (status) {
        case 'pending': return 'assigned_to_design';
        case 'in_progress': return 'design_in_progress';
        case 'draft_uploaded': return 'design_review';
        case 'changes_requested': return 'design_changes_requested';
        case 'approved': return 'design_approved';
        case 'completed': return 'sent_to_production';
        default: return 'assigned_to_design';
    }
}

function determinePriority(_row: any): 'high' | 'medium' | 'low' {
    // Basic logic: if deadline is close, high. For now random or medium.
    return 'medium';
}
