/**
 * Employees Service
 * Handles all employee-related data operations
 */

import { supabase } from './supabase';
import type { Employee, EmployeeInsert, EmployeeUpdate, Branch } from '@/types';

/**
 * Fetch all employees from Supabase
 */
export async function getEmployees(): Promise<Employee[]> {
    const { data, error } = await supabase
        .from('employee')
        .select('id, full_name, phone, email, role, branch_id, created_at, is_available, assigned_job')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Error fetching employees:', error);
        throw new Error(`Failed to load employees: ${error.message}`);
    }

    return data ?? [];
}

/**
 * Fetch a single employee by ID
 */
export async function getEmployeeById(id: string): Promise<Employee | null> {
    const { data, error } = await supabase
        .from('employee')
        .select('*')
        .eq('id', id)
        .single();

    if (error) {
        if (error.code === 'PGRST116') {
            return null; // Not found
        }
        console.error('Error fetching employee:', error);
        throw new Error(`Failed to load employee: ${error.message}`);
    }

    return data;
}

/**
 * Fetch employees by role
 */
export async function getEmployeesByRole(role: string): Promise<Employee[]> {
    const { data, error } = await supabase
        .from('employee')
        .select('*')
        .ilike('role', `%${role}%`)
        .order('full_name');

    if (error) {
        console.error('Error fetching employees by role:', error);
        throw new Error(`Failed to load employees: ${error.message}`);
    }

    return data ?? [];
}

/**
 * Fetch employees by branch
 */
export async function getEmployeesByBranch(branchId: number): Promise<Employee[]> {
    const { data, error } = await supabase
        .from('employee')
        .select('*')
        .eq('branch_id', branchId)
        .order('full_name');

    if (error) {
        console.error('Error fetching employees by branch:', error);
        throw new Error(`Failed to load employees: ${error.message}`);
    }

    return data ?? [];
}

/**
 * Create a new employee
 * Generates ID based on role prefix + sequential number
 */
export async function createEmployee(employee: EmployeeInsert): Promise<Employee> {
    // Generate role-based ID
    const rolePrefix = employee.role.trim().toLowerCase().substring(0, 3);

    // Get the latest employee with this role prefix
    const { data: latest } = await supabase
        .from('employee')
        .select('id')
        .ilike('id', `${rolePrefix}%`)
        .order('id', { ascending: false })
        .limit(1);

    let nextNumber = 1001;
    if (latest && latest.length > 0 && latest[0]) {
        const lastId = latest[0].id;
        const match = lastId.match(/[a-zA-Z]+(\d+)/);
        if (match && match[1]) {
            nextNumber = parseInt(match[1], 10) + 1;
        }
    }

    const newId = `${rolePrefix}${nextNumber}`;

    const { data, error } = await supabase
        .from('employee')
        .insert({
            id: newId,
            full_name: employee.full_name,
            phone: employee.phone ?? null,
            email: employee.email ?? null,
            role: employee.role,
            branch_id: employee.branch_id ?? null,
            is_available: employee.is_available ?? true,
            assigned_job: employee.assigned_job ?? null,
        })
        .select()
        .single();

    if (error) {
        console.error('Error creating employee:', error);
        throw new Error(`Failed to create employee: ${error.message}`);
    }

    return data;
}

/**
 * Update an existing employee
 */
export async function updateEmployee(id: string, updates: EmployeeUpdate): Promise<Employee> {
    const { data, error } = await supabase
        .from('employee')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    if (error) {
        console.error('Error updating employee:', error);
        throw new Error(`Failed to update employee: ${error.message}`);
    }

    return data;
}

/**
 * Delete an employee
 */
export async function deleteEmployee(id: string): Promise<void> {
    const { error } = await supabase
        .from('employee')
        .delete()
        .eq('id', id);

    if (error) {
        console.error('Error deleting employee:', error);
        throw new Error(`Failed to delete employee: ${error.message}`);
    }
}

/**
 * Get unique roles from employees
 */
export async function getEmployeeRoles(): Promise<string[]> {
    const { data, error } = await supabase
        .from('employee')
        .select('role')
        .not('role', 'is', null);

    if (error) {
        console.error('Error fetching roles:', error);
        // Return default roles on error
        return [
            'admin', 'receptionist', 'salesperson', 'designer',
            'accountant', 'production_manager', 'printing_manager',
            'prod_labour', 'print_labour', 'driver'
        ];
    }

    const roles = [...new Set(data?.map(e => e.role as string).filter(Boolean) ?? [])];

    // Add default roles if not present
    const defaultRoles = [
        'admin', 'receptionist', 'salesperson', 'designer',
        'accountant', 'production_manager', 'printing_manager',
        'prod_labour', 'print_labour', 'driver'
    ];

    for (const role of defaultRoles) {
        if (!roles.includes(role)) {
            roles.push(role);
        }
    }

    return roles.sort();
}

/**
 * Fetch all branches
 */
export async function getBranches(): Promise<Branch[]> {
    const { data, error } = await supabase
        .from('branches')
        .select('id, name, location, contact_no')
        .order('name');

    if (error) {
        console.error('Error fetching branches:', error);
        throw new Error(`Failed to load branches: ${error.message}`);
    }

    return data ?? [];
}

/**
 * Get employee count by role
 */
export async function getEmployeeCountByRole(): Promise<Record<string, number>> {
    const { data, error } = await supabase
        .from('employee')
        .select('role');

    if (error) {
        console.error('Error counting employees:', error);
        return {};
    }

    const counts: Record<string, number> = {};
    data?.forEach(e => {
        const role = e.role as string;
        if (role) {
            counts[role] = (counts[role] ?? 0) + 1;
        }
    });

    return counts;
}

/**
 * Generate a temporary password
 * Format: 3 letters + 4 numbers (e.g., 'abc1234')
 */
export function generateTemporaryPassword(): string {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';

    let password = '';
    for (let i = 0; i < 3; i++) {
        password += letters.charAt(Math.floor(Math.random() * letters.length));
    }
    for (let i = 0; i < 4; i++) {
        password += numbers.charAt(Math.floor(Math.random() * numbers.length));
    }

    return password;
}

/**
 * Update employee password
 * Note: Password is stored as-is in the database (matching current Flutter app behavior)
 * For production, consider adding server-side hashing
 */
export async function updateEmployeePassword(id: string, newPassword: string): Promise<boolean> {
    const { error } = await supabase
        .from('employee')
        .update({ password: newPassword })
        .eq('id', id);

    if (error) {
        console.error('Error updating password:', error);
        throw new Error(`Failed to update password: ${error.message}`);
    }

    return true;
}

/**
 * Reset employee password to a temporary one
 * Returns the new temporary password
 */
export async function resetEmployeePassword(id: string): Promise<string> {
    const newPassword = generateTemporaryPassword();
    await updateEmployeePassword(id, newPassword);
    return newPassword;
}

/**
 * Create employee with password (for new employees)
 */
export async function createEmployeeWithPassword(
    employee: EmployeeInsert,
    password?: string
): Promise<{ employee: Employee; password: string }> {
    const finalPassword = password || generateTemporaryPassword();

    // Generate role-based ID
    const rolePrefix = employee.role.trim().toLowerCase().substring(0, 3);

    // Get the latest employee with this role prefix
    const { data: latest } = await supabase
        .from('employee')
        .select('id')
        .ilike('id', `${rolePrefix}%`)
        .order('id', { ascending: false })
        .limit(1);

    let nextNumber = 1001;
    if (latest && latest.length > 0 && latest[0]) {
        const lastId = latest[0].id;
        const match = lastId.match(/[a-zA-Z]+(\d+)/);
        if (match && match[1]) {
            nextNumber = parseInt(match[1], 10) + 1;
        }
    }

    const newId = `${rolePrefix}${nextNumber}`;

    const { data, error } = await supabase
        .from('employee')
        .insert({
            id: newId,
            full_name: employee.full_name,
            phone: employee.phone ?? null,
            email: employee.email ?? null,
            role: employee.role,
            branch_id: employee.branch_id ?? null,
            is_available: employee.is_available ?? true,
            assigned_job: employee.assigned_job ?? null,
            password: finalPassword,
        })
        .select()
        .single();

    if (error) {
        console.error('Error creating employee:', error);
        throw new Error(`Failed to create employee: ${error.message}`);
    }

    return { employee: data, password: finalPassword };
}
