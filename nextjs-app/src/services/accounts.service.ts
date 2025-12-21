/**
 * Accounts Service
 * Handles financial data and invoicing
 */

import { } from './supabase';
import type { Invoice, InvoiceStatus, AccountsStats } from '@/types/accounts';

// Mock data
const MOCK_INVOICES: Invoice[] = [
    {
        id: 'inv-1',
        invoiceNumber: 'INV-2024-1001',
        jobCode: 'JB-5005',
        customerName: 'Retail Solutions',
        amount: 5000,
        status: 'pending',
        dueDate: new Date(Date.now() + 86400000).toISOString(),
        generatedAt: new Date().toISOString()
    },
    {
        id: 'inv-2',
        invoiceNumber: 'INV-2024-1002',
        jobCode: 'JB-4020',
        customerName: 'City Cafe',
        amount: 2500,
        status: 'paid',
        dueDate: new Date().toISOString(),
        generatedAt: new Date(Date.now() - 86400000).toISOString()
    },
    {
        id: 'inv-3',
        invoiceNumber: 'INV-2024-0998',
        jobCode: 'JB-3900',
        customerName: 'Tech Innovations',
        amount: 15000,
        status: 'overdue',
        dueDate: new Date(Date.now() - 172800000).toISOString(),
        generatedAt: new Date(Date.now() - 432000000).toISOString()
    }
];

class AccountsService {
    /**
     * Get dashboard stats (Mocked)
     */
    async getStats(): Promise<AccountsStats> {
        return {
            totalRevenueToday: 25000,
            pendingInvoicesCount: 8,
            totalOverdueAmount: 15000,
            monthlyRevenue: 450000
        };
    }

    /**
     * Get list of invoices
     */
    async getInvoices(statusFilter?: InvoiceStatus | 'all'): Promise<Invoice[]> {
        return new Promise((resolve) => {
            setTimeout(() => {
                if (!statusFilter || statusFilter === 'all') {
                    resolve(MOCK_INVOICES);
                } else {
                    resolve(MOCK_INVOICES.filter(inv => inv.status === statusFilter));
                }
            }, 500);
        });
    }

    /**
     * Generate a new invoice (Mocked)
     */
    async createInvoice(jobId: string, amount: number): Promise<boolean> {
        console.log(`Generating invoice for ${jobId} with amount ${amount}`);
        return true;
    }
}

export const accountsService = new AccountsService();
