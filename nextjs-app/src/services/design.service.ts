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
                // Filter for jobs in design phase using unified statuses
                // Include design_approved so designers can see completed work
                .or('status.eq.site_visited, status.eq.design_started, status.eq.design_in_review, status.eq.design_approved');

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
     * Get dashboard statistics from real data
     */
    async getStats(_designerId?: string): Promise<DesignStats> {
        try {
            // Get today's date for "approved today" count
            const today = new Date().toISOString().split('T')[0];

            // Fetch all counts in parallel
            const [pendingResult, approvedTodayResult, correctionsResult, completedResult] = await Promise.all([
                // Pending: jobs waiting for design to start (site_visited)
                supabase
                    .from('jobs')
                    .select('id', { count: 'exact', head: true })
                    .eq('status', 'site_visited'),

                // Approved today: jobs approved on this date
                supabase
                    .from('jobs')
                    .select('id', { count: 'exact', head: true })
                    .eq('status', 'design_approved')
                    .gte('updated_at', `${today}T00:00:00`)
                    .lte('updated_at', `${today}T23:59:59`),

                // Corrections/In Review: jobs being reviewed
                supabase
                    .from('jobs')
                    .select('id', { count: 'exact', head: true })
                    .eq('status', 'design_in_review'),

                // Total completed: all approved designs
                supabase
                    .from('jobs')
                    .select('id', { count: 'exact', head: true })
                    .eq('status', 'design_approved'),
            ]);

            return {
                pendingJobs: pendingResult.count || 0,
                approvedToday: approvedTodayResult.count || 0,
                correctionsHere: correctionsResult.count || 0,
                totalCompleted: completedResult.count || 0,
            };
        } catch (error) {
            console.error('Error fetching stats:', error);
            return {
                pendingJobs: 0,
                approvedToday: 0,
                correctionsHere: 0,
                totalCompleted: 0,
            };
        }
    },

    /**
     * Update job status in design workflow
     * Updates the design JSONB column with workflow status
     * Only updates main status column on key milestones (started, approved)
     */
    async updateStatus(jobId: string, status: DesignJobStatus): Promise<boolean> {
        try {
            console.log('[Design Service] updateStatus called:', { jobId, status });

            // First, fetch current design data
            const { data: currentJob, error: fetchError } = await supabase
                .from('jobs')
                .select('design, status')
                .eq('id', jobId)
                .single();

            if (fetchError) {
                console.error('[Design Service] Fetch error:', fetchError);
                throw fetchError;
            }

            console.log('[Design Service] Current job:', currentJob);

            const currentDesign = currentJob?.design || {};
            const existingTimeline = Array.isArray(currentDesign.timeline) ? currentDesign.timeline : [];

            // Create timeline entry for this status change
            const timelineEntry = {
                status: status,
                timestamp: new Date().toISOString(),
                // Can be extended later with: updatedBy, notes, etc.
            };

            // Build updated design JSONB with timeline
            const updatedDesign = {
                ...currentDesign,
                status: status,
                lastUpdated: new Date().toISOString(),
                timeline: [...existingTimeline, timelineEntry],
            };

            // Prepare update object
            const updateData: Record<string, any> = {
                design: updatedDesign,
            };

            // Only update main status column on key milestones
            if (status === 'in_progress') {
                updateData.status = 'design_started';
            } else if (status === 'approved' || status === 'completed') {
                updateData.status = 'design_approved';
            }

            console.log('[Design Service] Updating with:', updateData);

            const { error, data } = await supabase
                .from('jobs')
                .update(updateData)
                .eq('id', jobId)
                .select();

            if (error) {
                console.error('[Design Service] Update error:', error);
                throw error;
            }

            console.log('[Design Service] Update successful:', data);
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

    // Priority: design.status (JSONB) > main status column
    const designStatus = design.status || mapToDesignStatus(row.status);

    // Get timeline and find when design was started
    const timeline = Array.isArray(design.timeline) ? design.timeline : [];
    const startedEntry = timeline.find((t: any) => t.status === 'in_progress');
    const designStartedAt = startedEntry?.timestamp || null;

    return {
        id: row.id,
        jobCode: row.job_code || row.id,
        customerName: receptionist.customerName || 'Unknown',
        priority: determinePriority(row),
        status: designStatus,
        assignedDate: row.created_at,
        shopName: receptionist.shopName,
        description: `Signage for ${receptionist.shopName || 'Client'}`,
        salespersonImages: salesperson.images || [],
        drafts: design.drafts || [],
        timeline: timeline,
        designStartedAt: designStartedAt,
    };
}

// Helper: Map global status string to DesignJobStatus
function mapToDesignStatus(status: string): DesignJobStatus {
    switch (status) {
        case 'site_visited': return 'pending';       // Ready for design
        case 'design_started': return 'in_progress';
        case 'design_in_review': return 'draft_uploaded';
        case 'design_approved': return 'approved';
        case 'production_started': return 'completed';
        default: return 'pending';
    }
}

function determinePriority(_row: any): 'high' | 'medium' | 'low' {
    // Basic logic: if deadline is close, high. For now random or medium.
    return 'medium';
}
