/**
 * Design Dashboard Types
 */

// Design Job Status
export type DesignJobStatus =
    | 'pending'            // Waiting for design
    | 'in_progress'        // Designer working on it
    | 'draft_uploaded'     // Draft uploaded, waiting for approval
    | 'changes_requested'  // Client requested changes
    | 'approved'           // Design approved
    | 'completed';         // Moved to production

// Design Job Item
export interface DesignJob {
    id: string;
    jobCode: string;
    customerName: string;
    priority: 'high' | 'medium' | 'low';
    status: DesignJobStatus;
    deadline?: string;
    description?: string;
    specifications?: string; // Dimensions, materials etc.
    assignedDate: string;
    shopName?: string;

    // Drafts
    drafts?: DesignDraft[];

    // Linked data from other stages
    salespersonImages?: string[];
    receptionistNotes?: string;
}

// Design Draft
export interface DesignDraft {
    id: string;
    url: string;
    name: string;
    uploadedAt: string;
    version: number;
    status: 'pending_approval' | 'approved' | 'rejected';
    feedback?: string;
}

// Dashboard Stats
export interface DesignStats {
    pendingJobs: number;
    approvedToday: number;
    correctionsHere: number;
    totalCompleted: number;
}
