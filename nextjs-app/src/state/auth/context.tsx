'use client';

import {
    createContext,
    useContext,
    useReducer,
    useCallback,
    useEffect,
    type ReactNode,
    type Dispatch,
} from 'react';
import { authReducer } from './reducer';
import {
    AuthState,
    AuthAction,
    User,
    initialAuthState,
    roleDashboardMap,
    getRoleFromEmployeeId,
} from './types';
import { authService } from '@/services/auth.service';
import { storage } from '@/utils/storage';

// Context types
interface AuthContextValue {
    state: AuthState;
    dispatch: Dispatch<AuthAction>;
    login: (employeeId: string, password: string) => Promise<User>;
    logout: () => Promise<void>;
    getDashboardRoute: () => string;
}

// Create contexts
const AuthStateContext = createContext<AuthState | null>(null);
const AuthDispatchContext = createContext<Dispatch<AuthAction> | null>(null);
const AuthActionsContext = createContext<AuthContextValue | null>(null);

/**
 * Auth Provider
 * Wraps the app and provides authentication state and actions
 */
export function AuthProvider({ children }: { children: ReactNode }) {
    const [state, dispatch] = useReducer(authReducer, initialAuthState);

    // Initialize auth state from storage on mount
    useEffect(() => {
        const initAuth = async () => {
            dispatch({ type: 'AUTH_INIT' });

            try {
                const storedUser = storage.getUser();
                dispatch({ type: 'AUTH_INIT_COMPLETE', payload: storedUser });
            } catch (error) {
                console.error('Failed to initialize auth:', error);
                dispatch({ type: 'AUTH_INIT_COMPLETE', payload: null });
            }
        };

        initAuth();
    }, []);

    // Login action
    const login = useCallback(async (employeeId: string, password: string): Promise<User> => {
        dispatch({ type: 'LOGIN_REQUEST' });

        try {
            const user = await authService.login(employeeId, password);
            storage.setUser(user);
            dispatch({ type: 'LOGIN_SUCCESS', payload: user });
            return user;
        } catch (error) {
            const message = error instanceof Error ? error.message : 'Login failed';
            dispatch({ type: 'LOGIN_FAILURE', payload: message });
            throw error;
        }
    }, []);

    // Logout action
    const logout = useCallback(async () => {
        try {
            await authService.logout();
        } catch (error) {
            console.error('Logout error:', error);
        } finally {
            storage.clearUser();
            dispatch({ type: 'LOGOUT' });
        }
    }, []);

    // Get dashboard route for current user
    const getDashboardRoute = useCallback((): string => {
        if (!state.user) return '/login';
        return roleDashboardMap[state.user.role] || '/login';
    }, [state.user]);

    const value: AuthContextValue = {
        state,
        dispatch,
        login,
        logout,
        getDashboardRoute,
    };

    return (
        <AuthActionsContext.Provider value={value}>
            <AuthStateContext.Provider value={state}>
                <AuthDispatchContext.Provider value={dispatch}>{children}</AuthDispatchContext.Provider>
            </AuthStateContext.Provider>
        </AuthActionsContext.Provider>
    );
}

/**
 * Hook to access auth state
 */
export function useAuthState(): AuthState {
    const context = useContext(AuthStateContext);
    if (context === null) {
        throw new Error('useAuthState must be used within an AuthProvider');
    }
    return context;
}

/**
 * Hook to access auth dispatch
 */
export function useAuthDispatch(): Dispatch<AuthAction> {
    const context = useContext(AuthDispatchContext);
    if (context === null) {
        throw new Error('useAuthDispatch must be used within an AuthProvider');
    }
    return context;
}

/**
 * Hook to access all auth actions and state
 */
export function useAuth(): AuthContextValue {
    const context = useContext(AuthActionsContext);
    if (context === null) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}

// Re-export types and utilities
export { getRoleFromEmployeeId, roleDashboardMap };
export type { User, UserRole, AuthState } from './types';
