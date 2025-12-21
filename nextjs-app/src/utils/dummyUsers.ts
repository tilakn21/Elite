/**
 * Dummy Users for Testing
 * Use these credentials to test login with different roles
 * 
 * Format: Employee ID / Password
 */

import { User, UserRole } from '@/state/auth/types';

export interface DummyUser {
    employeeId: string;
    password: string;
    user: User;
}

export const DUMMY_USERS: DummyUser[] = [
    // Admin
    {
        employeeId: 'adm001',
        password: 'admin123',
        user: {
            id: '1',
            employeeId: 'adm001',
            name: 'John Admin',
            email: 'admin@elite.com',
            role: 'admin' as UserRole,
            department: 'Administration',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
    // Receptionist
    {
        employeeId: 'rec001',
        password: 'recep123',
        user: {
            id: '2',
            employeeId: 'rec001',
            name: 'Sarah Receptionist',
            email: 'receptionist@elite.com',
            role: 'receptionist' as UserRole,
            department: 'Front Desk',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
    // Designer
    {
        employeeId: 'des001',
        password: 'design123',
        user: {
            id: '3',
            employeeId: 'des001',
            name: 'Mike Designer',
            email: 'designer@elite.com',
            role: 'design' as UserRole,
            department: 'Design',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
    // Production
    {
        employeeId: 'prod001',
        password: 'prod123',
        user: {
            id: '4',
            employeeId: 'prod001',
            name: 'Dave Production',
            email: 'production@elite.com',
            role: 'production' as UserRole,
            department: 'Production',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
    // Printing
    {
        employeeId: 'pri001',
        password: 'print123',
        user: {
            id: '5',
            employeeId: 'pri001',
            name: 'Lisa Printing',
            email: 'printing@elite.com',
            role: 'printing' as UserRole,
            department: 'Printing',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
    // Accounts
    {
        employeeId: 'acc001',
        password: 'acc123',
        user: {
            id: '6',
            employeeId: 'acc001',
            name: 'Emma Accounts',
            email: 'accounts@elite.com',
            role: 'accounts' as UserRole,
            department: 'Accounts',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
    // Salesperson
    {
        employeeId: 'sal001',
        password: 'sales123',
        user: {
            id: '7',
            employeeId: 'sal001',
            name: 'Tom Sales',
            email: 'sales@elite.com',
            role: 'salesperson' as UserRole,
            department: 'Sales',
            createdAt: '2024-01-01T00:00:00Z',
        },
    },
];

/**
 * Find dummy user by credentials
 */
export function findDummyUser(employeeId: string, password: string): User | null {
    const found = DUMMY_USERS.find(
        (u) =>
            u.employeeId.toLowerCase() === employeeId.toLowerCase() && u.password === password
    );
    return found ? found.user : null;
}

/**
 * Check if we should use dummy auth (development mode)
 */
export function useDummyAuth(): boolean {
    return process.env.NEXT_PUBLIC_USE_DUMMY_AUTH === 'true';
}

/*
 * ============================================
 * TEST CREDENTIALS - Copy/paste to login:
 * ============================================
 * 
 * Admin:        adm001 / admin123
 * Receptionist: rec001 / recep123
 * Designer:     des001 / design123
 * Production:   prod001 / prod123
 * Printing:     pri001 / print123
 * Accounts:     acc001 / acc123
 * Salesperson:  sal001 / sales123
 * 
 * ============================================
 */
