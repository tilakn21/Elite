/**
 * Production Dashboard Types
 */

export type ProductionJobStatus =
    | 'pending_production' // Sent from Design
    | 'fabrication'        // Manufacturing start
    | 'assembly'           // Assembling parts
    | 'quality_check'      // Internal QC
    | 'ready_for_install'  // Done
    | 'completed';         // Installed/Delivered

export interface Worker {
    id: string;
    name: string;
    role: 'fabricator' | 'assembler' | 'installer';
    status: 'available' | 'busy' | 'on_site';
    currentJob?: string;
    skills: string[];
}

export interface ProductionJob {
    id: string;
    jobCode: string;
    customerName: string;
    description: string;
    status: ProductionJobStatus;
    deadline: string;
    assignedWorkers: string[]; // Worker IDs
    priority: 'high' | 'medium' | 'low';

    // Linked Data
    designProofUrl?: string;
    specifications?: Record<string, any>;

    // Progress
    fabricationProgress: number; // 0-100
    assemblyProgress: number; // 0-100
}

export interface ProductionStats {
    activeJobs: number;
    availableWorkers: number;
    completedToday: number;
    delayedJobs: number;
}
