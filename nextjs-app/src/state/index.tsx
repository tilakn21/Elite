'use client';

import { type ReactNode } from 'react';
import { ThemeProvider } from '@emotion/react';
import { AuthProvider } from './auth';
import { UIProvider } from './ui';
import { theme, globalStyles } from '@/styles';

/**
 * App Provider
 * Combines all context providers in the correct order
 */
export function AppProvider({ children }: { children: ReactNode }) {
    return (
        <ThemeProvider theme={theme}>
            {globalStyles}
            <AuthProvider>
                <UIProvider>{children}</UIProvider>
            </AuthProvider>
        </ThemeProvider>
    );
}

// Re-export all state hooks and types
export { useAuth, useAuthState, useAuthDispatch } from './auth';
export { useUI, useUIState } from './ui';
export type { User, UserRole, AuthState } from './auth';
export type { Toast, ToastType, UIState } from './ui';
