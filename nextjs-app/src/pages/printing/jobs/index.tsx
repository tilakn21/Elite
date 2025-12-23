/**
 * Printing Jobs - Full Queue List
 */

import { useState, useEffect, useCallback } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { AppLayout } from '@/components/layout';
import { printingService } from '@/services';
import type { PrintingJob } from '@/types/printing';
import { css } from '@emotion/react';

// Status badge helper
const getStatusInfo = (status: string): { label: string; color: string; bgColor: string } => {
    const statusMap: Record<string, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'In Queue', color: '#92400E', bgColor: '#FEF3C7' },
        print_started: { label: 'Printing', color: '#1E40AF', bgColor: '#DBEAFE' },
        print_completed: { label: 'Completed', color: '#065F46', bgColor: '#D1FAE5' },
    };
    return statusMap[status] || { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' };
};

const styles = {
    container: css`
        max-width: 1000px;
        margin: 0 auto;
        padding: 24px;
    `,
    header: css`
        margin-bottom: 24px;
        h1 { font-size: 24px; font-weight: 700; margin: 0; }
        p { color: #6B7280; margin: 4px 0 0 0; }
    `,
    loading: css`
        display: flex;
        justify-content: center;
        align-items: center;
        height: 200px;
    `,
};

export default function PrintingJobsPage() {
    const router = useRouter();

    const [jobs, setJobs] = useState<PrintingJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    const loadJobs = useCallback(async () => {
        try {
            const data = await printingService.getPrintingJobs();
            setJobs(data);
        } catch (error) {
            console.error('Failed to load jobs:', error);
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        loadJobs();
    }, [loadJobs]);

    const handleStartPrinting = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await printingService.startPrinting(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'print_started' } : job
                ));
            }
        } finally {
            setActionLoading(null);
        }
    };

    const handleMarkComplete = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await printingService.markPrintCompleted(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'print_completed' } : job
                ));
            }
        } finally {
            setActionLoading(null);
        }
    };

    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loading}>Loading...</div>
            </AppLayout>
        );
    }

    // Group jobs
    const pendingJobs = jobs.filter(j => j.status === 'pending');
    const activeJobs = jobs.filter(j => j.status === 'print_started');
    const completedJobs = jobs.filter(j => j.status === 'print_completed');

    return (
        <>
            <Head>
                <title>Print Queue | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.container}>
                    <div css={styles.header}>
                        <h1>Print Queue</h1>
                        <p>All print jobs ordered by arrival</p>
                    </div>

                    {jobs.length === 0 ? (
                        <div style={{ textAlign: 'center', padding: '60px', color: '#6B7280' }}>
                            No print jobs available
                        </div>
                    ) : (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                            {/* Pending Jobs */}
                            {pendingJobs.length > 0 && (
                                <div style={{ marginBottom: '24px' }}>
                                    <h2 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '12px', color: '#92400E' }}>
                                        📋 In Queue ({pendingJobs.length})
                                    </h2>
                                    {pendingJobs.map(job => (
                                        <JobCard
                                            key={job.id}
                                            job={job}
                                            onAction={() => handleStartPrinting(job.id)}
                                            actionLabel="▶️ Start"
                                            actionColor="#3B82F6"
                                            actionLoading={actionLoading === job.id}
                                            onClick={() => router.push(`/printing/jobs/${job.id}`)}
                                        />
                                    ))}
                                </div>
                            )}

                            {/* Active Jobs */}
                            {activeJobs.length > 0 && (
                                <div style={{ marginBottom: '24px' }}>
                                    <h2 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '12px', color: '#1E40AF' }}>
                                        🖨️ Currently Printing ({activeJobs.length})
                                    </h2>
                                    {activeJobs.map(job => (
                                        <JobCard
                                            key={job.id}
                                            job={job}
                                            onAction={() => handleMarkComplete(job.id)}
                                            actionLabel="✅ Complete"
                                            actionColor="#10B981"
                                            actionLoading={actionLoading === job.id}
                                            onClick={() => router.push(`/printing/jobs/${job.id}`)}
                                            highlight
                                        />
                                    ))}
                                </div>
                            )}

                            {/* Completed Jobs */}
                            {completedJobs.length > 0 && (
                                <div>
                                    <h2 style={{ fontSize: '16px', fontWeight: 600, marginBottom: '12px', color: '#065F46' }}>
                                        ✅ Completed ({completedJobs.length})
                                    </h2>
                                    {completedJobs.map(job => (
                                        <JobCard
                                            key={job.id}
                                            job={job}
                                            onClick={() => router.push(`/printing/jobs/${job.id}`)}
                                            completed
                                        />
                                    ))}
                                </div>
                            )}
                        </div>
                    )}
                </div>
            </AppLayout>
        </>
    );
}

// Job Card Component
function JobCard({
    job,
    onAction,
    actionLabel,
    actionColor,
    actionLoading,
    onClick,
    highlight,
    completed,
}: {
    job: PrintingJob;
    onAction?: () => void;
    actionLabel?: string;
    actionColor?: string;
    actionLoading?: boolean;
    onClick: () => void;
    highlight?: boolean;
    completed?: boolean;
}) {
    const statusInfo = getStatusInfo(job.status);

    return (
        <div
            style={{
                background: completed ? '#F9FAFB' : highlight ? 'linear-gradient(135deg, #EFF6FF 0%, white 100%)' : 'white',
                borderRadius: '12px',
                padding: '16px',
                marginBottom: '12px',
                boxShadow: completed ? 'none' : '0 1px 3px rgba(0,0,0,0.1)',
                border: highlight ? '2px solid #3B82F6' : 'none',
                display: 'flex',
                gap: '16px',
                alignItems: 'center',
                opacity: completed ? 0.7 : 1,
            }}
        >
            {/* Queue Number */}
            <div style={{
                width: '48px',
                height: '48px',
                background: completed ? '#D1FAE5' : highlight ? '#3B82F6' : '#FEF3C7',
                borderRadius: '12px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700,
                fontSize: completed ? '24px' : highlight ? '24px' : '20px',
                color: highlight ? 'white' : '#92400E',
                flexShrink: 0,
            }}>
                {completed ? '✅' : highlight ? '🖨️' : `#${job.queueNumber}`}
            </div>

            {/* Design Thumbnail */}
            {job.designImageUrl && (
                <img
                    src={job.designImageUrl}
                    alt="Design"
                    onClick={(e) => { e.stopPropagation(); onClick(); }}
                    style={{
                        width: '80px',
                        height: '60px',
                        objectFit: 'cover',
                        borderRadius: '8px',
                        cursor: 'pointer',
                        flexShrink: 0,
                        border: '1px solid #E5E7EB',
                    }}
                />
            )}

            {/* Job Info */}
            <div style={{ flex: 1, cursor: 'pointer' }} onClick={onClick}>
                <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                <div style={{ color: '#6B7280', fontSize: '14px' }}>
                    #{job.jobCode} • {job.shopName}
                </div>
            </div>

            {/* Status */}
            <span style={{
                padding: '4px 12px',
                borderRadius: '20px',
                fontSize: '12px',
                fontWeight: 500,
                background: statusInfo.bgColor,
                color: statusInfo.color,
            }}>
                {statusInfo.label}
            </span>

            {/* Action Button */}
            {onAction && (
                <button
                    onClick={(e) => { e.stopPropagation(); onAction(); }}
                    disabled={actionLoading}
                    style={{
                        padding: '8px 16px',
                        background: actionColor,
                        color: 'white',
                        border: 'none',
                        borderRadius: '8px',
                        fontWeight: 500,
                        cursor: 'pointer',
                        fontSize: '13px',
                        opacity: actionLoading ? 0.7 : 1,
                    }}
                >
                    {actionLoading ? '...' : actionLabel}
                </button>
            )}
        </div>
    );
}
