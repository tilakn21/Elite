import { css } from '@emotion/react';
import {
    FaUser, FaHandshake, FaPenFancy, FaFileInvoiceDollar,
    FaIndustry, FaPrint
} from 'react-icons/fa';
import { StageCard } from './StageCard';
import { InfoRow } from './InfoRow';
import type { Job } from '@/types';

interface JobStagesProps {
    job: Job;
}

const containerStyles = css`
  display: flex;
  flex-direction: column;
  gap: 16px;
`;

export const JobStages = ({ job }: JobStagesProps) => {

    // --- Stage Logic Helpers (mirrored from Flutter JobStageUtils) ---

    const isCompleted = (status?: string) => {
        if (!status) return false;
        const s = status.toLowerCase();
        return ['completed', 'approved', 'done', 'production_complete', 'print_complete'].includes(s);
    };

    // Helper to get nested status safely
    const getStatus = (data: any) => {
        if (!data) return 'Pending';
        // Handle Map/Object
        if (typeof data === 'object' && !Array.isArray(data)) {
            if (data.status) return data.status;
            if (data.current_status) return data.current_status;
            if (data.printStatus) return data.printStatus;
        }
        return 'Pending';
    };

    // --- Renderers for each stage ---

    const renderReceptionist = () => {
        const data = job.receptionist;
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Receptionist"
                icon={<FaUser size={20} />}
                color="#9333ea" // Purple
                status={data?.status}
                isCompleted={completed}
            >
                <InfoRow label="Customer" value={data?.customerName} />
                <InfoRow label="Phone" value={data?.client_phone} /> {/* Note: data mapping might differ, checking types */}
                <InfoRow label="Shop Name" value={data?.shopName} />
                <InfoRow label="Assigned To" value={data?.assignedSalesperson} />
                <InfoRow label="Date" value={data?.dateOfAppointment} />
                <InfoRow label="Address" value={`${data?.streetAddress || ''} ${data?.town || ''}`} />
            </StageCard>
        );
    };

    const renderSalesperson = () => {
        const data = job.salesperson;
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Salesperson"
                icon={<FaHandshake size={20} />}
                color="#2563eb" // Blue
                status={data?.status}
                isCompleted={completed}
            >
                <InfoRow label="Sign Type" value={data?.typeOfSign} />
                <InfoRow label="Material" value={data?.material} />
                <InfoRow label="Production Time" value={data?.timeForProduction} />
                <InfoRow label="Fitting Time" value={data?.timeForFitting} />
                <InfoRow label="Measurements" value={data?.signMeasurements} />
                <InfoRow label="Payment" value={data?.paymentAmount ? `£${data.paymentAmount}` : null} />
                <InfoRow label="Notes" value={data?.extraDetails} />
            </StageCard>
        );
    };

    const renderDesign = () => {
        // Design data can be a list of drafts or a single object often. 
        // In Flutter it handles numeric keys for multiple drafts. 
        // For simplicity here, we'll try to display the latest status or summary.
        const data = job.design;
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Designer"
                icon={<FaPenFancy size={20} />}
                color="#db2777" // Pink
                status={data?.status}
                isCompleted={completed}
            >
                {/* If we have specific fields */}
                <InfoRow label="Designer" value={data?.designer} />
                <InfoRow label="Comments" value={data?.comments} />
                {/* TODO: Add logic for multiple drafts if needed */}
            </StageCard>
        );
    };

    const renderProduction = () => {
        const data = job.production;
        const status = getStatus(data);
        const completed = isCompleted(status);

        return (
            <StageCard
                title="Production"
                icon={<FaIndustry size={20} />}
                color="#4f46e5" // Indigo
                status={status}
                isCompleted={completed}
            >
                <InfoRow label="Assigned Team" value={Array.isArray(data?.assigned_team) ? data?.assigned_team.join(', ') : (Array.isArray(data?.assignedTeam) ? data?.assignedTeam.join(', ') : data?.assignedTeam)} />
                <InfoRow label="Start Date" value={data?.startDate} />
                <InfoRow label="Est. Completion" value={data?.estimatedCompletion} />
                <InfoRow label="Materials" value={data?.materials} />
            </StageCard>
        );
    };

    const renderPrinting = () => {
        const data = job.printing;
        const status = getStatus(data);
        const completed = isCompleted(status);

        return (
            <StageCard
                title="Printing"
                icon={<FaPrint size={20} />}
                color="#0d9488" // Teal
                status={status}
                isCompleted={completed}
            >
                <InfoRow label="Printer" value={data?.printer_assigned} />
                <InfoRow label="Material" value={data?.printMaterial || data?.material} />
                <InfoRow label="Size" value={data?.printSize} />
                <InfoRow label="Quantity" value={data?.printQuantity} />
                <InfoRow label="Notes" value={data?.printNotes} />
            </StageCard>
        );
    };

    const renderAccounts = () => {
        const data = job.accounts;
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Accounts"
                icon={<FaFileInvoiceDollar size={20} />}
                color="#f97316" // Orange
                status={data?.payment_status || data?.status}
                isCompleted={completed}
            >
                <InfoRow label="Invoice No" value={data?.invoice_no || data?.invoiceNumber} />
                <InfoRow label="Total Amount" value={data?.totalAmount ? `£${data.totalAmount}` : null} />
                <InfoRow label="Paid" value={data?.amount_paid || data?.amountPaid ? `£${data?.amount_paid || data?.amountPaid}` : null} />
                <InfoRow label="Payment Method" value={data?.paymentMethod} />
            </StageCard>
        );
    };

    return (
        <div css={containerStyles}>
            {renderReceptionist()}
            {renderSalesperson()}
            {renderDesign()}
            {renderAccounts()}
            {renderProduction()}
            {renderPrinting()}
        </div>
    );
};
