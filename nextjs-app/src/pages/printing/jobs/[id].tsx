/**
 * Printing Job Details Page
 * Shows design proof, job details, and printing actions
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { css } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { supabase } from '@/services/supabase';
import { printingService } from '@/services';

interface JobDetails {
    id: string;
    jobCode: string;
    status: string;
    customerName: string;
    shopName: string;
    phone: string;
    email: string;
    city: string;
    area: string;
    // Design
    designProofs: string[];
    // Salesperson
    material: string;
    measurements: string;
    extraDetails: string;
    // Printing
    printingStatus: string;
    queueNumber: number;
}

// Styles
const styles = {
    container: css`
        max-width: 1000px;
        margin: 0 auto;
        padding: 24px;
    `,
    header: css`
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
        
        h1 { font-size: 24px; font-weight: 700; margin: 0; }
        .job-code { color: #6B7280; font-size: 14px; margin-top: 4px; }
    `,
    backButton: css`
        padding: 8px 16px;
        background: transparent;
        border: 1px solid #E5E7EB;
        border-radius: 8px;
        cursor: pointer;
        font-size: 14px;
        &:hover { background: #F9FAFB; }
    `,
    section: css`
        background: white;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        
        h2 {
            font-size: 16px; font-weight: 600;
            margin: 0 0 16px 0;
            padding-bottom: 12px;
            border-bottom: 1px solid #E5E7EB;
        }
    `,
    grid: css`
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
        @media (max-width: 600px) { grid-template-columns: 1fr; }
    `,
    field: css`
        .label { font-size: 12px; color: #6B7280; margin-bottom: 4px; }
        .value { font-size: 14px; font-weight: 500; color: #1F2937; }
    `,
    designImage: css`
        width: 100%;
        max-height: 400px;
        object-fit: contain;
        border-radius: 12px;
        background: #F3F4F6;
        cursor: pointer;
    `,
    actionBar: css`
        display: flex;
        gap: 12px;
        margin-top: 24px;
        
        button {
            flex: 1;
            padding: 14px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            border: none;
            
            &:disabled { opacity: 0.6; cursor: not-allowed; }
        }
    `,
    loading: css`
        display: flex;
        justify-content: center;
        align-items: center;
        height: 300px;
    `,
    statusBadge: (color: string, bgColor: string) => css`
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        background: ${bgColor};
        color: ${color};
    `,
};

// Status helper
const getStatusInfo = (status: string) => {
    const statusMap: Record<string, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'In Queue', color: '#92400E', bgColor: '#FEF3C7' },
        print_started: { label: 'Printing', color: '#1E40AF', bgColor: '#DBEAFE' },
        print_completed: { label: 'Completed', color: '#065F46', bgColor: '#D1FAE5' },
    };
    return statusMap[status] || { label: status, color: '#6B7280', bgColor: '#F3F4F6' };
};

export default function PrintingJobDetailsPage() {
    const router = useRouter();
    const { id } = router.query;

    const [job, setJob] = useState<JobDetails | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState(false);
    const [fullscreenImage, setFullscreenImage] = useState<string | null>(null);

    useEffect(() => {
        if (!id) return;

        async function loadJob() {
            try {
                const { data, error } = await supabase
                    .from('jobs')
                    .select('*')
                    .eq('id', id)
                    .single();

                if (error || !data) {
                    console.error('Error loading job:', error);
                    return;
                }

                const receptionist = data.receptionist || {};
                const salesperson = data.salesperson || {};
                const design = data.design || {};
                const printing = data.printing || {};

                // Use approved drafts if available, otherwise fallback to all drafts
                const allDrafts = design.drafts || [];
                const approvedDrafts = allDrafts.filter((d: any) => d.status === 'approved');
                const finalDrafts = approvedDrafts.length > 0 ? approvedDrafts : allDrafts;

                setJob({
                    id: data.id,
                    jobCode: data.job_code || data.id,
                    status: data.status,
                    customerName: receptionist.customerName || 'Unknown',
                    shopName: receptionist.shopName || '',
                    phone: receptionist.phone || '',
                    email: receptionist.email || '',
                    city: receptionist.city || '',
                    area: receptionist.area || '',
                    designProofs: finalDrafts.map((d: any) => d.url) || [],
                    material: salesperson.material || '',
                    measurements: salesperson.measurements || salesperson.signMeasurements || '',
                    extraDetails: salesperson.extraDetails || '',
                    printingStatus: printing.status || 'pending',
                    queueNumber: 1, // Would need to calculate from list
                });
            } catch (error) {
                console.error('Failed to load job:', error);
            } finally {
                setIsLoading(false);
            }
        }

        loadJob();
    }, [id]);

    const handleStartPrinting = async () => {
        if (!job) return;
        setActionLoading(true);
        try {
            const success = await printingService.startPrinting(job.id);
            if (success) {
                setJob({ ...job, printingStatus: 'print_started' });
            }
        } catch (error) {
            console.error('Failed to start printing:', error);
        } finally {
            setActionLoading(false);
        }
    };

    const handleMarkComplete = async () => {
        if (!job) return;
        setActionLoading(true);
        try {
            const success = await printingService.markPrintCompleted(job.id);
            if (success) {
                setJob({ ...job, printingStatus: 'print_completed' });
            }
        } catch (error) {
            console.error('Failed to complete:', error);
        } finally {
            setActionLoading(false);
        }
    };

    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loading}><div>Loading...</div></div>
            </AppLayout>
        );
    }

    if (!job) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.container}>
                    <p>Job not found</p>
                    <button onClick={() => router.back()}>Go Back</button>
                </div>
            </AppLayout>
        );
    }

    const statusInfo = getStatusInfo(job.printingStatus);

    return (
        <>
            <Head>
                <title>Print Job | {job.customerName}</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.container}>
                    {/* Header */}
                    <div css={styles.header}>
                        <div>
                            <h1>{job.customerName}</h1>
                            <div className="job-code">#{job.jobCode} • {job.shopName}</div>
                        </div>
                        <button css={styles.backButton} onClick={() => router.back()}>
                            ← Back
                        </button>
                    </div>

                    {/* Status */}
                    <div css={styles.section}>
                        <h2>Print Status</h2>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                            <span css={styles.statusBadge(statusInfo.color, statusInfo.bgColor)}>
                                {statusInfo.label}
                            </span>
                        </div>
                    </div>

                    {/* Design to Print */}
                    <div css={styles.section}>
                        <h2>📐 Design to Print</h2>
                        {job.designProofs.length > 0 ? (
                            <img
                                src={job.designProofs[0]}
                                alt="Design"
                                css={styles.designImage}
                                onClick={() => setFullscreenImage(job.designProofs[0] ?? null)}
                            />
                        ) : (
                            <p style={{ color: '#6B7280', fontSize: '14px' }}>No design available</p>
                        )}
                    </div>

                    {/* Print Specs */}
                    <div css={styles.section}>
                        <h2>🖨️ Print Specifications</h2>
                        <div css={styles.grid}>
                            <div css={styles.field}>
                                <div className="label">Material</div>
                                <div className="value">{job.material || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Dimensions</div>
                                <div className="value">{job.measurements || '-'}</div>
                            </div>
                        </div>
                        {job.extraDetails && (
                            <div css={styles.field} style={{ marginTop: '16px' }}>
                                <div className="label">Notes</div>
                                <div className="value">{job.extraDetails}</div>
                            </div>
                        )}
                    </div>

                    {/* Customer */}
                    <div css={styles.section}>
                        <h2>👤 Customer</h2>
                        <div css={styles.grid}>
                            <div css={styles.field}>
                                <div className="label">Phone</div>
                                <div className="value">{job.phone || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Location</div>
                                <div className="value">{job.city}, {job.area}</div>
                            </div>
                        </div>
                    </div>

                    {/* Action Buttons */}
                    <div css={styles.actionBar}>
                        {job.printingStatus === 'pending' && (
                            <button
                                onClick={handleStartPrinting}
                                disabled={actionLoading}
                                style={{ background: '#3B82F6', color: 'white' }}
                            >
                                {actionLoading ? 'Starting...' : '▶️ Start Printing'}
                            </button>
                        )}
                        {job.printingStatus === 'print_started' && (
                            <button
                                onClick={handleMarkComplete}
                                disabled={actionLoading}
                                style={{ background: '#10B981', color: 'white' }}
                            >
                                {actionLoading ? 'Completing...' : '✅ Mark Print Complete'}
                            </button>
                        )}
                        {job.printingStatus === 'print_completed' && (
                            <button
                                disabled
                                style={{ background: '#D1FAE5', color: '#065F46' }}
                            >
                                ✅ Print Completed
                            </button>
                        )}
                    </div>
                </div>
            </AppLayout>

            {/* Fullscreen Image Viewer */}
            {fullscreenImage && (
                <div
                    style={{
                        position: 'fixed',
                        inset: 0,
                        background: 'rgba(0, 0, 0, 0.9)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        zIndex: 2000,
                        cursor: 'pointer',
                    }}
                    onClick={() => setFullscreenImage(null)}
                >
                    <button
                        onClick={() => setFullscreenImage(null)}
                        style={{
                            position: 'absolute',
                            top: '20px',
                            right: '20px',
                            background: 'rgba(255,255,255,0.2)',
                            border: 'none',
                            color: 'white',
                            fontSize: '28px',
                            width: '44px',
                            height: '44px',
                            borderRadius: '50%',
                            cursor: 'pointer',
                        }}
                    >
                        ×
                    </button>
                    <img
                        src={fullscreenImage}
                        alt="Full size"
                        style={{
                            maxWidth: '95%',
                            maxHeight: '95%',
                            objectFit: 'contain',
                            borderRadius: '8px',
                        }}
                        onClick={(e) => e.stopPropagation()}
                    />
                </div>
            )}
        </>
    );
}
