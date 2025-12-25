/**
 * Job Workflow Types
 * Status transition rules and payment preconditions
 */

import type { JobStatus, PaymentStatus } from './database';

// Status transition rules - defines valid next statuses for each status
export const STATUS_TRANSITIONS: Record<JobStatus, JobStatus[]> = {
    received: ['salesperson_assigned'],
    salesperson_assigned: ['site_visited'],
    site_visited: ['design_started'],
    design_started: ['design_in_review'],
    design_in_review: ['design_approved', 'design_started'], // can go back for changes
    design_approved: ['production_started'],
    production_started: ['printing_queued'],
    printing_queued: ['printing_started'],
    printing_started: ['printing_completed'],
    printing_completed: ['framing_started'],
    framing_started: ['production_completed'],
    production_completed: ['out_for_delivery'],
    out_for_delivery: [] // terminal state
};

// Payment preconditions for status transitions
// These statuses require specific payment states before transitioning
export const PAYMENT_PRECONDITIONS: Partial<Record<JobStatus, PaymentStatus[]>> = {
    production_started: ['partially_paid', 'payment_done'], // Can't start production without some payment
    out_for_delivery: ['payment_done'] // Must be fully paid before delivery
};

// Status labels for UI display
export const STATUS_LABELS: Record<JobStatus, string> = {
    received: 'Received',
    salesperson_assigned: 'Salesperson Assigned',
    site_visited: 'Site Visited',
    design_started: 'Design Started',
    design_in_review: 'Design In Review',
    design_approved: 'Design Approved',
    production_started: 'Production Started',
    printing_queued: 'At Printing', // "At Printing" for clearer understanding
    printing_started: 'Printing Started',
    printing_completed: 'Printing Completed',
    framing_started: 'Framing / Assembly',
    production_completed: 'Production Completed',
    out_for_delivery: 'Out for Delivery'
};

// Payment status labels for UI display
export const PAYMENT_STATUS_LABELS: Record<PaymentStatus, string> = {
    payment_pending: 'Payment Pending',
    partially_paid: 'Partially Paid',
    payment_done: 'Paid in Full'
};

// Status colors for UI (badge variants)
export const STATUS_COLORS: Record<JobStatus, 'warning' | 'info' | 'success' | 'error' | 'default'> = {
    received: 'warning',
    salesperson_assigned: 'info',
    site_visited: 'info',
    design_started: 'info',
    design_in_review: 'warning',
    design_approved: 'success',
    production_started: 'info',
    printing_queued: 'warning',
    printing_started: 'info',
    printing_completed: 'success',
    framing_started: 'info',
    production_completed: 'success',
    out_for_delivery: 'success'
};

// Payment status colors for UI
export const PAYMENT_STATUS_COLORS: Record<PaymentStatus, 'warning' | 'info' | 'success' | 'error'> = {
    payment_pending: 'error',
    partially_paid: 'warning',
    payment_done: 'success'
};

// Role-based status filters - which statuses each role can see/manage
export const ROLE_STATUS_FILTERS: Record<string, JobStatus[]> = {
    receptionist: ['received', 'salesperson_assigned'],
    salesperson: ['salesperson_assigned', 'site_visited'],
    designer: ['design_started', 'design_in_review'],
    production: ['design_approved', 'production_started', 'printing_queued', 'printing_started', 'printing_completed', 'framing_started', 'production_completed'],
    printing: ['printing_queued', 'printing_started', 'printing_completed'],
    accounts: ['received', 'salesperson_assigned', 'site_visited', 'design_started',
        'design_in_review', 'design_approved', 'production_started', 'printing_queued',
        'printing_started', 'printing_completed', 'framing_started', 'production_completed', 'out_for_delivery'],
    admin: ['received', 'salesperson_assigned', 'site_visited', 'design_started',
        'design_in_review', 'design_approved', 'production_started', 'printing_queued',
        'printing_started', 'printing_completed', 'framing_started', 'production_completed', 'out_for_delivery']
};

// Helper type for workflow validation results
export interface WorkflowValidation {
    allowed: boolean;
    reason?: string;
    requiredPaymentStatus?: PaymentStatus[];
}
