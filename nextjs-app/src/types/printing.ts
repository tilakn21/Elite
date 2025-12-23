/**
 * Printing Dashboard Types
 */

// Simplified printing statuses
export type PrintingJobStatus =
    | 'pending'          // Ready for print (from production_completed)
    | 'print_started'    // Printing in progress
    | 'print_completed'; // Done

export interface PrintingJob {
    id: string;
    jobCode: string;
    customerName: string;
    shopName?: string;
    description?: string;
    status: PrintingJobStatus;
    priority: 'high' | 'medium' | 'low';
    queueNumber: number;  // Position in queue

    // Design image
    designImageUrl?: string;

    // Timeline
    timeline?: { status: string; timestamp: string }[];
    printStartedAt?: string;

    // From salesperson
    material?: string;
    dimensions?: string;

    createdAt: string;
}

export interface PrintingStats {
    pendingJobs: number;    // In queue
    activeJobs: number;     // Currently printing
    completedToday: number; // Finished today
}
