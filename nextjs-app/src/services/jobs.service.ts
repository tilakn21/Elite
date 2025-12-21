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

    // Count by status (case-insensitive)
    const statusCounts = jobs.reduce((acc, job) => {
        const status = (job.status ?? '').toLowerCase();
        acc[status] = (acc[status] ?? 0) + 1;
        return acc;
    }, {} as Record<string, number>);

    return {
        totalJobs,
        inProgress: statusCounts['in_progress'] ?? statusCounts['in progress'] ?? statusCounts['inprogress'] ?? 0,
        completed: statusCounts['completed'] ?? statusCounts['done'] ?? 0,
        pending: statusCounts['pending'] ?? statusCounts['new'] ?? statusCounts['draft'] ?? 0,
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
