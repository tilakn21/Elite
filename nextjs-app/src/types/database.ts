export type UserRole =
    | 'admin'
    | 'receptionist'
    | 'salesperson'
    | 'designer'
    | 'accountant'
    | 'production_manager'
    | 'printing_manager'
    | 'prod_labour'
    | 'print_labour'
    | 'driver';

// Unified Job Status - single source of truth for workflow
export type JobStatus =
    | 'received'              // Receptionist created
    | 'salesperson_assigned'  // Salesperson assigned
    | 'site_visited'          // Site visit completed
    | 'design_started'        // Design team working
    | 'design_in_review'      // Chat + modifications
    | 'design_approved'       // Customer approved
    | 'production_started'    // Manufacturing begun
    | 'printing_queued'       // Sent to printing (NEW)
    | 'printing_started'      // Printing in progress
    | 'printing_completed'    // Printing done
    | 'framing_started'       // Back to production for framing (NEW)
    | 'production_completed'  // Manufacturing done
    | 'out_for_delivery';     // Final delivery

// Payment Status - accounts dimension
export type PaymentStatus =
    | 'payment_pending'   // No payment received
    | 'partially_paid'    // Advance received
    | 'payment_done';     // Fully paid

// Payment record for tracking individual payments
// Payment record for tracking individual payments
export interface PaymentRecord {
    id?: string;
    amount: number;
    mode: string; // Allow flexible string for captialized 'Cash' etc
    // Schema variations
    recorded_by?: string;
    received_by?: string;
    recorded_at?: string;
    date?: string;
    notes?: string;
}

export interface Employee {
    id: string;
    full_name: string;
    phone: string | null;
    email: string | null;
    role: string;
    branch_id: number | null;
    created_at: string;
    is_available: boolean;
    assigned_job: string | null;
}

export interface EmployeeInsert {
    full_name: string;
    phone?: string | null;
    email?: string | null;
    role: string;
    branch_id?: number | null;
    is_available?: boolean;
    assigned_job?: string | null;
}

export interface EmployeeUpdate {
    full_name?: string;
    phone?: string | null;
    email?: string | null;
    role?: string;
    branch_id?: number | null;
    is_available?: boolean;
    assigned_job?: string | null;
}

export interface Branch {
    id: number;
    name: string;
    location: string;
    contact_no: string;
}

// JSONB Field Interfaces
export interface ReceptionistData {
    client_name?: string;
    customerName?: string;
    client_phone?: string;
    phone?: string;
    job_details?: string;
    priority?: string;
    shopName?: string;
    assignedSalesperson?: string;
    dateOfAppointment?: string;
    streetAddress?: string;
    town?: string;
    status?: string;
}

export interface SalespersonData {
    assigned_to?: string;
    notes?: string;
    status?: string;
    typeOfSign?: string;
    material?: string;
    timeForProduction?: string;
    timeForFitting?: string;
    signMeasurements?: string;
    paymentAmount?: number;
    extraDetails?: string;
}

export interface DesignData {
    designer?: string;
    status?: string;
    files?: string[];
    comments?: string;
}

export interface ProductionData {
    assigned_team?: string[];
    assignedTeam?: string[];
    status?: string;
    current_status?: string;
    start_date?: string;
    startDate?: string;
    end_date?: string;
    estimatedCompletion?: string;
    materials?: string;
}

export interface PrintingData {
    printer_assigned?: string;
    status?: string;
    printStatus?: string;
    material?: string;
    printMaterial?: string;
    printSize?: string;
    printQuantity?: string;
    printNotes?: string;
}

export interface AccountsData {
    invoice_no?: string;
    invoiceNumber?: string;
    payment_status?: PaymentStatus;
    status?: string;
    amount_paid?: number;
    amountPaid?: number;
    totalAmount?: number;
    total_amount?: number;
    paymentMethod?: string;
    payments?: PaymentRecord[];
    amount_remaining?: number;
}

export interface Job {
    id: string;
    job_code: string;
    status: string;
    branch_id: number;
    amount: number;
    created_at: string;
    updated_at: string;
    receptionist?: ReceptionistData;
    salesperson?: SalespersonData;
    design?: DesignData;
    production?: ProductionData;
    printing?: PrintingData;
    accounts?: AccountsData; // Mapped from 'accountant' column in DB usually
}

// Derived Types for UI
export interface JobSummary {
    id: string;
    job_code: string;
    title: string; // derived from client_name or details
    client: string;
    status: string;
    date: string;
}

export interface DashboardStats {
    totalJobs: number;
    inProgress: number;
    completed: number;
    pending: number;
}

export interface BranchStats {
    branchId: number;
    branchName: string;
    activeJobs: number;
}

// Reimbursement Types
export type ReimbursementStatus = 'pending' | 'approved' | 'rejected' | 'paid';

export interface Reimbursement {
    id: string;
    emp_id: string;
    emp_name: string;
    amount: number;
    reimbursement_date: string; // ISO date string
    purpose: string;
    receipt_url?: string;
    remarks?: string;
    status: ReimbursementStatus;
    created_at?: string;
    updated_at?: string;
}

export interface ReimbursementInsert {
    emp_id: string;
    emp_name: string;
    amount: number;
    reimbursement_date: string;
    purpose: string;
    receipt_url?: string;
    remarks?: string;
    status?: ReimbursementStatus;
}

export interface ReimbursementUpdate {
    amount?: number;
    reimbursement_date?: string;
    purpose?: string;
    receipt_url?: string;
    remarks?: string;
    status?: ReimbursementStatus;
}

// Calendar Types - Mapped from Jobs
export interface CalendarEvent {
    id: string;
    title: string;
    date: string; // YYYY-MM-DD
    type: 'job';
    status: string;
    metadata: {
        jobCode: string;
        client: string;
    };
}
