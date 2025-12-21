import { supabase } from './supabase';
import { User, UserRole, getRoleFromEmployeeId } from '@/state/auth/types';
import { findDummyUser } from '@/utils/dummyUsers';

/**
 * Auth Service
 * Handles authentication operations with Supabase
 * Supports dummy users for testing (always enabled for development)
 */

// Actual database schema from Supabase
interface EmployeeRow {
    id: string;           // This is the employee ID (e.g., 'sal1003')
    full_name: string;    // Employee name
    email: string | null;
    password: string;     // SHA-256 hashed password
    role: string;
    phone: string | null;
    branch_id: number | null;
    created_at: string;
    is_available: boolean;
    assigned_job: string | null;
}

/**
 * Map database employee row to User model
 */
function mapEmployeeToUser(employee: EmployeeRow): User {
    // Determine role from employee ID prefix (matching Flutter logic)
    const role = getRoleFromEmployeeId(employee.id) || (employee.role.toLowerCase() as UserRole);

    return {
        id: employee.id,
        employeeId: employee.id,           // id field contains the employee ID
        name: employee.full_name,          // full_name field contains the name
        email: employee.email || '',
        role: role,
        avatar: undefined,                 // No avatar_url in current schema
        phone: employee.phone || undefined,
        department: undefined,             // No department in current schema
        createdAt: employee.created_at,
    };
}

export const authService = {
    /**
     * Login with employee ID and password
     * First checks dummy users (for testing), then falls back to Supabase
     */
    async login(employeeId: string, password: string): Promise<User> {
        if (!employeeId.trim() || !password.trim()) {
            throw new Error('Please enter both Employee ID and Password.');
        }

        // Try dummy users first (for testing)
        const dummyUser = findDummyUser(employeeId, password);
        if (dummyUser) {
            console.log('Using dummy user for testing:', dummyUser.employeeId);
            return dummyUser;
        }

        // Query Supabase with password directly
        console.log('Attempting login for:', employeeId);

        // Query Supabase
        const { data, error } = await supabase
            .from('employee')
            .select('*')
            .eq('id', employeeId.trim())          // 'id' field contains employee ID
            .eq('password', password)             // Send password directly
            .single();

        if (error) {
            console.error('Login error:', error);
            throw new Error('Invalid Employee ID or Password.');
        }

        if (!data) {
            throw new Error('Invalid Employee ID or Password.');
        }

        // Validate that the employee ID has a known role prefix
        const role = getRoleFromEmployeeId(employeeId);
        if (!role) {
            throw new Error('Unknown role for this Employee ID.');
        }

        return mapEmployeeToUser(data as EmployeeRow);
    },

    /**
     * Logout the current user
     */
    async logout(): Promise<void> {
        // Clear any Supabase session if using Supabase Auth
        const { error } = await supabase.auth.signOut();
        if (error) {
            console.error('Logout error:', error);
        }
    },

    /**
     * Get current session (if using Supabase Auth)
     */
    async getSession() {
        const {
            data: { session },
        } = await supabase.auth.getSession();
        return session;
    },

    /**
     * Get user by employee ID
     */
    async getUserByEmployeeId(employeeId: string): Promise<User | null> {
        const { data, error } = await supabase
            .from('employee')
            .select('*')
            .eq('id', employeeId)    // 'id' field contains employee ID
            .single();

        if (error || !data) {
            return null;
        }

        return mapEmployeeToUser(data as EmployeeRow);
    },
};

export default authService;
