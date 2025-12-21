import { User } from '@/state/auth/types';

/**
 * Storage Utilities
 * SSR-safe localStorage helpers for persisting auth state
 */

const STORAGE_KEYS = {
    USER: 'elite_user',
    TOKEN: 'elite_token',
    THEME: 'elite_theme',
} as const;

/**
 * Check if we're running on the client
 */
function isClient(): boolean {
    return typeof window !== 'undefined';
}

/**
 * Safe localStorage getter
 */
function getItem(key: string): string | null {
    if (!isClient()) return null;
    try {
        return localStorage.getItem(key);
    } catch (error) {
        console.error(`Error reading from localStorage: ${key}`, error);
        return null;
    }
}

/**
 * Safe localStorage setter
 */
function setItem(key: string, value: string): void {
    if (!isClient()) return;
    try {
        localStorage.setItem(key, value);
    } catch (error) {
        console.error(`Error writing to localStorage: ${key}`, error);
    }
}

/**
 * Safe localStorage remover
 */
function removeItem(key: string): void {
    if (!isClient()) return;
    try {
        localStorage.removeItem(key);
    } catch (error) {
        console.error(`Error removing from localStorage: ${key}`, error);
    }
}

export const storage = {
    /**
     * Get stored user
     */
    getUser(): User | null {
        const data = getItem(STORAGE_KEYS.USER);
        if (!data) return null;
        try {
            return JSON.parse(data) as User;
        } catch {
            return null;
        }
    },

    /**
     * Store user
     */
    setUser(user: User): void {
        setItem(STORAGE_KEYS.USER, JSON.stringify(user));
    },

    /**
     * Clear stored user
     */
    clearUser(): void {
        removeItem(STORAGE_KEYS.USER);
        removeItem(STORAGE_KEYS.TOKEN);
    },

    /**
     * Get auth token
     */
    getToken(): string | null {
        return getItem(STORAGE_KEYS.TOKEN);
    },

    /**
     * Set auth token
     */
    setToken(token: string): void {
        setItem(STORAGE_KEYS.TOKEN, token);
    },

    /**
     * Remove auth token
     */
    removeToken(): void {
        removeItem(STORAGE_KEYS.TOKEN);
    },

    /**
     * Get theme preference
     */
    getTheme(): 'light' | 'dark' | null {
        const theme = getItem(STORAGE_KEYS.THEME);
        if (theme === 'light' || theme === 'dark') return theme;
        return null;
    },

    /**
     * Set theme preference
     */
    setTheme(theme: 'light' | 'dark'): void {
        setItem(STORAGE_KEYS.THEME, theme);
    },

    /**
     * Clear all app storage
     */
    clearAll(): void {
        Object.values(STORAGE_KEYS).forEach(removeItem);
    },
};

export default storage;
