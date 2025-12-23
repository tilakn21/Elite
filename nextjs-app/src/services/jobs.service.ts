/**
 * Jobs Service
 * Handles all job-related data operations
 */

import { supabase } from './supabase';
import type { Job, JobSummary, DashboardStats } from '@/types';

/**
 * Parse JSONB field from Supabase response
 */
function parseJsonField<T>(field: unknown): T | null {
    if (!field) return null;
    if (typeof field === 'object') return field as T;
    if (typeof field === 'string') {
        try {
            return JSON.parse(field) as T;
        } catch {
            return null;
        }
    }
    return null;
}

/**
 * Fetch all jobs with pagination
 */
export async function getJobs(options: {
    page?: number;
    limit?: number;
    status?: string;
    branchId?: number;
} = {}): Promise<{ jobs: Job[]; total: number }> {
    const { page = 1, limit = 20, status, branchId } = options;
    const offset = (page - 1) * limit;

    let query = supabase
        .from('jobs')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

    if (status) {
        query = query.eq('status', status);
    }

    if (branchId) {
        query = query.eq('branch_id', branchId);
    }

    const { data, error, count } = await query;

    if (error) {
        console.error('Error fetching jobs:', error);
        throw new Error(`Failed to load jobs: ${error.message}`);
    }

    const jobs: Job[] = (data ?? []).map(job => ({
        id: job.id,
        job_code: job.job_code ?? job.id,
        status: job.status ?? 'Unknown',
        branch_id: job.branch_id,
        amount: job.amount,
        receptionist: parseJsonField(job.receptionist) || undefined,
        salesperson: parseJsonField(job.salesperson) || undefined,
        design: parseJsonField(job.design) || undefined,
        production: parseJsonField(job.production) || undefined,
        printing: parseJsonField(job.printing) || undefined,
        accounts: parseJsonField(job.accountant) || undefined,
        created_at: job.created_at,
        updated_at: job.updated_at,
    }));

    return { jobs, total: count ?? 0 };
}

/**
 * Fetch jobs as summary (for tables/lists)
 */
export async function getJobSummaries(options: {
    page?: number;
    limit?: number;
    status?: string;
} = {}): Promise<{ jobs: JobSummary[]; total: number }> {
    const { page = 1, limit = 20, status } = options;
    const offset = (page - 1) * limit;

    let query = supabase
        .from('jobs')
        .select('id, job_code, status, receptionist, created_at', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

    if (status) {
        query = query.eq('status', status);
    }

    const { data, error, count } = await query;

    if (error) {
        console.error('Error fetching job summaries:', error);
        throw new Error(`Failed to load jobs: ${error.message}`);
    }

    const jobs: JobSummary[] = (data ?? []).map(job => {
        const receptionist = parseJsonField<Record<string, unknown>>(job.receptionist);
        return {
            id: job.id,
            job_code: job.job_code ?? job.id,
            title: (receptionist?.shopName as string) ?? `Job ${job.job_code ?? job.id}`,
            client: (receptionist?.customerName as string) ?? 'Unknown Client',
            status: job.status ?? 'Unknown',
            date: new Date(job.created_at).toLocaleDateString(),
        };
    });

    return { jobs, total: count ?? 0 };
}

/**
 * Fetch a single job by ID
 */
export async function getJobById(id: string): Promise<Job | null> {
    const { data, error } = await supabase
        .from('jobs')
        .select('*')
        .eq('id', id)
        .single();

    if (error) {
        if (error.code === 'PGRST116') {
            return null;
        }
        console.error('Error fetching job:', error);
        throw new Error(`Failed to load job: ${error.message}`);
    }

    return {
        id: data.id,
        job_code: data.job_code ?? data.id,
        status: data.status ?? 'Unknown',
        branch_id: data.branch_id,
        amount: data.amount,
        receptionist: parseJsonField(data.receptionist) || undefined,
        salesperson: parseJsonField(data.salesperson) || undefined,
        design: parseJsonField(data.design) || undefined,
        production: parseJsonField(data.production) || undefined,
        printing: parseJsonField(data.printing) || undefined,
        accounts: parseJsonField(data.accountant) || undefined,
        created_at: data.created_at,
        updated_at: data.updated_at,
    };
}

/**
 * Get dashboard statistics
 * Uses workflow status to categorize jobs
 */
export async function getDashboardStats(): Promise<DashboardStats> {
    const { data, error } = await supabase
        .from('jobs')
        .select('status');

    if (error) {
        console.error('Error fetching stats:', error);
        return { totalJobs: 0, inProgress: 0, completed: 0, pending: 0 };
    }

    const jobs = data ?? [];
    const totalJobs = jobs.length;

    // Categorize by workflow stage
    let pending = 0;
    let inProgress = 0;
    let completed = 0;

    jobs.forEach(job => {
        const status = (job.status ?? '').toLowerCase();

        // Pending: just received
        if (status === 'received' || status === 'pending' || status === 'new' || status === 'draft') {
            pending++;
        }
        // Completed: out for delivery or explicitly completed
        else if (status === 'out_for_delivery' || status === 'completed' || status === 'done' || status === 'delivered') {
            completed++;
        }
        // In Progress: all intermediate stages
        else if (status) {
            inProgress++;
        }
    });

    return {
        totalJobs,
        inProgress,
        completed,
        pending,
    };
}

/**
 * Get recent jobs for dashboard
 */
export async function getRecentJobs(limit: number = 5): Promise<JobSummary[]> {
    const { jobs } = await getJobSummaries({ limit });
    return jobs;
}

/**
 * Update job status
 */
export async function updateJobStatus(id: string, status: string): Promise<void> {
    const { error } = await supabase
        .from('jobs')
        .update({ status, updated_at: new Date().toISOString() })
        .eq('id', id);

    if (error) {
        console.error('Error updating job status:', error);
        throw new Error(`Failed to update job: ${error.message}`);
    }
}

/**
 * Get job counts by status
 */
export async function getJobCountsByStatus(): Promise<Record<string, number>> {
    const { data, error } = await supabase
        .from('jobs')
        .select('status');

    if (error) {
        console.error('Error counting jobs:', error);
        return {};
    }

    const counts: Record<string, number> = {};
    data?.forEach(job => {
        const status = job.status ?? 'Unknown';
        counts[status] = (counts[status] ?? 0) + 1;
    });

    return counts;
}

/**
 * Get monthly revenue for charts
 */
export async function getMonthlyRevenue(months: number = 9): Promise<{ month: string; revenue: number }[]> {
    const now = new Date();
    const startDate = new Date(now.getFullYear(), now.getMonth() - months + 1, 1);

    const { data, error } = await supabase
        .from('jobs')
        .select('created_at, amount')
        .not('amount', 'is', null)
        .gte('created_at', startDate.toISOString())
        .order('created_at');

    if (error) {
        console.error('Error fetching revenue:', error);
        return [];
    }

    // Initialize monthly data
    const monthlyData: Record<string, number> = {};
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (let i = 0; i < months; i++) {
        const date = new Date(now.getFullYear(), now.getMonth() - months + 1 + i, 1);
        const key = `${monthNames[date.getMonth()]} ${date.getFullYear()}`;
        monthlyData[key] = 0;
    }

    // Aggregate data
    data?.forEach(job => {
        const date = new Date(job.created_at);
        const key = `${monthNames[date.getMonth()]} ${date.getFullYear()}`;
        if (key in monthlyData) {
            monthlyData[key] += job.amount ?? 0;
        }
    });

    return Object.entries(monthlyData).map(([month, revenue]) => ({ month, revenue }));
}

/**
 * Get today's appointments count
 * Looks at receptionist.dateOfAppointment field
 */
export async function getTodaysAppointments(): Promise<number> {
    const today: string = new Date().toISOString().split('T')[0] ?? '';

    const { data, error } = await supabase
        .from('jobs')
        .select('receptionist')
        .not('receptionist', 'is', null);

    if (error) {
        console.error('Error fetching appointments:', error);
        return 0;
    }

    let count = 0;
    data?.forEach(job => {
        if (job.receptionist) {
            const receptionist = parseJsonField<{ dateOfAppointment?: string }>(job.receptionist);
            const appointmentDate = receptionist?.dateOfAppointment;
            if (appointmentDate && appointmentDate.startsWith(today)) {
                count++;
            }
        }
    });

    return count;
}

/**
 * Get jobs stuck for more than 3 days (no status change)
 */
export async function getStuckJobs(): Promise<{ count: number; jobs: JobSummary[] }> {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

    const { data, error } = await supabase
        .from('jobs')
        .select('id, job_code, status, created_at, updated_at, receptionist')
        .not('status', 'ilike', '%completed%')
        .not('status', 'eq', 'out_for_delivery')
        .lte('updated_at', threeDaysAgo.toISOString())
        .order('updated_at', { ascending: true })
        .limit(10);

    if (error) {
        console.error('Error fetching stuck jobs:', error);
        return { count: 0, jobs: [] };
    }

    const jobs: JobSummary[] = (data ?? []).map(job => {
        const receptionist = parseJsonField<{ customerName?: string; shopName?: string }>(job.receptionist);
        return {
            id: job.id,
            job_code: job.job_code ?? job.id,
            title: receptionist?.shopName || `Job #${job.job_code}`,
            client: receptionist?.customerName ?? 'Unknown',
            status: job.status ?? 'unknown',
            date: job.updated_at ? new Date(job.updated_at).toLocaleDateString() : '',
        };
    });

    return { count: data?.length ?? 0, jobs };
}

/**
 * Activity item type for recent activity log
 */
export interface ActivityItem {
    id: string;
    jobCode: string;
    action: string;
    status: string;
    timestamp: string;
    department: string;
}

/**
 * Get recent activity across all jobs
 * Shows jobs ordered by most recently updated
 */
export async function getRecentActivity(limit: number = 10): Promise<ActivityItem[]> {
    const { data, error } = await supabase
        .from('jobs')
        .select('id, job_code, status, updated_at, created_at, receptionist')
        .order('updated_at', { ascending: false })
        .limit(limit);

    if (error) {
        console.error('Error fetching activity:', error);
        return [];
    }

    const getDepartment = (status: string): string => {
        const s = status?.toLowerCase() || '';
        if (s === 'received') return 'Reception';
        if (s.includes('salesperson') || s.includes('visit')) return 'Sales';
        if (s.includes('design')) return 'Design';
        if (s.includes('production')) return 'Production';
        if (s.includes('print')) return 'Printing';
        if (s.includes('delivery')) return 'Delivery';
        return 'Unknown';
    };

    const getAction = (status: string): string => {
        const s = status?.toLowerCase() || '';
        if (s === 'received') return 'Job received';
        if (s.includes('assigned')) return 'Assigned';
        if (s.includes('started')) return 'Started';
        if (s.includes('review')) return 'Sent for review';
        if (s.includes('approved')) return 'Approved';
        if (s.includes('completed')) return 'Completed';
        if (s.includes('visit')) return 'Site visited';
        if (s.includes('delivery')) return 'Out for delivery';
        return 'Status updated';
    };

    return (data ?? []).map(job => {
        const receptionist = parseJsonField<{ shopName?: string }>(job.receptionist);
        return {
            id: job.id,
            jobCode: receptionist?.shopName || `#${job.job_code}`,
            action: getAction(job.status),
            status: job.status ?? 'unknown',
            timestamp: job.updated_at ?? job.created_at,
            department: getDepartment(job.status),
        };
    });
}

