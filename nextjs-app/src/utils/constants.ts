/**
 * App Constants
 * Centralized configuration values
 */

// API Configuration
export const API_CONFIG = {
    BASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL || '',
    TIMEOUT: 30000,
} as const;

// Route paths
export const ROUTES = {
    // Auth
    LOGIN: '/login',

    // Admin
    ADMIN_DASHBOARD: '/admin',
    ADMIN_EMPLOYEES: '/admin/employees',
    ADMIN_JOBS: '/admin/jobs',
    ADMIN_CALENDAR: '/admin/calendar',
    ADMIN_REIMBURSEMENTS: '/admin/reimbursements',

    // Receptionist
    RECEPTIONIST_DASHBOARD: '/receptionist',
    RECEPTIONIST_NEW_JOB: '/receptionist/new-job',
    RECEPTIONIST_ASSIGN_SALESPERSON: '/receptionist/assign-salesperson',
    RECEPTIONIST_JOBS: '/receptionist/jobs',
    RECEPTIONIST_CALENDAR: '/receptionist/calendar',

    // Design
    DESIGN_DASHBOARD: '/design',
    DESIGN_JOBS: '/design/jobs',
    DESIGN_CHATS: '/design/chats',
    DESIGN_CALENDAR: '/design/calendar',

    // Production
    PRODUCTION_DASHBOARD: '/production',
    PRODUCTION_JOBS: '/production/jobs',
    PRODUCTION_ASSIGN_LABOUR: '/production/assign-labour',
    PRODUCTION_CALENDAR: '/production/calendar',

    // Printing
    PRINTING_DASHBOARD: '/printing',
    PRINTING_JOBS: '/printing/jobs',

    // Accounts
    ACCOUNTS_DASHBOARD: '/accounts',
    ACCOUNTS_JOBS: '/accounts/jobs',
    ACCOUNTS_INVOICES: '/accounts/invoices',
    ACCOUNTS_PAYMENTS: '/accounts/payments',
    ACCOUNTS_REIMBURSEMENTS: '/accounts/reimbursements',
    ACCOUNTS_EMPLOYEES: '/admin/employees',

    // Salesperson
    SALESPERSON_DASHBOARD: '/salesperson',
    SALESPERSON_PROFILE: '/salesperson/profile',
    SALESPERSON_REIMBURSEMENT: '/salesperson/reimbursement',
    SALESPERSON_CALENDAR: '/salesperson/calendar',
} as const;

// Job status values (matching Flutter)
export const JOB_STATUS = {
    QUEUED: 'queued',
    IN_PROGRESS: 'inProgress',
    PENDING: 'pending',
    PENDING_APPROVAL: 'pendingApproval',
    APPROVED: 'approved',
    DESIGN_COMPLETED: 'designCompleted',
    COMPLETED: 'completed',
} as const;

// Reimbursement status values
export const REIMBURSEMENT_STATUS = {
    PENDING: 'pending',
    APPROVED: 'approved',
    REJECTED: 'rejected',
} as const;

// Date/time formats
export const DATE_FORMATS = {
    DISPLAY: 'MMM dd, yyyy',
    DISPLAY_WITH_TIME: 'MMM dd, yyyy HH:mm',
    ISO: 'yyyy-MM-dd',
    TIME: 'HH:mm',
} as const;

// Pagination defaults
export const PAGINATION = {
    DEFAULT_PAGE_SIZE: 10,
    PAGE_SIZE_OPTIONS: [10, 25, 50, 100],
} as const;

// File upload limits
export const FILE_LIMITS = {
    MAX_SIZE_MB: 10,
    MAX_FILES: 10,
    ALLOWED_IMAGE_TYPES: ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'],
    ALLOWED_DOCUMENT_TYPES: ['application/pdf'],
} as const;
