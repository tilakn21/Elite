import { AuthState, AuthAction, initialAuthState } from './types';

/**
 * Auth Reducer
 * Pure reducer function for managing authentication state
 */
export function authReducer(state: AuthState, action: AuthAction): AuthState {
    switch (action.type) {
        case 'AUTH_INIT':
            return {
                ...state,
                isLoading: true,
                error: null,
            };

        case 'AUTH_INIT_COMPLETE':
            return {
                ...state,
                isLoading: false,
                isInitialized: true,
                user: action.payload,
                isAuthenticated: action.payload !== null,
            };

        case 'LOGIN_REQUEST':
            return {
                ...state,
                isLoading: true,
                error: null,
            };

        case 'LOGIN_SUCCESS':
            return {
                ...state,
                isLoading: false,
                isAuthenticated: true,
                user: action.payload,
                error: null,
            };

        case 'LOGIN_FAILURE':
            return {
                ...state,
                isLoading: false,
                isAuthenticated: false,
                user: null,
                error: action.payload,
            };

        case 'LOGOUT':
            return {
                ...initialAuthState,
                isInitialized: true,
            };

        case 'CLEAR_ERROR':
            return {
                ...state,
                error: null,
            };

        case 'UPDATE_USER':
            if (!state.user) return state;
            return {
                ...state,
                user: {
                    ...state.user,
                    ...action.payload,
                },
            };

        default:
            return state;
    }
}
