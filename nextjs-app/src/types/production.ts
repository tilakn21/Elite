/**
 * Production Dashboard Types
 */

// Production Job Status (internal workflow)
export type ProductionJobStatus =
    | 'pending'           // Design approved, waiting for production
    | 'in_progress'       // Production started
    | 'ready_for_printing'; // Production complete, ready for printing

export interface Worker {
    id: string;
    name: string;
    role: string;
    status: 'available' | 'busy';
    currentJob?: string;
}

export interface ProductionJob {
    id: string;
    jobCode: string;
    customerName: string;
    shopName?: string;
    description?: string;
    status: ProductionJobStatus;
    priority: 'high' | 'medium' | 'low';

    // Assigned workers
    assignedWorkers: string[];

    // Progress (0-100)
    progress: number;

    // Timeline
    timeline?: { status: string; timestamp: string }[];
    productionStartedAt?: string;

    // Linked Data
    designProofUrl?: string;
    salespersonNotes?: string;
}

export interface ProductionStats {
    pendingJobs: number;      // Jobs waiting to start
    activeJobs: number;       // Jobs in progress
    completedToday: number;   // Jobs completed today
    availableWorkers: number; // Workers available
}
