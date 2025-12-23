/**
 * Accounts Service
 * Handles financial data, invoicing, and payment management
 */

import { supabase } from './supabase';
import type { Invoice, InvoiceStatus, AccountsStats } from '@/types/accounts';
import type { PaymentStatus, PaymentRecord, Job } from '@/types/database';
import { calculatePaymentStatus } from './job-workflow.service';

class AccountsService {
    /**
     * Get dashboard stats from real data
     */
    async getStats(): Promise<AccountsStats> {
        try {
            const { data: jobs } = await supabase
                .from('jobs')
                .select('amount, accountant, created_at');

            if (!jobs) {
                return {
                    totalRevenueToday: 0,
                    pendingInvoicesCount: 0,
                    totalOverdueAmount: 0,
                    monthlyRevenue: 0
                };
            }

            const today = new Date().toISOString().split('T')[0];
            const thisMonth = new Date().toISOString().slice(0, 7); // YYYY-MM

            let totalRevenueToday = 0;
            let pendingCount = 0;
            let monthlyRevenue = 0;

            jobs.forEach(job => {
                const accounts = job.accountant || {};
                const amountPaid = accounts.amount_paid || 0;
                const paymentStatus = accounts.payment_status;
                const createdDate = job.created_at?.split('T')[0];

                if (paymentStatus === 'payment_pending') {
                    pendingCount++;
                }

                if (createdDate === today) {
                    totalRevenueToday += amountPaid;
                }

                if (job.created_at?.startsWith(thisMonth)) {
                    monthlyRevenue += amountPaid;
                }
            });

            return {
                totalRevenueToday,
                pendingInvoicesCount: pendingCount,
                totalOverdueAmount: 0, // Would need due date logic
                monthlyRevenue
            };
        } catch (error) {
            console.error('Error fetching accounts stats:', error);
            return {
                totalRevenueToday: 0,
                pendingInvoicesCount: 0,
                totalOverdueAmount: 0,
                monthlyRevenue: 0
            };
        }
    }

    /**
     * Get list of invoices (jobs as invoices)
     */
    async getInvoices(statusFilter?: InvoiceStatus | 'all'): Promise<Invoice[]> {
        try {
            const { data, error } = await supabase
                .from('jobs')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) {
                console.error('Error fetching invoices:', error);
                return [];
            }

            const invoices = (data || []).map(job => this.mapToInvoice(job));

            if (!statusFilter || statusFilter === 'all') {
                return invoices;
            }

            return invoices.filter(inv => inv.status === statusFilter);
        } catch (error) {
            console.error('Error in getInvoices:', error);
            return [];
        }
    }

    /**
     * Get jobs filtered by payment status
     */
    async getJobsByPaymentStatus(paymentStatus: PaymentStatus): Promise<Job[]> {
        try {
            const { data, error } = await supabase
                .from('jobs')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) {
                console.error('Error fetching jobs:', error);
                return [];
            }

            // Filter by payment status in accountant JSONB
            return (data || [])
                .filter(job => {
                    const accounts = job.accountant || {};
                    return accounts.payment_status === paymentStatus;
                })
                .map(job => ({
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
        } catch (error) {
            console.error('Error in getJobsByPaymentStatus:', error);
            return [];
        }
    }

    /**
     * Record a payment for a job
     */
    async recordPayment(
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
     * Update job's total amount
     */
    async setJobAmount(jobId: string, amount: number): Promise<boolean> {
        try {
            const { data: job } = await supabase
                .from('jobs')
                .select('accountant')
                .eq('id', jobId)
                .single();

            const accounts = job?.accountant || {};
            const amountPaid = accounts.amount_paid || 0;
            const newPaymentStatus = calculatePaymentStatus(amount, amountPaid);

            const { error } = await supabase
                .from('jobs')
                .update({
                    amount,
                    accountant: {
                        ...accounts,
                        total_amount: amount,
                        payment_status: newPaymentStatus
                    },
                    updated_at: new Date().toISOString()
                })
                .eq('id', jobId);

            return !error;
        } catch (error) {
            console.error('Error setting job amount:', error);
            return false;
        }
    }

    /**
     * Map job row to Invoice type
     */
    private mapToInvoice(job: Record<string, unknown>): Invoice {
        const receptionist = (job.receptionist || {}) as Record<string, unknown>;
        const accounts = (job.accountant || {}) as Record<string, unknown>;
        const totalAmount = (job.amount as number) || (accounts.total_amount as number) || 0;

        // Determine invoice status
        let status: InvoiceStatus = 'pending';
        const paymentStatus = accounts.payment_status as PaymentStatus;
        if (paymentStatus === 'payment_done') {
            status = 'paid';
        } else if (paymentStatus === 'payment_pending' && totalAmount > 0) {
            // Check if overdue (simple: older than 30 days)
            const createdAt = new Date(job.created_at as string);
            const daysSinceCreation = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24);
            if (daysSinceCreation > 30) {
                status = 'overdue';
            }
        }

        return {
            id: job.id as string,
            invoiceNumber: (accounts.invoiceNumber as string) || `INV-${job.job_code || job.id}`,
            jobCode: (job.job_code || job.id) as string,
            customerName: (receptionist.customerName as string) || 'Unknown',
            amount: totalAmount,
            status,
            dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days from now
            generatedAt: job.created_at as string
        };
    }
}

export const accountsService = new AccountsService();
