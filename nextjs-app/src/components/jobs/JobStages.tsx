import { css } from '@emotion/react';
import {
    FaUser, FaHandshake, FaPenFancy, FaFileInvoiceDollar,
    FaIndustry, FaPrint
} from 'react-icons/fa';
import { StageCard, TimelineItem } from './StageCard';
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

    // --- Stage Logic Helpers ---

    const isCompleted = (status?: string) => {
        if (!status) return false;
        const s = status.toLowerCase();
        return ['completed', 'approved', 'done', 'production_complete', 'print_complete', 'paid', 'payment_done'].includes(s);
    };

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const getStatus = (data: any): string => {
        if (!data) return 'Pending';
        if (typeof data === 'object' && !Array.isArray(data)) {
            if (data.status) return String(data.status);
            if (data.current_status) return String(data.current_status);
            if (data.printStatus) return String(data.printStatus);
        }
        return 'Pending';
    };

    const formatDate = (dateStr?: string) => {
        if (!dateStr) return undefined;
        try {
            const date = new Date(dateStr);
            return date.toLocaleDateString('en-GB', {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch {
            return dateStr;
        }
    };

    // --- Timeline Generators ---

    const getReceptionistTimeline = (): TimelineItem[] => {
        const data = job.receptionist;
        if (!data) return [];

        return [
            {
                label: 'Job Received',
                timestamp: formatDate(job.created_at),
                completed: true,
            },
            {
                label: 'Customer Details Added',
                completed: !!data.customerName,
            },
            {
                label: 'Salesperson Assigned',
                completed: !!data.assignedSalesperson,
                current: !!data.assignedSalesperson && !data.dateOfAppointment,
            },
            {
                label: 'Appointment Scheduled',
                timestamp: data.dateOfAppointment ? formatDate(data.dateOfAppointment) : undefined,
                completed: !!data.dateOfAppointment,
                current: !!data.dateOfAppointment,
            },
        ];
    };

    const getSalespersonTimeline = (): TimelineItem[] => {
        const data = job.salesperson;
        if (!data) return [];

        const hasDetails = !!(data.typeOfSign || data.material || data.signMeasurements);
        const siteVisited = data.status === 'site_visited' || hasDetails;

        return [
            {
                label: 'Job Assigned',
                completed: true,
            },
            {
                label: 'Site Visit Scheduled',
                completed: !!data.status || siteVisited,
                current: !!data.status && !siteVisited,
            },
            {
                label: 'Site Visited',
                completed: siteVisited,
                current: siteVisited && !hasDetails,
            },
            {
                label: 'Details Submitted',
                completed: hasDetails,
                current: hasDetails,
            },
        ];
    };

    const getDesignTimeline = (): TimelineItem[] => {
        const data = job.design;
        if (!data) return [];

        const status = String(data.status || '').toLowerCase();
        const completed = isCompleted(data.status);

        return [
            {
                label: 'Design Started',
                completed: status !== 'pending' && !!data.status,
                current: status === 'design_started' || status === 'started',
            },
            {
                label: 'Draft Created',
                completed: status.includes('review') || status.includes('approved') || completed,
            },
            {
                label: 'Sent for Review',
                completed: status.includes('review') || status.includes('approved') || completed,
                current: status.includes('review'),
            },
            {
                label: 'Customer Feedback',
                completed: status.includes('approved') || completed,
            },
            {
                label: 'Design Approved',
                completed: status.includes('approved') || completed,
            },
        ];
    };

    const getProductionTimeline = (): TimelineItem[] => {
        const data = job.production;
        if (!data) return [];

        const status = getStatus(data).toLowerCase();
        // Check for specific milestones in the linear flow
        const hasStarted = status.includes('started') || status.includes('progress') || status.includes('printing') || status.includes('framing') || status.includes('completed') || status.includes('done');
        const sentToPrint = status.includes('printing') || status.includes('framing') || status.includes('completed') || status.includes('done');
        const framingStarted = status.includes('framing') || status.includes('completed') || status.includes('done');
        const completed = isCompleted(status);
        const hasTeam = !!(data.assigned_team || data.assignedTeam);

        return [
            {
                label: 'Production Queued',
                completed: !!data.status || hasTeam,
            },
            {
                label: 'Production Started',
                timestamp: data.startDate ? formatDate(data.startDate) : undefined,
                completed: hasStarted,
                current: hasStarted && !sentToPrint,
            },
            {
                label: 'Sent to Printing',
                completed: sentToPrint,
                current: sentToPrint && !framingStarted,
            },
            {
                label: 'Framing / Assembly',
                completed: framingStarted,
                current: framingStarted && !completed,
            },
            {
                label: 'Production Complete',
                timestamp: data.estimatedCompletion ? `Est: ${formatDate(data.estimatedCompletion)}` : undefined,
                completed: completed,
            },
        ];
    };

    const getPrintingTimeline = (): TimelineItem[] => {
        const data = job.printing;
        if (!data) return [];

        const status = getStatus(data).toLowerCase();
        const completed = isCompleted(status);
        // Printing is "started" if status is printed_started or completed
        const started = status === 'print_started' || status.includes('started') || completed;

        return [
            {
                label: 'Received for Printing',
                completed: !!data.status,
            },
            {
                label: 'Printing Started',
                completed: started,
                current: started && !completed,
            },
            {
                label: 'Printing Complete',
                completed: completed,
            },
        ];
    };

    const getAccountsTimeline = (): TimelineItem[] => {
        const data = job.accounts;
        if (!data) return [];

        const paymentStatus = (data.payment_status || data.status || '').toLowerCase();
        const completed = paymentStatus === 'paid' || paymentStatus === 'payment_done';
        const partial = paymentStatus === 'partially_paid';

        return [
            {
                label: 'Invoice Generated',
                completed: !!(data.invoice_no || data.invoiceNumber),
            },
            {
                label: 'Invoice Sent',
                completed: !!(data.invoice_no || data.invoiceNumber),
            },
            {
                label: 'Advance Received',
                completed: partial || completed,
                current: partial,
            },
            {
                label: 'Payment Complete',
                completed: completed,
            },
        ];
    };

    // --- Progress Calculator ---
    const calculateProgress = (timeline: TimelineItem[]): number => {
        if (timeline.length === 0) return 0;
        const completedCount = timeline.filter(t => t.completed).length;
        return Math.round((completedCount / timeline.length) * 100);
    };

    // --- Renderers ---

    const renderReceptionist = () => {
        const data = job.receptionist;
        const timeline = getReceptionistTimeline();
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Receptionist"
                icon={<FaUser size={20} />}
                color="#9333ea"
                status={data?.status || 'Pending'}
                isCompleted={completed}
                progress={calculateProgress(timeline)}
                timeline={timeline}
            >
                <InfoRow label="Customer" value={data?.customerName} />
                <InfoRow label="Phone" value={data?.phone || data?.client_phone} />
                <InfoRow label="Shop Name" value={data?.shopName} />
                <InfoRow label="Assigned To" value={data?.assignedSalesperson} />
                <InfoRow label="Date" value={data?.dateOfAppointment} />
            </StageCard>
        );
    };

    const renderSalesperson = () => {
        const data = job.salesperson;
        const timeline = getSalespersonTimeline();
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Salesperson"
                icon={<FaHandshake size={20} />}
                color="#2563eb"
                status={data?.status || 'Pending'}
                isCompleted={completed}
                progress={calculateProgress(timeline)}
                timeline={timeline}
            >
                <InfoRow label="Sign Type" value={data?.typeOfSign} />
                <InfoRow label="Material" value={data?.material} />
                <InfoRow label="Measurements" value={data?.signMeasurements} />
                <InfoRow label="Payment" value={data?.paymentAmount ? `£${data.paymentAmount}` : null} />
            </StageCard>
        );
    };

    const renderDesign = () => {
        const data = job.design;
        const timeline = getDesignTimeline();
        const completed = isCompleted(data?.status);

        return (
            <StageCard
                title="Designer"
                icon={<FaPenFancy size={20} />}
                color="#db2777"
                status={data?.status || 'Pending'}
                isCompleted={completed}
                progress={calculateProgress(timeline)}
                timeline={timeline}
            >
                <InfoRow label="Designer" value={data?.designer} />
                <InfoRow label="Comments" value={data?.comments} />
            </StageCard>
        );
    };

    const renderProduction = () => {
        const data = job.production;
        const timeline = getProductionTimeline();
        const status = getStatus(data);
        const completed = isCompleted(status);

        return (
            <StageCard
                title="Production"
                icon={<FaIndustry size={20} />}
                color="#4f46e5"
                status={status}
                isCompleted={completed}
                progress={calculateProgress(timeline)}
                timeline={timeline}
            >
                <InfoRow
                    label="Assigned Team"
                    value={
                        Array.isArray(data?.assigned_team)
                            ? data?.assigned_team.join(', ')
                            : (Array.isArray(data?.assignedTeam) ? data?.assignedTeam.join(', ') : data?.assignedTeam)
                    }
                />
                <InfoRow label="Start Date" value={data?.startDate} />
                <InfoRow label="Est. Completion" value={data?.estimatedCompletion} />
            </StageCard>
        );
    };

    const renderPrinting = () => {
        const data = job.printing;
        const timeline = getPrintingTimeline();
        const status = getStatus(data);
        const completed = isCompleted(status);

        return (
            <StageCard
                title="Printing"
                icon={<FaPrint size={20} />}
                color="#0d9488"
                status={status}
                isCompleted={completed}
                progress={calculateProgress(timeline)}
                timeline={timeline}
            >
                <InfoRow label="Printer" value={data?.printer_assigned} />
                <InfoRow label="Material" value={data?.printMaterial || data?.material} />
                <InfoRow label="Size" value={data?.printSize} />
                <InfoRow label="Quantity" value={data?.printQuantity} />
            </StageCard>
        );
    };

    const renderAccounts = () => {
        const data = job.accounts;
        const timeline = getAccountsTimeline();
        const completed = isCompleted(data?.payment_status || data?.status);

        return (
            <StageCard
                title="Accounts"
                icon={<FaFileInvoiceDollar size={20} />}
                color="#f97316"
                status={data?.payment_status || data?.status || 'Pending'}
                isCompleted={completed}
                progress={calculateProgress(timeline)}
                timeline={timeline}
            >
                <InfoRow label="Invoice No" value={data?.invoice_no || data?.invoiceNumber} />
                <InfoRow label="Total Amount" value={data?.totalAmount ? `£${data.totalAmount}` : null} />
                <InfoRow label="Paid" value={data?.amount_paid ? `£${data.amount_paid}` : null} />
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
