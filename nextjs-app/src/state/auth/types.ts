/**
 * Auth State Types
 * Defines the shape of authentication state and actions
 */

// User role types (matching Flutter ID prefixes)
export type UserRole =
    | 'admin'
    | 'receptionist'
    | 'salesperson'
    | 'design'
    | 'production'
    | 'printing'
    | 'accounts';

// User model
export interface User {
    id: string;
    employeeId: string;
    name: string;
    email: string;
    role: UserRole;
    avatar?: string;
    phone?: string;
    department?: string;
    createdAt: string;
}

// Auth state shape
export interface AuthState {
    user: User | null;
    isAuthenticated: boolean;
    isLoading: boolean;
    isInitialized: boolean;
    error: string | null;
}

// Auth action types
export type AuthAction =
    | { type: 'AUTH_INIT' }
    | { type: 'AUTH_INIT_COMPLETE'; payload: User | null }
    | { type: 'LOGIN_REQUEST' }
    | { type: 'LOGIN_SUCCESS'; payload: User }
    | { type: 'LOGIN_FAILURE'; payload: string }
    | { type: 'LOGOUT' }
    | { type: 'CLEAR_ERROR' }
    | { type: 'UPDATE_USER'; payload: Partial<User> };

// Initial auth state
export const initialAuthState: AuthState = {
    user: null,
    isAuthenticated: false,
    isLoading: false,
    isInitialized: false,
    error: null,
};

// Role to dashboard route mapping
export const roleDashboardMap: Record<UserRole, string> = {
    admin: '/admin',
    receptionist: '/receptionist',
    salesperson: '/salesperson',
    design: '/design',
    production: '/production',
    printing: '/printing',
    accounts: '/accounts',
};

// Employee ID prefix to role mapping
export function getRoleFromEmployeeId(employeeId: string): UserRole | null {
    const prefix = employeeId.toLowerCase();
    if (prefix.startsWith('adm')) return 'admin';
    if (prefix.startsWith('rec')) return 'receptionist';
    if (prefix.startsWith('sal')) return 'salesperson';
    if (prefix.startsWith('des')) return 'design';
    if (prefix.startsWith('prod')) return 'production';
    if (prefix.startsWith('pri')) return 'printing';
    if (prefix.startsWith('acc')) return 'accounts';
    return null;
}
