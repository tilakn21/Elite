/**
 * Reimbursements Service
 * Handles employee reimbursement requests with Supabase integration
 */

import { supabase } from './supabase';
import type { Reimbursement, ReimbursementInsert, ReimbursementStatus } from '@/types';

/**
 * Upload receipt image to Supabase storage
 */
export async function uploadReceiptToStorage(
    file: File,
    empId: string
): Promise<string | null> {
    try {
        const fileExt = file.name.split('.').pop();
        const fileName = `${empId}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}.${fileExt}`;
        const filePath = `receipts/${fileName}`;

        const { error: uploadError } = await supabase.storage
            .from('reimbursements')
            .upload(filePath, file);

        if (uploadError) {
            console.error('Receipt upload error:', uploadError);
            return null;
        }

        // Get public URL
        const { data: urlData } = supabase.storage
            .from('reimbursements')
            .getPublicUrl(filePath);

        return urlData?.publicUrl || null;
    } catch (error) {
        console.error('Error uploading receipt:', error);
        return null;
    }
}

/**
 * Fetch all reimbursements (Admin/Accounts view)
 */
export async function getReimbursements(): Promise<Reimbursement[]> {
    try {
        const { data, error } = await supabase
            .from('employee_reimbursement')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching reimbursements:', error);
            return [];
        }

        return (data || []).map(row => ({
            id: row.id,
            emp_id: row.emp_id,
            emp_name: row.emp_name,
            amount: parseFloat(row.amount),
            reimbursement_date: row.reimbursement_date,
            purpose: row.purpose,
            receipt_url: row.receipt_url || undefined,
            remarks: row.remarks || undefined,
            status: (row.status || 'pending') as ReimbursementStatus,
            created_at: row.created_at,
        }));
    } catch (error) {
        console.error('Error in getReimbursements:', error);
        return [];
    }
}

/**
 * Fetch reimbursements for a specific employee
 */
export async function getReimbursementsByEmployee(empId: string): Promise<Reimbursement[]> {
    try {
        const { data, error } = await supabase
            .from('employee_reimbursement')
            .select('*')
            .eq('emp_id', empId)
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching employee reimbursements:', error);
            return [];
        }

        return (data || []).map(row => ({
            id: row.id,
            emp_id: row.emp_id,
            emp_name: row.emp_name,
            amount: parseFloat(row.amount),
            reimbursement_date: row.reimbursement_date,
            purpose: row.purpose,
            receipt_url: row.receipt_url || undefined,
            remarks: row.remarks || undefined,
            status: (row.status || 'pending') as ReimbursementStatus,
            created_at: row.created_at,
        }));
    } catch (error) {
        console.error('Error in getReimbursementsByEmployee:', error);
        return [];
    }
}

/**
 * Create a reimbursement request
 */
export async function createReimbursement(
    reimbursement: ReimbursementInsert,
    receiptFile?: File
): Promise<Reimbursement | null> {
    try {
        // Upload receipt if provided
        let receiptUrl: string | undefined;
        if (receiptFile) {
            const uploadedUrl = await uploadReceiptToStorage(receiptFile, reimbursement.emp_id);
            if (uploadedUrl) {
                receiptUrl = uploadedUrl;
            }
        }

        // Insert into database
        const { data, error } = await supabase
            .from('employee_reimbursement')
            .insert({
                emp_id: reimbursement.emp_id,
                emp_name: reimbursement.emp_name,
                amount: reimbursement.amount,
                reimbursement_date: reimbursement.reimbursement_date,
                purpose: reimbursement.purpose,
                remarks: reimbursement.remarks || null,
                receipt_url: receiptUrl || reimbursement.receipt_url || null,
                status: 'pending',
            })
            .select()
            .single();

        if (error) {
            console.error('Error creating reimbursement:', error);
            return null;
        }

        return {
            id: data.id,
            emp_id: data.emp_id,
            emp_name: data.emp_name,
            amount: parseFloat(data.amount),
            reimbursement_date: data.reimbursement_date,
            purpose: data.purpose,
            receipt_url: data.receipt_url || undefined,
            remarks: data.remarks || undefined,
            status: data.status as ReimbursementStatus,
            created_at: data.created_at,
        };
    } catch (error) {
        console.error('Error in createReimbursement:', error);
        return null;
    }
}

/**
 * Update a reimbursement status (Admin/Accounts action)
 */
export async function updateReimbursementStatus(
    id: string,
    status: ReimbursementStatus
): Promise<boolean> {
    try {
        const { error } = await supabase
            .from('employee_reimbursement')
            .update({ status })
            .eq('id', id);

        if (error) {
            console.error('Error updating reimbursement status:', error);
            return false;
        }

        return true;
    } catch (error) {
        console.error('Error in updateReimbursementStatus:', error);
        return false;
    }
}

/**
 * Delete a reimbursement request
 */
export async function deleteReimbursement(id: string): Promise<boolean> {
    try {
        const { error } = await supabase
            .from('employee_reimbursement')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting reimbursement:', error);
            return false;
        }

        return true;
    } catch (error) {
        console.error('Error in deleteReimbursement:', error);
        return false;
    }
}

/**
 * Get unpaid reimbursements stats (approved but not yet paid)
 */
export async function getUnpaidReimbursementsTotal(): Promise<{ count: number; total: number }> {
    try {
        const { data, error } = await supabase
            .from('employee_reimbursement')
            .select('amount, status')
            .eq('status', 'approved');

        if (error) {
            console.error('Error fetching unpaid reimbursements:', error);
            return { count: 0, total: 0 };
        }

        const total = (data || []).reduce((sum, r) => sum + parseFloat(r.amount || '0'), 0);
        return { count: data?.length ?? 0, total };
    } catch (error) {
        console.error('Error in getUnpaidReimbursementsTotal:', error);
        return { count: 0, total: 0 };
    }
}

// Export as service object for consistent API
export const reimbursementsService = {
    getReimbursements,
    getReimbursementsByEmployee,
    createReimbursement,
    updateReimbursementStatus,
    deleteReimbursement,
    getUnpaidReimbursementsTotal,
    uploadReceiptToStorage,
};
