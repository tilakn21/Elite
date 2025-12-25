/**
 * Accounts Service
 * Handles financial data, invoicing, and payment management
 */

import { supabase } from './supabase';
import type { Invoice, InvoiceStatus, AccountsStats } from '@/types/accounts';
import type { PaymentStatus, PaymentRecord, Job } from '@/types/database';

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

            const accountant = job.accountant || {};
            const totalAmount = job.amount || accountant.total_amount || 0;
            const currentPaid = accountant.amount_paid || 0;
            const currentPayments = accountant.payments || [];

            // Create new payment record matching user's schema
            const newPayment = {
                date: new Date().toISOString(),
                mode: mode.charAt(0).toUpperCase() + mode.slice(1), // Capitalize first letter as per example
                amount: amount,
                received_by: recordedBy, // User uses received_by
                notes: notes
            };

            const newAmountPaid = currentPaid + amount;
            const newAmountRemaining = Math.max(0, totalAmount - newAmountPaid);

            // Calculate payment status
            let newPaymentStatus: PaymentStatus = 'payment_pending';
            if (newAmountPaid >= totalAmount && totalAmount > 0) {
                newPaymentStatus = 'payment_done';
            } else if (newAmountPaid > 0) {
                newPaymentStatus = 'partially_paid'; // User uses partially_paid
            }

            // Update job with new payment
            const { error: updateError } = await supabase
                .from('jobs')
                .update({
                    accountant: {
                        ...accountant,
                        amount_paid: newAmountPaid,
                        total_amount: totalAmount,
                        payment_status: newPaymentStatus,
                        amount_remaining: newAmountRemaining,
                        payments: [...currentPayments, newPayment]
                    }
                })
                .eq('id', jobId);

            if (updateError) {
                console.error('Update error:', updateError);
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

            const accountant = job?.accountant || {};
            const amountPaid = accountant.amount_paid || 0;
            const amountRemaining = Math.max(0, amount - amountPaid);

            // Calculate payment status
            let newPaymentStatus: PaymentStatus = 'payment_pending';
            if (amountPaid >= amount && amount > 0) {
                newPaymentStatus = 'payment_done';
            } else if (amountPaid > 0) {
                newPaymentStatus = 'partially_paid';
            }

            const { error } = await supabase
                .from('jobs')
                .update({
                    amount: amount, // Update top-level column
                    accountant: {
                        ...accountant,
                        total_amount: amount,
                        payment_status: newPaymentStatus,
                        amount_remaining: amountRemaining
                    }
                })
                .eq('id', jobId);

            if (error) {
                console.error('Set amount error:', error);
            }
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

    /**
     * Get recent payments for the activity feed
     */
    async getRecentPayments(limit: number = 10): Promise<Array<{
        id: string;
        jobCode: string;
        customerName: string;
        amount: number;
        mode: string;
        recordedAt: string;
    }>> {
        try {
            const { data: jobs } = await supabase
                .from('jobs')
                .select('id, job_code, receptionist, accountant, created_at')
                .not('accountant', 'is', null)
                .order('created_at', { ascending: false })
                .limit(50);

            const payments: Array<{
                id: string;
                jobCode: string;
                customerName: string;
                amount: number;
                mode: string;
                recordedAt: string;
            }> = [];

            (jobs || []).forEach(job => {
                const accounts = job.accountant || {};
                const receptionist = (job.receptionist || {}) as Record<string, unknown>;
                const paymentRecords = accounts.payments || [];

                paymentRecords.forEach((payment: Record<string, unknown>) => {
                    payments.push({
                        id: payment.id as string || `${job.id}-${payments.length}`,
                        jobCode: job.job_code || job.id,
                        customerName: (receptionist.customerName as string) || 'Unknown',
                        amount: payment.amount as number || 0,
                        mode: payment.mode as string || 'cash',
                        recordedAt: (payment.date as string) || (payment.recorded_at as string) || job.created_at,
                    });
                });
            });

            // Sort by date and return top N
            return payments
                .sort((a, b) => new Date(b.recordedAt).getTime() - new Date(a.recordedAt).getTime())
                .slice(0, limit);
        } catch (error) {
            console.error('Error fetching recent payments:', error);
            return [];
        }
    }

    /**
     * Get jobs pending invoice generation (design approved but no invoice)
     */
    async getPendingInvoiceJobs(): Promise<Array<{
        id: string;
        jobCode: string;
        customerName: string;
        shopName: string;
        amount: number;
        status: string;
    }>> {
        try {
            const { data: jobs } = await supabase
                .from('jobs')
                .select('id, job_code, status, amount, receptionist, accountant')
                .or('status.eq.design_approved,status.eq.production_completed,status.eq.printing_completed')
                .order('created_at', { ascending: true });

            return (jobs || [])
                .filter(job => {
                    const accounts = job.accountant || {};
                    // No invoice generated yet
                    return !accounts.invoice_no && !accounts.invoiceNumber;
                })
                .map(job => {
                    const receptionist = (job.receptionist || {}) as Record<string, unknown>;
                    return {
                        id: job.id,
                        jobCode: job.job_code || job.id,
                        customerName: (receptionist.customerName as string) || 'Unknown',
                        shopName: (receptionist.shopName as string) || '',
                        amount: job.amount || 0,
                        status: job.status || 'unknown',
                    };
                });
        } catch (error) {
            console.error('Error fetching pending invoice jobs:', error);
            return [];
        }
    }

    /**
     * Get weekly collection stats
     */
    async getWeeklyStats(): Promise<{
        weeklyCollection: number;
        weekPayments: number;
        overdueCount: number;
        overdueAmount: number;
    }> {
        try {
            const now = new Date();
            const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

            const { data: jobs } = await supabase
                .from('jobs')
                .select('amount, accountant, created_at');

            let weeklyCollection = 0;
            let weekPayments = 0;
            let overdueCount = 0;
            let overdueAmount = 0;

            (jobs || []).forEach(job => {
                const accounts = job.accountant || {};
                const amountPaid = accounts.amount_paid || 0;
                const totalAmount = job.amount || accounts.total_amount || 0;
                const paymentRecords = accounts.payments || [];
                const createdAt = new Date(job.created_at);
                const daysSinceCreation = (now.getTime() - createdAt.getTime()) / (1000 * 60 * 60 * 24);

                // Weekly payments
                paymentRecords.forEach((payment: Record<string, unknown>) => {
                    const dateStr = (payment.date as string) || (payment.recorded_at as string);
                    if (dateStr) {
                        const paymentDate = new Date(dateStr);
                        if (paymentDate >= weekAgo) {
                            weeklyCollection += (payment.amount as number) || 0;
                            weekPayments++;
                        }
                    }
                });

                // Overdue (pending > 30 days)
                if (amountPaid < totalAmount && daysSinceCreation > 30) {
                    overdueCount++;
                    overdueAmount += totalAmount - amountPaid;
                }
            });

            return { weeklyCollection, weekPayments, overdueCount, overdueAmount };
        } catch (error) {
            console.error('Error fetching weekly stats:', error);
            return { weeklyCollection: 0, weekPayments: 0, overdueCount: 0, overdueAmount: 0 };
        }
    }

    /**
     * Get all jobs with payment information for accounts management
     */
    async getJobsForAccounts(filter?: 'all' | 'pending' | 'partial' | 'paid'): Promise<Array<{
        id: string;
        jobCode: string;
        customerName: string;
        shopName: string;
        phone: string;
        status: string;
        totalAmount: number;
        amountPaid: number;
        paymentStatus: string;
        createdAt: string;
        updatedAt: string;
    }>> {
        try {
            const { data: jobs } = await supabase
                .from('jobs')
                .select('*')
                .order('created_at', { ascending: false });

            const result = (jobs || []).map(job => {
                const receptionist = (job.receptionist || {}) as Record<string, unknown>;
                const accounts = (job.accountant || {}) as Record<string, unknown>;
                const totalAmount = job.amount || (accounts.total_amount as number) || 0;
                const amountPaid = (accounts.amount_paid as number) || 0;

                let paymentStatus = 'pending';
                const storedStatus = accounts.payment_status as string;

                if (storedStatus) {
                    if (storedStatus === 'payment_done') paymentStatus = 'paid';
                    else if (storedStatus === 'partially_paid') paymentStatus = 'partial';
                    else if (storedStatus === 'payment_pending') paymentStatus = 'pending';
                    else paymentStatus = storedStatus; // Fallback
                } else {
                    // Fallback calculation
                    if (amountPaid >= totalAmount && totalAmount > 0) {
                        paymentStatus = 'paid';
                    } else if (amountPaid > 0) {
                        paymentStatus = 'partial';
                    }
                }

                return {
                    id: job.id,
                    jobCode: job.job_code || job.id,
                    customerName: (receptionist.customerName as string) || (receptionist.client_name as string) || 'Unknown',
                    shopName: (receptionist.shopName as string) || '',
                    phone: (receptionist.phone as string) || (receptionist.client_phone as string) || '',
                    status: job.status || 'unknown',
                    totalAmount,
                    amountPaid,
                    paymentStatus,
                    createdAt: job.created_at,
                    updatedAt: job.updated_at,
                };
            });

            if (!filter || filter === 'all') {
                return result;
            }
            return result.filter(job => job.paymentStatus === filter);
        } catch (error) {
            console.error('Error fetching jobs for accounts:', error);
            return [];
        }
    }

    /**
     * Get all payments from all jobs as a ledger
     */
    async getAllPayments(limit: number = 50): Promise<Array<{
        id: string;
        jobId: string;
        jobCode: string;
        customerName: string;
        amount: number;
        mode: string;
        recordedBy: string;
        recordedAt: string;
        notes?: string;
    }>> {
        try {
            const { data: jobs } = await supabase
                .from('jobs')
                .select('id, job_code, receptionist, accountant, created_at')
                .not('accountant', 'is', null)
                .order('created_at', { ascending: false });

            const payments: Array<{
                id: string;
                jobId: string;
                jobCode: string;
                customerName: string;
                amount: number;
                mode: string;
                recordedBy: string;
                recordedAt: string;
                notes?: string;
            }> = [];

            (jobs || []).forEach(job => {
                const accounts = job.accountant || {};
                const receptionist = (job.receptionist || {}) as Record<string, unknown>;
                const paymentRecords = accounts.payments || [];

                paymentRecords.forEach((payment: Record<string, unknown>) => {
                    payments.push({
                        id: payment.id as string || `${job.id}-${payments.length}`,
                        jobId: job.id,
                        jobCode: job.job_code || job.id,
                        customerName: (receptionist.customerName as string) || 'Unknown',
                        amount: payment.amount as number || 0,
                        mode: payment.mode as string || 'cash',
                        recordedBy: (payment.received_by as string) || (payment.recorded_by as string) || 'Unknown',
                        recordedAt: (payment.date as string) || (payment.recorded_at as string) || job.created_at,
                        notes: payment.notes as string,
                    });
                });
            });

            // Sort by date descending
            return payments
                .sort((a, b) => new Date(b.recordedAt).getTime() - new Date(a.recordedAt).getTime())
                .slice(0, limit);
        } catch (error) {
            console.error('Error fetching all payments:', error);
            return [];
        }
    }

    /**
     * Generate next invoice number
     */
    async generateInvoiceNumber(): Promise<string> {
        const year = new Date().getFullYear();
        const { count } = await supabase
            .from('jobs')
            .select('*', { count: 'exact', head: true });

        const invoiceNum = (count || 0) + 1;
        return `INV-${year}-${String(invoiceNum).padStart(4, '0')}`;
    }

    /**
     * Update job with invoice number
     */
    async setInvoiceNumber(jobId: string, invoiceNumber: string): Promise<boolean> {
        try {
            const { data: job } = await supabase
                .from('jobs')
                .select('accountant')
                .eq('id', jobId)
                .single();

            const accounts = job?.accountant || {};

            const { error } = await supabase
                .from('jobs')
                .update({
                    accountant: {
                        ...accounts,
                        invoiceNumber,
                        invoice_no: invoiceNumber,
                    }
                })
                .eq('id', jobId);

            return !error;
        } catch (error) {
            console.error('Error setting invoice number:', error);
            return false;
        }
    }

    /**
     * Generate and save invoice for a job
     */
    async generateInvoice(jobId: string): Promise<{
        success: boolean;
        invoiceNumber?: string;
        invoiceData?: {
            invoiceNumber: string;
            jobCode: string;
            customerName: string;
            shopName: string;
            phone: string;
            address: string;
            totalAmount: number;
            amountPaid: number;
            payments: Array<{ amount: number; mode: string; date: string }>;
            generatedAt: string;
            status: string;
        };
        error?: string;
    }> {
        try {
            // Fetch job data
            const { data: job, error: fetchError } = await supabase
                .from('jobs')
                .select('*')
                .eq('id', jobId)
                .single();

            if (fetchError || !job) {
                return { success: false, error: 'Job not found' };
            }

            const receptionist = (job.receptionist || {}) as Record<string, unknown>;
            const accounts = (job.accountant || {}) as Record<string, unknown>;

            // Check if invoice already exists
            if (accounts.invoiceNumber || accounts.invoice_no) {
                return {
                    success: true,
                    invoiceNumber: (accounts.invoiceNumber as string) || (accounts.invoice_no as string),
                    invoiceData: {
                        invoiceNumber: (accounts.invoiceNumber as string) || (accounts.invoice_no as string),
                        jobCode: job.job_code || job.id,
                        customerName: (receptionist.customerName as string) || (receptionist.client_name as string) || 'Unknown',
                        shopName: (receptionist.shopName as string) || '',
                        phone: (receptionist.phone as string) || (receptionist.client_phone as string) || '',
                        address: `${(receptionist.streetAddress as string) || ''}, ${(receptionist.town as string) || ''}`.trim().replace(/^,\s*|,\s*$/g, ''),
                        totalAmount: job.amount || 0,
                        amountPaid: (accounts.amount_paid as number) || 0,
                        payments: ((accounts.payments as Array<Record<string, unknown>>) || []).map(p => ({
                            amount: p.amount as number,
                            mode: p.mode as string,
                            date: (p.date as string) || (p.recorded_at as string)
                        })),
                        generatedAt: (accounts.invoiceGeneratedAt as string) || new Date().toISOString(),
                        status: 'paid'
                    }
                };
            }

            // Generate new invoice number
            const invoiceNumber = await this.generateInvoiceNumber();
            const generatedAt = new Date().toISOString();

            // Update job with invoice details - merge accountant data
            const updatedAccountant = {
                ...(accounts as Record<string, unknown>),
                invoiceNumber,
                invoice_no: invoiceNumber,
                invoiceGeneratedAt: generatedAt,
            };

            const { error: updateError } = await supabase
                .from('jobs')
                .update({
                    accountant: updatedAccountant
                })
                .eq('id', jobId);

            if (updateError) {
                console.error('Invoice save error:', updateError);
                return { success: false, error: `Failed to save invoice: ${updateError.message}` };
            }

            return {
                success: true,
                invoiceNumber,
                invoiceData: {
                    invoiceNumber,
                    jobCode: job.job_code || job.id,
                    customerName: (receptionist.customerName as string) || (receptionist.client_name as string) || 'Unknown',
                    shopName: (receptionist.shopName as string) || '',
                    phone: (receptionist.phone as string) || (receptionist.client_phone as string) || '',
                    address: `${(receptionist.streetAddress as string) || ''}, ${(receptionist.town as string) || ''}`.trim().replace(/^,\s*|,\s*$/g, ''),
                    totalAmount: job.amount || 0,
                    amountPaid: (accounts.amount_paid as number) || 0,
                    payments: ((accounts.payments as Array<Record<string, unknown>>) || []).map(p => ({
                        amount: p.amount as number,
                        mode: p.mode as string,
                        date: (p.date as string) || (p.recorded_at as string)
                    })),
                    generatedAt,
                    status: 'paid'
                }
            };
        } catch (error) {
            console.error('Error generating invoice:', error);
            return { success: false, error: 'Failed to generate invoice' };
        }
    }

    /**
     * Get invoice data for a job
     */
    async getInvoiceData(jobId: string): Promise<{
        invoiceNumber: string;
        jobCode: string;
        customerName: string;
        shopName: string;
        phone: string;
        address: string;
        signType: string;
        totalAmount: number;
        amountPaid: number;
        payments: Array<{ amount: number; mode: string; date: string }>;
        generatedAt: string;
        status: string;
    } | null> {
        try {
            const { data: job, error } = await supabase
                .from('jobs')
                .select('*')
                .eq('id', jobId)
                .single();

            if (error || !job) return null;

            const receptionist = (job.receptionist || {}) as Record<string, unknown>;
            const salesperson = (job.salesperson || {}) as Record<string, unknown>;
            const accounts = (job.accountant || {}) as Record<string, unknown>;

            return {
                invoiceNumber: (accounts.invoiceNumber as string) || (accounts.invoice_no as string) || '',
                jobCode: job.job_code || job.id,
                customerName: (receptionist.customerName as string) || (receptionist.client_name as string) || 'Unknown',
                shopName: (receptionist.shopName as string) || '',
                phone: (receptionist.phone as string) || (receptionist.client_phone as string) || '',
                address: `${(receptionist.streetAddress as string) || ''}, ${(receptionist.town as string) || ''}`.trim().replace(/^,\s*|,\s*$/g, ''),
                signType: (salesperson.typeOfSign as string) || 'Signboard',
                totalAmount: job.amount || 0,
                amountPaid: (accounts.amount_paid as number) || 0,
                payments: ((accounts.payments as Array<Record<string, unknown>>) || []).map(p => ({
                    amount: p.amount as number,
                    mode: p.mode as string,
                    date: (p.date as string) || (p.recorded_at as string)
                })),
                generatedAt: (accounts.invoiceGeneratedAt as string) || '',
                status: job.status
            };
        } catch (error) {
            console.error('Error fetching invoice data:', error);
            return null;
        }
    }
}

export const accountsService = new AccountsService();
