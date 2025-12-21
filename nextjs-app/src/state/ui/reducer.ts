import { UIState, UIAction } from './types';

/**
 * UI Reducer
 * Pure reducer function for managing UI state
 */
export function uiReducer(state: UIState, action: UIAction): UIState {
    switch (action.type) {
        // Sidebar actions
        case 'TOGGLE_SIDEBAR':
            return {
                ...state,
                isSidebarOpen: !state.isSidebarOpen,
            };

        case 'SET_SIDEBAR_OPEN':
            return {
                ...state,
                isSidebarOpen: action.payload,
            };

        case 'TOGGLE_SIDEBAR_COLLAPSED':
            return {
                ...state,
                isSidebarCollapsed: !state.isSidebarCollapsed,
            };

        case 'SET_SIDEBAR_COLLAPSED':
            return {
                ...state,
                isSidebarCollapsed: action.payload,
            };

        // Mobile nav actions
        case 'TOGGLE_MOBILE_NAV':
            return {
                ...state,
                isMobileNavOpen: !state.isMobileNavOpen,
            };

        case 'SET_MOBILE_NAV_OPEN':
            return {
                ...state,
                isMobileNavOpen: action.payload,
            };

        // Modal actions
        case 'OPEN_MODAL':
            return {
                ...state,
                modal: {
                    isOpen: true,
                    component: action.payload.component,
                    props: action.payload.props,
                },
            };

        case 'CLOSE_MODAL':
            return {
                ...state,
                modal: {
                    isOpen: false,
                    component: null,
                    props: undefined,
                },
            };

        // Toast actions
        case 'ADD_TOAST':
            return {
                ...state,
                toasts: [
                    ...state.toasts,
                    {
                        ...action.payload,
                        id: `toast-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
                    },
                ],
            };

        case 'REMOVE_TOAST':
            return {
                ...state,
                toasts: state.toasts.filter((toast) => toast.id !== action.payload),
            };

        case 'CLEAR_TOASTS':
            return {
                ...state,
                toasts: [],
            };

        // Loading actions
        case 'SET_GLOBAL_LOADING':
            return {
                ...state,
                isGlobalLoading: action.payload.isLoading,
                loadingMessage: action.payload.message ?? null,
            };

        // Search actions
        case 'SET_SEARCH_QUERY':
            return {
                ...state,
                searchQuery: action.payload,
            };

        default:
            return state;
    }
}
