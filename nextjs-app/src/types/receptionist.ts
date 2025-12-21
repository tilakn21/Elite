/**
 * Receptionist Dashboard Types
 * Matches Flutter models for job requests and salesperson management
 */

// Job request status enum
export type JobRequestStatus = 'pending' | 'approved' | 'declined' | 'completed';

// Job request model - matches Flutter JobRequest
export interface JobRequest {
    id: string;
    jobCode: string;
    customerName: string;
    phone: string;
    email: string;
    status: JobRequestStatus;
    dateAdded: string;
    shopName?: string;
    streetAddress?: string;
    streetNumber?: string;
    town?: string;
    postcode?: string;
    assignedSalesperson?: string;
    timeOfVisit?: string;
    dateOfVisit?: string;
    dateOfAppointment?: string;
    createdBy?: string;
    receptionistJson?: Record<string, unknown>;
}

// Salesperson status enum
export type SalespersonStatus = 'available' | 'busy' | 'on_visit';

// Salesperson model for assignment
export interface Salesperson {
    id: string;
    name: string;
    status: SalespersonStatus;
    isAvailable: boolean;
    numberOfJobs: number;
    department?: string;
}

// Form data for creating new job request
export interface NewJobRequestData {
    customerName: string;
    phone: string;
    shopName: string;
    streetAddress: string;
    streetNumber: string;
    town: string;
    postcode: string;
    dateOfAppointment?: string;
    dateOfVisit: string;
    timeOfVisit: string;
    assignedSalesperson?: string;
}

// Dashboard stats
export interface ReceptionistStats {
    totalJobs: number;
    pendingJobs: number;
    completedJobs: number;
    assignedToday: number;
}

// Receptionist profile
export interface ReceptionistProfile {
    id: string;
    fullName: string;
    role: string;
    branchId?: number;
    branchName?: string;
}
