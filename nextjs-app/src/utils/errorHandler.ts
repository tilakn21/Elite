/**
 * Error Handler Utilities
 * Centralized error handling for graceful degradation
 */

/**
 * Custom error class for application errors
 */
export class AppError extends Error {
    public readonly code: string;
    public readonly statusCode: number;
    public readonly isOperational: boolean;

    constructor(
        message: string,
        code: string = 'UNKNOWN_ERROR',
        statusCode: number = 500,
        isOperational: boolean = true
    ) {
        super(message);
        this.name = 'AppError';
        this.code = code;
        this.statusCode = statusCode;
        this.isOperational = isOperational;

        // Maintains proper stack trace for where error was thrown
        Error.captureStackTrace?.(this, this.constructor);
    }
}

/**
 * Error codes for common scenarios
 */
export const ErrorCodes = {
    NETWORK_ERROR: 'NETWORK_ERROR',
    AUTH_ERROR: 'AUTH_ERROR',
    NOT_FOUND: 'NOT_FOUND',
    VALIDATION_ERROR: 'VALIDATION_ERROR',
    DATABASE_ERROR: 'DATABASE_ERROR',
    UNKNOWN_ERROR: 'UNKNOWN_ERROR',
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];

/**
 * Result type for error-safe operations
 */
export type Result<T, E = Error> = { success: true; data: T } | { success: false; error: E };

/**
 * Wraps an async function to return a Result instead of throwing
 */
export async function safeAsync<T>(fn: () => Promise<T>): Promise<Result<T>> {
    try {
        const data = await fn();
        return { success: true, data };
    } catch (error) {
        console.error('safeAsync caught error:', error);
        return {
            success: false,
            error: error instanceof Error ? error : new Error(String(error)),
        };
    }
}

/**
 * Wraps an async function with a fallback value on error
 */
export async function withFallback<T>(fn: () => Promise<T>, fallback: T): Promise<T> {
    try {
        return await fn();
    } catch (error) {
        console.error('withFallback caught error, using fallback:', error);
        return fallback;
    }
}

/**
 * Handle service errors and return user-friendly messages
 */
export function handleServiceError(error: unknown): string {
    if (error instanceof AppError) {
        return error.message;
    }

    if (error instanceof Error) {
        // Check for common error patterns
        const message = error.message.toLowerCase();

        if (message.includes('network') || message.includes('fetch')) {
            return 'Unable to connect. Please check your internet connection.';
        }

        if (message.includes('unauthorized') || message.includes('authentication')) {
            return 'Your session has expired. Please log in again.';
        }

        if (message.includes('not found')) {
            return 'The requested resource was not found.';
        }

        if (message.includes('timeout')) {
            return 'The request timed out. Please try again.';
        }

        // For development, return the actual message
        if (process.env.NODE_ENV === 'development') {
            return error.message;
        }
    }

    return 'An unexpected error occurred. Please try again.';
}

/**
 * Log error to console (and potentially to external service)
 */
export function logError(error: unknown, context?: Record<string, unknown>): void {
    const timestamp = new Date().toISOString();
    const errorInfo = {
        timestamp,
        message: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
        context,
    };

    console.error('[Error]', errorInfo);

    // TODO: Send to error tracking service (Sentry, etc.)
}

/**
 * Check if error is a network error
 */
export function isNetworkError(error: unknown): boolean {
    if (error instanceof Error) {
        const message = error.message.toLowerCase();
        return (
            message.includes('network') ||
            message.includes('fetch') ||
            message.includes('failed to fetch') ||
            message.includes('networkerror')
        );
    }
    return false;
}

/**
 * Check if error is an authentication error
 */
export function isAuthError(error: unknown): boolean {
    if (error instanceof Error) {
        const message = error.message.toLowerCase();
        return message.includes('unauthorized') || message.includes('authentication') || message.includes('401');
    }
    return false;
}

/**
 * Retry an async function with exponential backoff
 */
export async function withRetry<T>(
    fn: () => Promise<T>,
    options: {
        maxRetries?: number;
        baseDelay?: number;
        maxDelay?: number;
        shouldRetry?: (error: unknown) => boolean;
    } = {}
): Promise<T> {
    const { maxRetries = 3, baseDelay = 1000, maxDelay = 10000, shouldRetry = isNetworkError } = options;

    let lastError: unknown;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
        try {
            return await fn();
        } catch (error) {
            lastError = error;

            if (attempt === maxRetries || !shouldRetry(error)) {
                throw error;
            }

            const delay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
            console.log(`Retry attempt ${attempt + 1}/${maxRetries} after ${delay}ms`);
            await new Promise((resolve) => setTimeout(resolve, delay));
        }
    }

    throw lastError;
}

/**
 * Setup global error handlers
 */
export function setupGlobalErrorHandlers(): void {
    if (typeof window === 'undefined') return;

    // Handle unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
        console.error('Unhandled Promise Rejection:', event.reason);
        logError(event.reason, { type: 'unhandledrejection' });
        // Prevent the default browser behavior
        event.preventDefault();
    });

    // Handle global errors
    window.addEventListener('error', (event) => {
        console.error('Global Error:', event.error || event.message);
        logError(event.error || event.message, { type: 'error', filename: event.filename, lineno: event.lineno });
    });
}

export default {
    AppError,
    ErrorCodes,
    safeAsync,
    withFallback,
    handleServiceError,
    logError,
    isNetworkError,
    isAuthError,
    withRetry,
    setupGlobalErrorHandlers,
};
