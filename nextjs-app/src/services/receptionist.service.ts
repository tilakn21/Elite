/**
 * Receptionist Service
 * Handles job requests, salesperson assignment, and receptionist data
 */

import supabase from './supabase';
import type {
    JobRequest,
    Salesperson,
    NewJobRequestData,
    ReceptionistStats,
    ReceptionistProfile,
    JobRequestStatus,
    SalespersonStatus,
} from '@/types/receptionist';

/**
 * Parse job request status from string
 * Maps unified JobStatus to legacy JobRequestStatus for UI
 */
function parseJobStatus(status: string | null | undefined): JobRequestStatus {
    switch (status?.toLowerCase()) {
        // Unified statuses
        case 'salesperson_assigned':
        case 'site_visited':
        case 'design_started':
        case 'design_in_review':
        case 'design_approved':
        case 'production_started':
        case 'production_completed':
        case 'printing_started':
        case 'printing_completed':
        case 'out_for_delivery':
        // Legacy
        case 'approved':
        case 'salesperson assigned':
            return 'approved'; // "Assigned" in UI
        case 'declined':
            return 'declined';
        case 'completed':
            return 'completed';
        case 'received':
        case 'pending':
        default:
            return 'pending'; // "Pending" in UI - no salesperson yet
    }
}

/**
 * Parse salesperson status
 */
function parseSalespersonStatus(isAvailable: boolean): SalespersonStatus {
    return isAvailable ? 'available' : 'busy';
}

/**
 * Fetch all job requests from Supabase
 */
export async function getJobRequests(): Promise<JobRequest[]> {
    const { data, error } = await supabase
        .from('jobs')
        .select('id, job_code, status, created_at, receptionist')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Error fetching job requests:', error);
        return [];
    }

    return (data ?? []).map((job) => {
        const receptionist = job.receptionist as Record<string, unknown> | null;
        return {
            id: String(job.id ?? ''),
            jobCode: String(job.job_code ?? job.id ?? ''),
            customerName: String(receptionist?.customerName ?? 'Unknown'),
            phone: String(receptionist?.phone ?? ''),
            email: String(receptionist?.createdBy ?? ''),
            status: parseJobStatus(job.status),
            dateAdded: job.created_at ?? '',
            shopName: receptionist?.shopName as string | undefined,
            streetAddress: receptionist?.streetAddress as string | undefined,
            streetNumber: receptionist?.streetNumber as string | undefined,
            town: receptionist?.town as string | undefined,
            postcode: receptionist?.postcode as string | undefined,
            assignedSalesperson: receptionist?.assignedSalesperson as string | undefined,
            timeOfVisit: receptionist?.timeOfVisit as string | undefined,
            dateOfVisit: receptionist?.dateOfVisit as string | undefined,
            dateOfAppointment: receptionist?.dateOfAppointment as string | undefined,
            createdBy: receptionist?.createdBy as string | undefined,
            receptionistJson: receptionist ?? undefined,
        };
    });
}

/**
 * Fetch all salespersons (employees with ID starting with 'sal')
 */
export async function getSalespersons(): Promise<Salesperson[]> {
    const { data, error } = await supabase
        .from('employee')
        .select('id, full_name, is_available, number_of_jobs')
        .ilike('id', 'sal%');

    if (error) {
        console.error('Error fetching salespersons:', error);
        return [];
    }

    // Sort: available first (with fewer jobs), then unavailable
    const sorted = (data ?? []).sort((a, b) => {
        const aAvailable = a.is_available ? 0 : 1;
        const bAvailable = b.is_available ? 0 : 1;
        if (aAvailable !== bAvailable) return aAvailable - bAvailable;
        return (a.number_of_jobs ?? 0) - (b.number_of_jobs ?? 0);
    });

    return sorted.map((e) => ({
        id: String(e.id ?? ''),
        name: String(e.full_name ?? ''),
        status: parseSalespersonStatus(e.is_available === true),
        isAvailable: e.is_available === true,
        numberOfJobs: Number(e.number_of_jobs ?? 0),
    }));
}

/**
 * Create a new job request
 */
export async function createJobRequest(
    data: NewJobRequestData,
    receptionistId: string
): Promise<{ success: boolean; jobId?: string; error?: string }> {
    const now = new Date().toISOString();

    // Fetch receptionist's branch_id
    const { data: empData } = await supabase
        .from('employee')
        .select('branch_id')
        .eq('id', receptionistId)
        .maybeSingle();

    const branchId = empData?.branch_id ? Number(empData.branch_id) : null;

    const receptionistJson = {
        customerName: data.customerName,
        phone: data.phone,
        shopName: data.shopName,
        streetAddress: data.streetAddress,
        streetNumber: data.streetNumber,
        town: data.town,
        postcode: data.postcode,
        dateOfAppointment: data.dateOfAppointment,
        dateOfVisit: data.dateOfVisit,
        timeOfVisit: data.timeOfVisit,
        assignedSalesperson: data.assignedSalesperson,
        createdBy: receptionistId,
        createdAt: now,
    };

    const insertData: Record<string, unknown> = {
        status: data.assignedSalesperson ? 'salesperson_assigned' : 'received',
        created_at: now,
        receptionist: receptionistJson,
        accountant: {
            payment_status: 'payment_pending',
            amount_paid: 0,
            total_amount: 0,
            payments: []
        }
    };

    if (branchId !== null) {
        insertData.branch_id = branchId;
    }

    const { data: insertedJob, error } = await supabase
        .from('jobs')
        .insert(insertData)
        .select()
        .single();

    if (error) {
        console.error('Error creating job:', error);
        return { success: false, error: error.message };
    }

    const jobId = String(insertedJob?.id ?? '');

    // Update salesperson's assigned_job array and number_of_jobs
    if (data.assignedSalesperson && jobId) {
        const { data: empData } = await supabase
            .from('employee')
            .select('assigned_job, number_of_jobs')
            .eq('id', data.assignedSalesperson)
            .single();

        if (empData) {
            const currentJobs = Array.isArray(empData.assigned_job)
                ? empData.assigned_job
                : [];
            const numberOfJobs = Number(empData.number_of_jobs ?? 0);

            if (!currentJobs.includes(jobId)) {
                currentJobs.push(jobId);
                const newJobCount = numberOfJobs + 1;
                const isAvailable = newJobCount < 4;

                await supabase
                    .from('employee')
                    .update({
                        assigned_job: currentJobs,
                        number_of_jobs: newJobCount,
                        is_available: isAvailable,
                    })
                    .eq('id', data.assignedSalesperson);
            }
        }
    }

    return { success: true, jobId };
}

/**
 * Get receptionist profile
 */
export async function getReceptionistProfile(
    receptionistId: string
): Promise<ReceptionistProfile | null> {
    const { data, error } = await supabase
        .from('employee')
        .select('id, full_name, role, branch_id')
        .eq('id', receptionistId)
        .maybeSingle();

    if (error || !data) {
        console.error('Error fetching receptionist:', error);
        return null;
    }

    let branchName: string | undefined;
    if (data.branch_id) {
        const { data: branchData } = await supabase
            .from('branches')
            .select('name')
            .eq('id', data.branch_id)
            .maybeSingle();
        branchName = branchData?.name;
    }

    return {
        id: String(data.id ?? ''),
        fullName: String(data.full_name ?? ''),
        role: String(data.role ?? ''),
        branchId: data.branch_id ? Number(data.branch_id) : undefined,
        branchName,
    };
}

/**
 * Get dashboard stats
 */
export async function getDashboardStats(): Promise<ReceptionistStats> {
    const jobs = await getJobRequests();
    const today = new Date().toISOString().split('T')[0];

    return {
        totalJobs: jobs.length,
        pendingJobs: jobs.filter((j) => j.status === 'pending').length,
        completedJobs: jobs.filter((j) => j.status === 'completed').length,
        assignedToday: jobs.filter((j) => j.dateAdded.startsWith(today ?? '')).length,
    };
}

/**
 * Update salesperson availability
 */
export async function setSalespersonAvailable(
    salespersonId: string,
    available: boolean
): Promise<void> {
    await supabase
        .from('employee')
        .update({ is_available: available })
        .eq('id', salespersonId);
}

/**
 * Get job count for a salesperson on a specific date
 * Used to determine date-based availability
 */
export async function getJobCountForSalespersonOnDate(
    salespersonId: string,
    date: string // YYYY-MM-DD format
): Promise<number> {
    const { data, error } = await supabase
        .from('jobs')
        .select('id, receptionist')
        .contains('receptionist', { assignedSalesperson: salespersonId });

    if (error) {
        console.error('Error counting jobs for salesperson:', error);
        return 0;
    }

    // Filter jobs by appointment date
    const jobsOnDate = (data ?? []).filter((job) => {
        const receptionist = job.receptionist as Record<string, unknown> | null;
        const appointmentDate = receptionist?.dateOfAppointment as string;
        const visitDate = receptionist?.dateOfVisit as string;

        // Check both dateOfAppointment and dateOfVisit
        return appointmentDate?.startsWith(date) || visitDate?.startsWith(date);
    });

    return jobsOnDate.length;
}

/**
 * Fetch salespersons with availability based on a specific date
 * A salesperson is unavailable for a date if they already have 3+ jobs on that date
 */
export async function getSalespersonsForDate(date: string): Promise<Salesperson[]> {
    const { data, error } = await supabase
        .from('employee')
        .select('id, full_name, is_available, number_of_jobs')
        .ilike('id', 'sal%');

    if (error) {
        console.error('Error fetching salespersons:', error);
        return [];
    }

    // Get all jobs for the specified date to count assignments
    const { data: jobsData } = await supabase
        .from('jobs')
        .select('receptionist');

    const jobsByDate = (jobsData ?? []).filter((job) => {
        const receptionist = job.receptionist as Record<string, unknown> | null;
        const appointmentDate = receptionist?.dateOfAppointment as string;
        const visitDate = receptionist?.dateOfVisit as string;
        return appointmentDate?.startsWith(date) || visitDate?.startsWith(date);
    });

    // Count jobs per salesperson for this date
    const jobCountByPerson: Record<string, number> = {};
    jobsByDate.forEach((job) => {
        const receptionist = job.receptionist as Record<string, unknown> | null;
        const assignedTo = receptionist?.assignedSalesperson as string;
        if (assignedTo) {
            jobCountByPerson[assignedTo] = (jobCountByPerson[assignedTo] ?? 0) + 1;
        }
    });

    const MAX_JOBS_PER_DAY = 3;

    // Map salespersons with date-specific availability
    const salespersons: Salesperson[] = (data ?? []).map((e) => {
        const jobsOnDate = jobCountByPerson[e.id] ?? 0;
        const isAvailableForDate = jobsOnDate < MAX_JOBS_PER_DAY;

        return {
            id: String(e.id ?? ''),
            name: String(e.full_name ?? ''),
            status: isAvailableForDate ? 'available' : 'busy',
            isAvailable: isAvailableForDate,
            numberOfJobs: jobsOnDate, // Jobs on this specific date
        };
    });

    // Sort: available first (with fewer jobs), then unavailable
    salespersons.sort((a, b) => {
        const aAvailable = a.isAvailable ? 0 : 1;
        const bAvailable = b.isAvailable ? 0 : 1;
        if (aAvailable !== bAvailable) return aAvailable - bAvailable;
        return a.numberOfJobs - b.numberOfJobs;
    });

    return salespersons;
}

/**
 * Check if a salesperson is available for a specific date
 */
export async function isSalespersonAvailableForDate(
    salespersonId: string,
    date: string
): Promise<boolean> {
    const jobCount = await getJobCountForSalespersonOnDate(salespersonId, date);
    return jobCount < 3;
}

/**
 * Assign a salesperson to an existing pending job
 */
export async function assignSalespersonToJob(
    jobId: string,
    salespersonId: string,
    appointmentDate: string
): Promise<{ success: boolean; error?: string }> {
    try {
        // Get current job data
        const { data: jobData, error: fetchError } = await supabase
            .from('jobs')
            .select('receptionist, status')
            .eq('id', jobId)
            .single();

        if (fetchError || !jobData) {
            return { success: false, error: 'Job not found' };
        }

        // Only allow assignment for pending/received jobs
        const currentStatus = jobData.status;
        if (currentStatus !== 'received' && currentStatus !== 'pending') {
            return { success: false, error: 'Job is already assigned' };
        }

        // Check salesperson availability
        const isAvailable = await isSalespersonAvailableForDate(salespersonId, appointmentDate);
        if (!isAvailable) {
            return { success: false, error: 'Salesperson is not available on this date' };
        }

        // Update receptionist JSON with salesperson assignment
        const receptionist = (jobData.receptionist as Record<string, unknown>) || {};
        receptionist.assignedSalesperson = salespersonId;

        // Update job
        const { error: updateError } = await supabase
            .from('jobs')
            .update({
                receptionist,
                status: 'salesperson_assigned',
                updated_at: new Date().toISOString(),
            })
            .eq('id', jobId);

        if (updateError) {
            return { success: false, error: updateError.message };
        }

        // Update salesperson's job count
        const { data: empData } = await supabase
            .from('employee')
            .select('assigned_job, number_of_jobs')
            .eq('id', salespersonId)
            .single();

        if (empData) {
            const currentJobs = Array.isArray(empData.assigned_job)
                ? empData.assigned_job
                : [];
            const numberOfJobs = Number(empData.number_of_jobs ?? 0);

            // Convert jobId to number for comparison (Supabase may store as number)
            const jobIdNum = Number(jobId);
            const jobIdStr = String(jobId);
            const alreadyAssigned = currentJobs.some((j: unknown) =>
                String(j) === jobIdStr || Number(j) === jobIdNum
            );

            if (!alreadyAssigned) {
                currentJobs.push(jobIdNum);
                const newJobCount = numberOfJobs + 1;
                const stillAvailable = newJobCount < 3;

                const { error: empUpdateError } = await supabase
                    .from('employee')
                    .update({
                        assigned_job: currentJobs,
                        number_of_jobs: newJobCount,
                        is_available: stillAvailable,
                    })
                    .eq('id', salespersonId);

                if (empUpdateError) {
                    console.error('Error updating employee job count:', empUpdateError);
                }
            }
        }

        return { success: true };
    } catch (err) {
        console.error('Error assigning salesperson:', err);
        return { success: false, error: 'An unexpected error occurred' };
    }
}

// Export as named service object for consistency
export const receptionistService = {
    getJobRequests,
    getSalespersons,
    getSalespersonsForDate,
    getJobCountForSalespersonOnDate,
    isSalespersonAvailableForDate,
    createJobRequest,
    assignSalespersonToJob,
    getReceptionistProfile,
    getDashboardStats,
    setSalespersonAvailable,
};

