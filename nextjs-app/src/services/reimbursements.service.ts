/**
 * Reimbursements Service
 * Handles employee reimbursement requests
 */

import type { Reimbursement, ReimbursementInsert } from '@/types';

/**
 * Fetch all reimbursements (Admin/Accounts view)
 */
export async function getReimbursements(): Promise<Reimbursement[]> {
    // Mock data for now until table is confirmed
    // TODO: Create 'reimbursements' table in Supabase
    console.warn('Using mock data for reimbursements');

    return Promise.resolve([
        {
            id: '1',
            emp_id: 'emp001',
            emp_name: 'John Doe',
            amount: 150.00,
            reimbursement_date: '2025-12-15',
            purpose: 'Travel Expenses',
            status: 'pending',
            created_at: '2025-12-15T10:00:00Z',
        },
        {
            id: '2',
            emp_id: 'dsg002',
            emp_name: 'Jane Smith',
            amount: 45.50,
            reimbursement_date: '2025-12-18',
            purpose: 'Office Supplies',
            status: 'approved',
            created_at: '2025-12-18T14:30:00Z',
        }
    ]);

    /* 
    // Real implementation:
    const { data, error } = await supabase
      .from('reimbursements')
      .select('*')
      .order('created_at', { ascending: false });
  
    if (error) throw new Error(error.message);
    return data ?? [];
    */
}

/**
 * Create a reimbursement request
 */
export async function createReimbursement(reimbursement: ReimbursementInsert): Promise<Reimbursement> {
    // Mock logic
    return {
        id: Math.random().toString(36).substr(2, 9),
        ...reimbursement,
        status: 'pending',
        created_at: new Date().toISOString(),
    } as Reimbursement;
}

/**
 * Update a reimbursement status
 */
export async function updateReimbursementStatus(id: string, status: Reimbursement['status']): Promise<void> {
    console.log(`Updating reimbursement ${id} to ${status}`);
}
