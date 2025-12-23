/**
 * Job Workflow Service
 * Manages job status transitions and payment validation
 */

import { supabase } from './supabase';
import type { JobStatus, PaymentStatus, PaymentRecord, Job } from '@/types/database';
import {
    STATUS_TRANSITIONS,
    PAYMENT_PRECONDITIONS,
    STATUS_LABELS,
    PAYMENT_STATUS_LABELS,
    WorkflowValidation
} from '@/types/job-workflow';

/**
 * Check if a status transition is allowed
 */
export function canTransitionTo(
    currentStatus: JobStatus,
    targetStatus: JobStatus,
    paymentStatus: PaymentStatus = 'payment_pending'
): WorkflowValidation {
    // Check if the transition is defined in allowed transitions
    const allowedNext = STATUS_TRANSITIONS[currentStatus] || [];

    if (!allowedNext.includes(targetStatus)) {
        return {
            allowed: false,
            reason: `Cannot transition from "${STATUS_LABELS[currentStatus]}" to "${STATUS_LABELS[targetStatus]}". Allowed next: ${allowedNext.map(s => STATUS_LABELS[s]).join(', ') || 'none'}`
        };
    }

    // Check payment preconditions if any
    const requiredPayment = PAYMENT_PRECONDITIONS[targetStatus];
    if (requiredPayment && !requiredPayment.includes(paymentStatus)) {
        return {
            allowed: false,
            reason: `"${STATUS_LABELS[targetStatus]}" requires payment status: ${requiredPayment.map(s => PAYMENT_STATUS_LABELS[s]).join(' or ')}. Current: ${PAYMENT_STATUS_LABELS[paymentStatus]}`,
            requiredPaymentStatus: requiredPayment
        };
    }

    return { allowed: true };
}

/**
 * Get allowed next statuses for a job
 */
export function getNextAllowedStatuses(
    currentStatus: JobStatus,
    paymentStatus: PaymentStatus = 'payment_pending'
): { status: JobStatus; label: string; blocked: boolean; blockReason?: string }[] {
    const allowedNext = STATUS_TRANSITIONS[currentStatus] || [];

    return allowedNext.map(status => {
        const validation = canTransitionTo(currentStatus, status, paymentStatus);
        return {
            status,
            label: STATUS_LABELS[status],
            blocked: !validation.allowed,
            blockReason: validation.reason
        };
    });
}

/**
 * Calculate payment status based on amounts
 */
export function calculatePaymentStatus(totalAmount: number, amountPaid: number): PaymentStatus {
    if (amountPaid <= 0) return 'payment_pending';
    if (amountPaid >= totalAmount) return 'payment_done';
    return 'partially_paid';
}

/**
 * Get payment status for a job
 */
export async function getJobPaymentStatus(jobId: string): Promise<{
    paymentStatus: PaymentStatus;
    totalAmount: number;
    amountPaid: number;
    payments: PaymentRecord[];
}> {
    const { data, error } = await supabase
        .from('jobs')
        .select('amount, accountant')
        .eq('id', jobId)
        .single();

    if (error || !data) {
        console.error('Error fetching job payment status:', error);
        return {
            paymentStatus: 'payment_pending',
            totalAmount: 0,
            amountPaid: 0,
            payments: []
        };
    }

    const accounts = data.accountant || {};
    const totalAmount = data.amount || accounts.total_amount || accounts.totalAmount || 0;
    const amountPaid = accounts.amount_paid || accounts.amountPaid || 0;
    const payments = accounts.payments || [];
    const paymentStatus = accounts.payment_status || calculatePaymentStatus(totalAmount, amountPaid);

    return { paymentStatus, totalAmount, amountPaid, payments };
}

/**
 * Transition job to a new status with validation
 */
export async function transitionJobStatus(
    jobId: string,
    newStatus: JobStatus,
    userId?: string
): Promise<{ success: boolean; error?: string }> {
    try {
        // Fetch current job state
        const { data: job, error: fetchError } = await supabase
            .from('jobs')
            .select('status, accountant, amount')
            .eq('id', jobId)
            .single();

        if (fetchError || !job) {
            return { success: false, error: 'Job not found' };
        }

        const currentStatus = job.status as JobStatus;
        const accounts = job.accountant || {};
        const paymentStatus = accounts.payment_status || 'payment_pending';

        // Validate transition
        const validation = canTransitionTo(currentStatus, newStatus, paymentStatus);
        if (!validation.allowed) {
            return { success: false, error: validation.reason };
        }

        // Update job status
        const { error: updateError } = await supabase
            .from('jobs')
            .update({
                status: newStatus,
                updated_at: new Date().toISOString()
            })
            .eq('id', jobId);

        if (updateError) {
            return { success: false, error: updateError.message };
        }

        // Log to timeline if needed (optional)
        if (userId) {
            try {
                await supabase.from('job_timeline').insert({
                    job_id: jobId,
                    stage: newStatus,
                    updated_by: userId,
                    timestamp: new Date().toISOString()
                });
            } catch {
                // Silent fail for timeline logging
            }
        }

        return { success: true };
    } catch (error) {
        console.error('Error transitioning job status:', error);
        return { success: false, error: 'Failed to update status' };
    }
}

/**
 * Record a payment for a job
 */
export async function recordPayment(
    jobId: string,
    amount: number,
    mode: PaymentRecord['mode'],
    recordedBy: string,
    notes?: string
): Promise<{ success: boolean; newPaymentStatus?: PaymentStatus; error?: string }> {
    try {
        // Fetch current job
        const { data: job, error: fetchError } = await supabase
            .from('jobs')
            .select('amount, accountant')
            .eq('id', jobId)
            .single();

        if (fetchError || !job) {
            return { success: false, error: 'Job not found' };
        }

        const accounts = job.accountant || {};
        const totalAmount = job.amount || accounts.total_amount || 0;
        const currentPaid = accounts.amount_paid || 0;
        const currentPayments: PaymentRecord[] = accounts.payments || [];

        // Create new payment record
        const newPayment: PaymentRecord = {
            id: `pay_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            amount,
            mode,
            recorded_by: recordedBy,
            recorded_at: new Date().toISOString(),
            notes
        };

        const newAmountPaid = currentPaid + amount;
        const newPaymentStatus = calculatePaymentStatus(totalAmount, newAmountPaid);

        // Update job with new payment
        const { error: updateError } = await supabase
            .from('jobs')
            .update({
                accountant: {
                    ...accounts,
                    amount_paid: newAmountPaid,
                    payment_status: newPaymentStatus,
                    payments: [...currentPayments, newPayment],
                    total_amount: totalAmount
                },
                updated_at: new Date().toISOString()
            })
            .eq('id', jobId);

        if (updateError) {
            return { success: false, error: updateError.message };
        }

        return { success: true, newPaymentStatus };
    } catch (error) {
        console.error('Error recording payment:', error);
        return { success: false, error: 'Failed to record payment' };
    }
}

/**
 * Get jobs filtered by status(es)
 */
export async function getJobsByStatus(
    statuses: JobStatus | JobStatus[],
    options: { limit?: number; page?: number } = {}
): Promise<Job[]> {
    const { limit = 50, page = 1 } = options;
    const offset = (page - 1) * limit;
    const statusList = Array.isArray(statuses) ? statuses : [statuses];

    const { data, error } = await supabase
        .from('jobs')
        .select('*')
        .in('status', statusList)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

    if (error) {
        console.error('Error fetching jobs by status:', error);
        return [];
    }

    return (data || []).map(job => ({
        id: job.id,
        job_code: job.job_code || job.id,
        status: job.status,
        branch_id: job.branch_id,
        amount: job.amount,
        created_at: job.created_at,
        updated_at: job.updated_at,
        receptionist: job.receptionist,
        salesperson: job.salesperson,
        design: job.design,
        production: job.production,
        printing: job.printing,
        accounts: job.accountant
    }));
}

/**
 * Get jobs filtered by payment status
 */
export async function getJobsByPaymentStatus(
    paymentStatus: PaymentStatus
): Promise<Job[]> {
    // Using JSONB path query
    const { data, error } = await supabase
        .from('jobs')
        .select('*')
        .eq('accountant->>payment_status', paymentStatus)
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Error fetching jobs by payment status:', error);
        return [];
    }

    return (data || []).map(job => ({
        id: job.id,
        job_code: job.job_code || job.id,
        status: job.status,
        branch_id: job.branch_id,
        amount: job.amount,
        created_at: job.created_at,
        updated_at: job.updated_at,
        receptionist: job.receptionist,
        salesperson: job.salesperson,
        design: job.design,
        production: job.production,
        printing: job.printing,
        accounts: job.accountant
    }));
}

// Export as named service
export const jobWorkflowService = {
    canTransitionTo,
    getNextAllowedStatuses,
    calculatePaymentStatus,
    getJobPaymentStatus,
    transitionJobStatus,
    recordPayment,
    getJobsByStatus,
    getJobsByPaymentStatus
};

export default jobWorkflowService;
