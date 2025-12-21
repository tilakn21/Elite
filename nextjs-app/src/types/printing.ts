/**
 * Printing Dashboard Types
 */

export type PrintingJobStatus = 'ready_for_print' | 'printing' | 'completed' | 'quality_check_failed' | 'quality_check_passed';

export interface PrintingJob {
    id: string;
    jobCode: string; // Display ID (e.g. JB-101)
    customerName: string;
    description: string;
    material: string;
    dimensions: string; // e.g., "10x5 ft"
    status: PrintingJobStatus;
    priority: 'high' | 'medium' | 'low';
    quantity: number;
    files: string[]; // URLs to design files
    assignedTo?: string; // Printer name or ID
    createdAt: string;
    startedAt?: string;
    completedAt?: string;
}

export interface PrintingStats {
    jobsInQueue: number;
    completedToday: number;
    inkLevelCyan: number; // Percentage 0-100
    inkLevelMagenta: number;
    inkLevelYellow: number;
    inkLevelBlack: number;
    activePrinters: number;
}
