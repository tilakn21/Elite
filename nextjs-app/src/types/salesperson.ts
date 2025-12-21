/**
 * Salesperson Types
 * Data models for salesperson dashboard
 */

export interface SiteVisitItem {
    jobCode: string;
    customerName: string;
    dateOfVisit: string;
    status: 'pending' | 'submitted' | 'completed';
    shopName?: string;
    jobData?: JobData;
    receptionistData?: ReceptionistData;
    salespersonData?: SalespersonData;
}

export interface JobData {
    id: string;
    job_code: string;
    created_at: string;
    status: string;
}

export interface ReceptionistData {
    customerName: string;
    shopName: string;
    dateOfVisit: string;
    dateOfAppointment: string;
    phone: string;
    email: string;
    city: string;
    area: string;
    landMark: string;
    assignedSalesperson: string;
}

export interface SalespersonData {
    status: string;
    typeOfSign?: string;
    material?: string;
    tools?: string;
    productionTime?: string;
    fittingTime?: string;
    extraDetails?: string;
    measurements?: string; // signMeasurements
    windowMeasurements?: string; // windowVinylMeasurements
    stickSide?: string;
    images?: string[];
    paymentAmount?: number;
    modeOfPayment?: string;
    submittedAt?: string;
}

export interface SalespersonProfile {
    id: string;
    full_name: string;
    phone: string | null;
    email: string | null;
    role: string;
    branch_id: number | null;
    created_at: string;
    is_available: boolean;
    number_of_jobs: number;
}
