/**
 * Accounts Dashboard Types
 */

export type InvoiceStatus = 'pending' | 'paid' | 'overdue';

export interface Invoice {
    id: string;
    invoiceNumber: string; // e.g. INV-2024-001
    jobCode: string; // Linked job
    customerName: string;
    amount: number;
    status: InvoiceStatus;
    dueDate: string;
    generatedAt: string;
}

export interface AccountsStats {
    totalRevenueToday: number;
    pendingInvoicesCount: number;
    totalOverdueAmount: number;
    monthlyRevenue: number;
}
