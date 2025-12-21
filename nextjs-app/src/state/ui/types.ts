/**
 * UI State Types
 * Manages global UI state: modals, toasts, sidebar, loading states
 */

// Toast notification types
export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
    id: string;
    type: ToastType;
    message: string;
    duration?: number;
}

// Modal types
export interface ModalState {
    isOpen: boolean;
    component: string | null;
    props?: Record<string, unknown>;
}

// UI State shape
export interface UIState {
    // Sidebar
    isSidebarOpen: boolean;
    isSidebarCollapsed: boolean;

    // Mobile nav
    isMobileNavOpen: boolean;

    // Modals
    modal: ModalState;

    // Toasts
    toasts: Toast[];

    // Global loading
    isGlobalLoading: boolean;
    loadingMessage: string | null;

    // Search
    searchQuery: string;
}

// UI Action types
export type UIAction =
    // Sidebar actions
    | { type: 'TOGGLE_SIDEBAR' }
    | { type: 'SET_SIDEBAR_OPEN'; payload: boolean }
    | { type: 'TOGGLE_SIDEBAR_COLLAPSED' }
    | { type: 'SET_SIDEBAR_COLLAPSED'; payload: boolean }
    // Mobile nav actions
    | { type: 'TOGGLE_MOBILE_NAV' }
    | { type: 'SET_MOBILE_NAV_OPEN'; payload: boolean }
    // Modal actions
    | { type: 'OPEN_MODAL'; payload: { component: string; props?: Record<string, unknown> } }
    | { type: 'CLOSE_MODAL' }
    // Toast actions
    | { type: 'ADD_TOAST'; payload: Omit<Toast, 'id'> }
    | { type: 'REMOVE_TOAST'; payload: string }
    | { type: 'CLEAR_TOASTS' }
    // Loading actions
    | { type: 'SET_GLOBAL_LOADING'; payload: { isLoading: boolean; message?: string } }
    // Search actions
    | { type: 'SET_SEARCH_QUERY'; payload: string };

// Initial UI state
export const initialUIState: UIState = {
    isSidebarOpen: true,
    isSidebarCollapsed: false,
    isMobileNavOpen: false,
    modal: {
        isOpen: false,
        component: null,
        props: undefined,
    },
    toasts: [],
    isGlobalLoading: false,
    loadingMessage: null,
    searchQuery: '',
};
