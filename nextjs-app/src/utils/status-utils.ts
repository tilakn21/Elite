/**
 * Status Utilities
 * Helpers for job status display, colors, and department mapping
 */

import type { JobStatus } from '@/types';

/**
 * All workflow statuses in order
 */
export const WORKFLOW_STATUSES: JobStatus[] = [
    'received',
    'salesperson_assigned',
    'site_visited',
    'design_started',
    'design_in_review',
    'design_approved',
    'production_started',
    'printing_queued',
    'printing_started',
    'printing_completed',
    'framing_started',
    'production_completed',
    'out_for_delivery',
];

/**
 * Status to human-readable label mapping
 */
export function getStatusLabel(status: string): string {
    const labels: Record<string, string> = {
        received: 'Received',
        salesperson_assigned: 'Salesperson Assigned',
        site_visited: 'Site Visited',
        design_started: 'Design Started',
        design_in_review: 'Design In Review',
        design_approved: 'Design Approved',
        production_started: 'Production Started',
        printing_queued: 'At Printing',
        printing_started: 'Printing Started',
        printing_completed: 'Printing Completed',
        framing_started: 'Framing / Assembly',
        production_completed: 'Production Completed',
        out_for_delivery: 'Out for Delivery',
        // Legacy status support
        pending: 'Pending',
        in_progress: 'In Progress',
        completed: 'Completed',
        cancelled: 'Cancelled',
    };
    return labels[status?.toLowerCase()] || status || 'Unknown';
}

/**
 * Status to color mapping for badges
 */
export function getStatusColor(status: string): string {
    const s = status?.toLowerCase() || '';

    // Reception stage
    if (s === 'received') return '#9333ea'; // Purple

    // Sales stages
    if (s === 'salesperson_assigned' || s === 'site_visited') return '#2563eb'; // Blue

    // Design stages
    if (s === 'design_started' || s === 'design_in_review' || s === 'design_approved') return '#db2777'; // Pink

    // Production stages
    if (s === 'production_started' || s === 'production_completed' || s === 'framing_started') return '#4f46e5'; // Indigo
    if (s === 'printing_queued') return '#f59e0b'; // Amber (Waiting)

    // Printing stages
    if (s === 'printing_started' || s === 'printing_completed') return '#0d9488'; // Teal

    // Delivery
    if (s === 'out_for_delivery') return '#10b981'; // Green

    // Legacy statuses
    if (s === 'completed' || s === 'done') return '#10b981'; // Green
    if (s === 'pending') return '#f59e0b'; // Amber
    if (s === 'cancelled') return '#ef4444'; // Red

    return '#6b7280'; // Gray default
}

/**
 * Get current department based on status
 */
export function getCurrentDepartment(status: string): string {
    const s = status?.toLowerCase() || '';

    if (s === 'received') return 'Reception';
    if (s === 'salesperson_assigned' || s === 'site_visited') return 'Sales';
    if (s === 'design_started' || s === 'design_in_review' || s === 'design_approved') return 'Design';
    if (s === 'production_started' || s === 'production_completed' || s === 'framing_started') return 'Production';
    if (s === 'printing_queued' || s === 'printing_started' || s === 'printing_completed') return 'Printing';
    if (s === 'out_for_delivery') return 'Delivery';

    return 'Unknown';
}

/**
 * Categorize status for dashboard stats
 */
export function getStatusCategory(status: string): 'pending' | 'in_progress' | 'completed' {
    const s = status?.toLowerCase() || '';

    if (s === 'received') return 'pending';
    if (s === 'out_for_delivery' || s === 'completed' || s === 'done') return 'completed';

    // Everything else is in progress
    return 'in_progress';
}

/**
 * Get status options for filter dropdowns
 */
export function getStatusFilterOptions(): { value: string; label: string }[] {
    return [
        { value: '', label: 'All Statuses' },
        { value: 'received', label: 'Received' },
        { value: 'salesperson_assigned', label: 'Salesperson Assigned' },
        { value: 'site_visited', label: 'Site Visited' },
        { value: 'design_started', label: 'Design Started' },
        { value: 'design_in_review', label: 'Design In Review' },
        { value: 'design_approved', label: 'Design Approved' },
        { value: 'production_started', label: 'Production Started' },
        { value: 'printing_queued', label: 'At Printing' },
        { value: 'printing_started', label: 'Printing Started' },
        { value: 'printing_completed', label: 'Printing Completed' },
        { value: 'framing_started', label: 'Framing / Assembly' },
        { value: 'production_completed', label: 'Production Completed' },
        { value: 'out_for_delivery', label: 'Out for Delivery' },
    ];
}

/**
 * Get workflow stage index (0-10), useful for progress calculation
 */
export function getWorkflowStageIndex(status: string): number {
    const index = WORKFLOW_STATUSES.indexOf(status as JobStatus);
    return index >= 0 ? index : 0;
}

/**
 * Calculate workflow progress percentage
 */
export function getWorkflowProgress(status: string): number {
    const index = getWorkflowStageIndex(status);
    return Math.round((index / (WORKFLOW_STATUSES.length - 1)) * 100);
}
