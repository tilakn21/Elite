/**
 * Salesperson Service
 * Handles salesperson-specific operations with Supabase
 */

import { supabase } from './supabase';
import { SiteVisitItem, SalespersonProfile, SalespersonData } from '@/types/salesperson';

export const salespersonService = {
    /**
     * Fetch assigned jobs for a salesperson
     */
    async getAssignedJobs(salespersonId: string): Promise<SiteVisitItem[]> {
        try {
            const { data, error } = await supabase
                .from('jobs')
                .select('id, job_code, receptionist, salesperson, created_at, status')
                .contains('receptionist', { assignedSalesperson: salespersonId });

            if (error) {
                console.error('Error fetching assigned jobs:', error);
                return [];
            }

            if (!data) return [];

            return data.map((job: Record<string, unknown>) => {
                const receptionist = job.receptionist as Record<string, unknown> | null;
                const salesperson = job.salesperson as Record<string, unknown> | null;
                const jobCode = (job.job_code as string) || (job.id as string) || '';

                const status = salesperson?.status?.toString().toLowerCase() === 'completed'
                    ? 'completed'
                    : salesperson
                        ? 'submitted'
                        : 'pending';

                return {
                    jobCode,
                    customerName: (receptionist?.customerName as string) || '',
                    dateOfVisit: (receptionist?.dateOfVisit as string) || '',
                    status,
                    shopName: (receptionist?.shopName as string) || '',
                    jobData: {
                        id: job.id as string,
                        job_code: jobCode,
                        created_at: job.created_at as string,
                        status: job.status as string,
                    },
                    receptionistData: receptionist ? {
                        customerName: (receptionist.customerName as string) || '',
                        shopName: (receptionist.shopName as string) || '',
                        dateOfVisit: (receptionist.dateOfVisit as string) || '',
                        dateOfAppointment: (receptionist.dateOfAppointment as string) || '',
                        phone: (receptionist.phone as string) || '',
                        email: (receptionist.email as string) || '',
                        city: (receptionist.city as string) || '',
                        area: (receptionist.area as string) || '',
                        landMark: (receptionist.landMark as string) || '',
                        assignedSalesperson: (receptionist.assignedSalesperson as string) || '',
                    } : undefined,
                    salespersonData: salesperson ? {
                        status: (salesperson.status as string) || '',
                        material: salesperson.material as string,
                        tools: salesperson.tools as string,
                        productionTime: salesperson.productionTime as string,
                        fittingTime: salesperson.fittingTime as string,
                        measurements: salesperson.measurements as string,
                        images: salesperson.images as string[],
                    } : undefined,
                } as SiteVisitItem;
            });
        } catch (error) {
            console.error('Error in getAssignedJobs:', error);
            return [];
        }
    },

    /**
     * Fetch salesperson profile by ID
     */
    async getProfile(salespersonId: string): Promise<SalespersonProfile | null> {
        try {
            const { data, error } = await supabase
                .from('employee')
                .select('*')
                .eq('id', salespersonId)
                .single();

            if (error || !data) {
                console.error('Error fetching profile:', error);
                return null;
            }

            return {
                id: data.id,
                full_name: data.full_name,
                phone: data.phone,
                email: data.email,
                role: data.role,
                branch_id: data.branch_id,
                created_at: data.created_at,
                is_available: data.is_available ?? true,
                number_of_jobs: data.number_of_jobs ?? 0,
            };
        } catch (error) {
            console.error('Error in getProfile:', error);
            return null;
        }
    },

    /**
     * Update salesperson availability and decrement job count
     */
    async setSalespersonAvailable(salespersonId: string): Promise<boolean> {
        try {
            // Get current job count
            const { data: employee, error: fetchError } = await supabase
                .from('employee')
                .select('number_of_jobs')
                .eq('id', salespersonId)
                .single();

            if (fetchError) {
                console.error('Error fetching employee:', fetchError);
                return false;
            }

            let numberOfJobs = (employee?.number_of_jobs || 0) as number;
            if (numberOfJobs > 0) {
                numberOfJobs -= 1;
            }

            // Update availability and job count
            const { error: updateError } = await supabase
                .from('employee')
                .update({ is_available: true, number_of_jobs: numberOfJobs })
                .eq('id', salespersonId);

            if (updateError) {
                console.error('Error updating employee:', updateError);
                return false;
            }

            return true;
        } catch (error) {
            console.error('Error in setSalespersonAvailable:', error);
            return false;
        }
    },

    /**
     * Submit job details from salesperson
     */
    async submitJobDetails(jobCode: string, salespersonData: SalespersonData): Promise<boolean> {
        try {
            const { error } = await supabase
                .from('jobs')
                .update({
                    salesperson: {
                        ...salespersonData,
                        status: 'completed',
                        submittedAt: new Date().toISOString(),
                    }
                })
                .eq('job_code', jobCode);

            if (error) {
                console.error('Error submitting job details:', error);
                return false;
            }

            return true;
        } catch (error) {
            console.error('Error in submitJobDetails:', error);
            return false;
        }
    },

    /**
     * Change password for salesperson
     */
    async changePassword(
        salespersonId: string,
        currentPassword: string,
        newPassword: string
    ): Promise<{ success: boolean; error?: string }> {
        try {
            // Verify current password
            const { data, error: fetchError } = await supabase
                .from('employee')
                .select('password')
                .eq('id', salespersonId)
                .eq('password', currentPassword)
                .single();

            if (fetchError || !data) {
                return { success: false, error: 'Current password is incorrect.' };
            }

            // Update password
            const { error: updateError } = await supabase
                .from('employee')
                .update({ password: newPassword })
                .eq('id', salespersonId);

            if (updateError) {
                return { success: false, error: 'Failed to update password.' };
            }

            return { success: true };
        } catch (error) {
            console.error('Error in changePassword:', error);
            return { success: false, error: 'An error occurred.' };
        }
    },

    /**
     * Get job details by job code
     */
    async getJobDetails(jobCode: string): Promise<Record<string, unknown> | null> {
        try {
            const { data, error } = await supabase
                .from('jobs')
                .select('*')
                .eq('job_code', jobCode)
                .single();

            if (error || !data) {
                console.error('Error fetching job details:', error);
                return null;
            }

            return data;
        } catch (error) {
            console.error('Error in getJobDetails:', error);
            return null;
        }
    },
};

export default salespersonService;
