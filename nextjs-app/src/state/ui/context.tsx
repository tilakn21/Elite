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
import { uiReducer } from './reducer';
import { UIState, UIAction, initialUIState, ToastType } from './types';

// Context types
interface UIContextValue {
    state: UIState;
    dispatch: Dispatch<UIAction>;
    // Sidebar actions
    toggleSidebar: () => void;
    setSidebarOpen: (isOpen: boolean) => void;
    toggleSidebarCollapsed: () => void;
    // Mobile nav actions
    toggleMobileNav: () => void;
    closeMobileNav: () => void;
    // Modal actions
    openModal: (component: string, props?: Record<string, unknown>) => void;
    closeModal: () => void;
    // Toast actions
    showToast: (type: ToastType, message: string, duration?: number) => void;
    removeToast: (id: string) => void;
    // Loading actions
    setGlobalLoading: (isLoading: boolean, message?: string) => void;
    // Search actions
    setSearchQuery: (query: string) => void;
}

// Create contexts
const UIStateContext = createContext<UIState | null>(null);
const UIActionsContext = createContext<UIContextValue | null>(null);

/**
 * UI Provider
 * Manages global UI state including responsive sidebar behavior
 */
export function UIProvider({ children }: { children: ReactNode }) {
    const [state, dispatch] = useReducer(uiReducer, initialUIState);

    // Auto-remove toasts after duration
    useEffect(() => {
        const timers: NodeJS.Timeout[] = [];

        state.toasts.forEach((toast) => {
            const duration = toast.duration ?? 5000;
            const timer = setTimeout(() => {
                dispatch({ type: 'REMOVE_TOAST', payload: toast.id });
            }, duration);
            timers.push(timer);
        });

        return () => {
            timers.forEach(clearTimeout);
        };
    }, [state.toasts]);

    // Sidebar actions
    const toggleSidebar = useCallback(() => {
        dispatch({ type: 'TOGGLE_SIDEBAR' });
    }, []);

    const setSidebarOpen = useCallback((isOpen: boolean) => {
        dispatch({ type: 'SET_SIDEBAR_OPEN', payload: isOpen });
    }, []);

    const toggleSidebarCollapsed = useCallback(() => {
        dispatch({ type: 'TOGGLE_SIDEBAR_COLLAPSED' });
    }, []);

    // Mobile nav actions
    const toggleMobileNav = useCallback(() => {
        dispatch({ type: 'TOGGLE_MOBILE_NAV' });
    }, []);

    const closeMobileNav = useCallback(() => {
        dispatch({ type: 'SET_MOBILE_NAV_OPEN', payload: false });
    }, []);

    // Modal actions
    const openModal = useCallback((component: string, props?: Record<string, unknown>) => {
        dispatch({ type: 'OPEN_MODAL', payload: { component, props } });
    }, []);

    const closeModal = useCallback(() => {
        dispatch({ type: 'CLOSE_MODAL' });
    }, []);

    // Toast actions
    const showToast = useCallback((type: ToastType, message: string, duration?: number) => {
        dispatch({ type: 'ADD_TOAST', payload: { type, message, duration } });
    }, []);

    const removeToast = useCallback((id: string) => {
        dispatch({ type: 'REMOVE_TOAST', payload: id });
    }, []);

    // Loading actions
    const setGlobalLoading = useCallback((isLoading: boolean, message?: string) => {
        dispatch({ type: 'SET_GLOBAL_LOADING', payload: { isLoading, message } });
    }, []);

    // Search actions
    const setSearchQuery = useCallback((query: string) => {
        dispatch({ type: 'SET_SEARCH_QUERY', payload: query });
    }, []);

    const value: UIContextValue = {
        state,
        dispatch,
        toggleSidebar,
        setSidebarOpen,
        toggleSidebarCollapsed,
        toggleMobileNav,
        closeMobileNav,
        openModal,
        closeModal,
        showToast,
        removeToast,
        setGlobalLoading,
        setSearchQuery,
    };

    return (
        <UIActionsContext.Provider value={value}>
            <UIStateContext.Provider value={state}>{children}</UIStateContext.Provider>
        </UIActionsContext.Provider>
    );
}

/**
 * Hook to access UI state
 */
export function useUIState(): UIState {
    const context = useContext(UIStateContext);
    if (context === null) {
        throw new Error('useUIState must be used within a UIProvider');
    }
    return context;
}

/**
 * Hook to access all UI actions and state
 */
export function useUI(): UIContextValue {
    const context = useContext(UIActionsContext);
    if (context === null) {
        throw new Error('useUI must be used within a UIProvider');
    }
    return context;
}

// Re-export types
export type { Toast, ToastType } from './types';
