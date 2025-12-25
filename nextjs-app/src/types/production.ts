/**
 * Production Dashboard Types
 */

// Production Job Status (internal workflow)
export type ProductionJobStatus =
    | 'pending'           // Design approved, waiting for production
    | 'in_progress'       // Production started
    | 'at_printing'       // Sent to printing (NEW)
    | 'ready_for_framing' // Printing done, back for framing (NEW)
    | 'framing_in_progress' // Framing started (NEW)
    | 'completed';        // Production complete

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
