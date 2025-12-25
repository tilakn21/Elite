/**
 * Production - Job List & Status Updates
 * Start production, update progress, mark complete
 */

import { useState, useEffect, useCallback } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { productionService } from '@/services';
import type { ProductionJob } from '@/types/production';
import * as styles from '@/styles/pages/production/update-status.styles';

// Status badge helper
const getStatusInfo = (status: string): { label: string; color: string; bgColor: string } => {
    const statusMap: Record<string, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' },
        in_progress: { label: 'In Production', color: '#1E40AF', bgColor: '#DBEAFE' },
        at_printing: { label: 'At Printing', color: '#B45309', bgColor: '#FEF3C7' },
        ready_for_framing: { label: 'Ready for Framing', color: '#3730A3', bgColor: '#E0E7FF' },
        framing_in_progress: { label: 'Framing', color: '#4F46E5', bgColor: '#EEF2FF' },
        completed: { label: 'Completed', color: '#065F46', bgColor: '#D1FAE5' },
    };
    return statusMap[status] || { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' };
};

export default function ProductionJobsPage() {
    const theme = useTheme();
    const router = useRouter();

    const [jobs, setJobs] = useState<ProductionJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    const loadJobs = useCallback(async () => {
        try {
            const data = await productionService.getProductionJobs();
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

    const handleStartProduction = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await productionService.startProduction(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'in_progress', progress: 0 } : job
                ));
            }
        } catch (error) {
            console.error('Failed to start production:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleProgressUpdate = async (jobId: string, newProgress: number) => {
        try {
            await productionService.updateProgress(jobId, newProgress);
            setJobs(prev => prev.map(job =>
                job.id === jobId ? { ...job, progress: newProgress } : job
            ));
        } catch (error) {
            console.error('Failed to update progress:', error);
        }
    };

    const handleSendToPrinting = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await productionService.sendToPrinting(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'at_printing', progress: 50 } : job
                ));
            }
        } catch (error) {
            console.error('Failed to send to printing:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleStartFraming = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await productionService.startFraming(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'framing_in_progress', progress: 75 } : job
                ));
            }
        } catch (error) {
            console.error('Failed to start framing:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleCompleteProduction = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await productionService.completeProduction(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'completed', progress: 100 } : job
                ));
            }
        } catch (error) {
            console.error('Failed to complete production:', error);
        } finally {
            setActionLoading(null);
        }
    };


    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loadingContainer}>
                    <div css={styles.spinnerAnimation} />
                </div>
            </AppLayout>
        );
    }

    // Group jobs by status
    const pendingJobs = jobs.filter(j => j.status === 'pending');
    const inProgressJobs = jobs.filter(j => j.status === 'in_progress');
    const atPrintingJobs = jobs.filter(j => j.status === 'at_printing');
    const framingJobs = jobs.filter(j => j.status === 'ready_for_framing' || j.status === 'framing_in_progress');
    const completedJobs = jobs.filter(j => j.status === 'completed');


    return (
        <>
            <Head>
                <title>Production Jobs | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <h1>Production Jobs</h1>
                        <p style={{ color: '#6B7280', marginTop: '4px' }}>
                            Manage job progress and workflow
                        </p>
                    </div>

                    {jobs.length === 0 ? (
                        <div style={{
                            textAlign: 'center',
                            padding: '60px 20px',
                            color: '#6B7280'
                        }}>
                            <p style={{ fontSize: '18px', marginBottom: '8px' }}>No production jobs</p>
                            <p>Jobs will appear here after design approval</p>
                        </div>
                    ) : (
                        <>
                            {/* Pending Jobs */}
                            {pendingJobs.length > 0 && (
                                <div style={{ marginBottom: '32px' }}>
                                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#92400E' }}>
                                        ⏳ Pending ({pendingJobs.length})
                                    </h2>
                                    {pendingJobs.map(job => (
                                        <div key={job.id} css={styles.jobCard}>
                                            <div
                                                className="header"
                                                onClick={() => router.push(`/production/jobs/${job.id}`)}
                                                style={{ cursor: 'pointer' }}
                                            >
                                                <div>
                                                    <h3>{job.customerName}</h3>
                                                    <p style={{ color: '#6B7280', fontSize: '14px' }}>
                                                        #{job.jobCode} • {job.shopName}
                                                    </p>
                                                </div>
                                                <span style={{
                                                    padding: '4px 12px',
                                                    borderRadius: '20px',
                                                    fontSize: '12px',
                                                    fontWeight: 500,
                                                    background: getStatusInfo(job.status).bgColor,
                                                    color: getStatusInfo(job.status).color,
                                                }}>
                                                    {getStatusInfo(job.status).label}
                                                </span>
                                            </div>
                                            <button
                                                onClick={() => handleStartProduction(job.id)}
                                                disabled={actionLoading === job.id}
                                                style={{
                                                    marginTop: '16px',
                                                    width: '100%',
                                                    padding: '12px',
                                                    background: '#3B82F6',
                                                    color: 'white',
                                                    border: 'none',
                                                    borderRadius: '8px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer',
                                                    opacity: actionLoading === job.id ? 0.7 : 1,
                                                }}
                                            >
                                                {actionLoading === job.id ? 'Starting...' : '▶️ Start Production'}
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* In Progress Jobs */}
                            {inProgressJobs.length > 0 && (
                                <div style={{ marginBottom: '32px' }}>
                                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#1E40AF' }}>
                                        🔨 In Progress ({inProgressJobs.length})
                                    </h2>
                                    {inProgressJobs.map(job => (
                                        <div key={job.id} css={styles.jobCard}>
                                            <div
                                                className="header"
                                                onClick={() => router.push(`/production/jobs/${job.id}`)}
                                                style={{ cursor: 'pointer' }}
                                            >
                                                <div>
                                                    <h3>{job.customerName}</h3>
                                                    <p style={{ color: '#6B7280', fontSize: '14px' }}>
                                                        #{job.jobCode} • {job.shopName}
                                                    </p>
                                                </div>
                                                <span style={{
                                                    padding: '4px 12px',
                                                    borderRadius: '20px',
                                                    fontSize: '12px',
                                                    fontWeight: 500,
                                                    background: getStatusInfo(job.status).bgColor,
                                                    color: getStatusInfo(job.status).color,
                                                }}>
                                                    {getStatusInfo(job.status).label}
                                                </span>
                                            </div>

                                            {/* Progress Bar */}
                                            <div style={{ marginTop: '16px' }}>
                                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                                                    <span style={{ fontSize: '14px', fontWeight: 500 }}>Progress</span>
                                                    <span style={{ fontSize: '14px', color: '#3B82F6', fontWeight: 600 }}>{job.progress}%</span>
                                                </div>
                                                <input
                                                    type="range"
                                                    min="0"
                                                    max="100"
                                                    value={job.progress}
                                                    onChange={(e) => handleProgressUpdate(job.id, parseInt(e.target.value))}
                                                    style={{
                                                        width: '100%',
                                                        height: '8px',
                                                        borderRadius: '4px',
                                                        appearance: 'none',
                                                        background: `linear-gradient(to right, #3B82F6 ${job.progress}%, #E5E7EB ${job.progress}%)`,
                                                        cursor: 'pointer',
                                                    }}
                                                />
                                            </div>

                                            <button
                                                onClick={() => handleSendToPrinting(job.id)}
                                                disabled={actionLoading === job.id}
                                                style={{
                                                    marginTop: '16px',
                                                    width: '100%',
                                                    padding: '12px',
                                                    background: '#F59E0B', // Amber
                                                    color: 'white',
                                                    border: 'none',
                                                    borderRadius: '8px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer',
                                                    opacity: actionLoading === job.id ? 0.7 : 1,
                                                }}
                                            >
                                                {actionLoading === job.id ? 'Sending...' : '📤 Send to Printing'}
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* At Printing */}
                            {atPrintingJobs.length > 0 && (
                                <div style={{ marginBottom: '32px' }}>
                                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#B45309' }}>
                                        🖨️ At Printing ({atPrintingJobs.length})
                                    </h2>
                                    {atPrintingJobs.map(job => (
                                        <div key={job.id} css={styles.jobCard} style={{ opacity: 0.9 }}>
                                            <div
                                                className="header"
                                                onClick={() => router.push(`/production/jobs/${job.id}`)}
                                                style={{ cursor: 'pointer' }}
                                            >
                                                <div>
                                                    <h3>{job.customerName}</h3>
                                                    <p style={{ color: '#6B7280', fontSize: '14px' }}>
                                                        #{job.jobCode} • {job.shopName}
                                                    </p>
                                                </div>
                                                <span style={{
                                                    padding: '4px 12px',
                                                    borderRadius: '20px',
                                                    fontSize: '12px',
                                                    fontWeight: 500,
                                                    background: getStatusInfo(job.status).bgColor,
                                                    color: getStatusInfo(job.status).color,
                                                }}>
                                                    {getStatusInfo(job.status).label}
                                                </span>
                                            </div>
                                            <div style={{ marginTop: '12px', padding: '12px', background: '#FFF7ED', borderRadius: '8px', color: '#9A3412', textAlign: 'center', fontSize: '14px' }}>
                                                Wait for printing to complete...
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* Framing */}
                            {framingJobs.length > 0 && (
                                <div style={{ marginBottom: '32px' }}>
                                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#4F46E5' }}>
                                        🖼️ Framing & Assembly ({framingJobs.length})
                                    </h2>
                                    {framingJobs.map(job => (
                                        <div key={job.id} css={styles.jobCard}>
                                            <div
                                                className="header"
                                                onClick={() => router.push(`/production/jobs/${job.id}`)}
                                                style={{ cursor: 'pointer' }}
                                            >
                                                <div>
                                                    <h3>{job.customerName}</h3>
                                                    <p style={{ color: '#6B7280', fontSize: '14px' }}>
                                                        #{job.jobCode} • {job.shopName}
                                                    </p>
                                                </div>
                                                <span style={{
                                                    padding: '4px 12px',
                                                    borderRadius: '20px',
                                                    fontSize: '12px',
                                                    fontWeight: 500,
                                                    background: getStatusInfo(job.status).bgColor,
                                                    color: getStatusInfo(job.status).color,
                                                }}>
                                                    {getStatusInfo(job.status).label}
                                                </span>
                                            </div>
                                            {job.status === 'ready_for_framing' ? (
                                                <button
                                                    onClick={() => handleStartFraming(job.id)}
                                                    disabled={actionLoading === job.id}
                                                    style={{ marginTop: '16px', width: '100%', padding: '12px', background: '#4F46E5', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}
                                                >
                                                    {actionLoading === job.id ? 'Starting...' : '🖼️ Start Framing'}
                                                </button>
                                            ) : (
                                                <button
                                                    onClick={() => handleCompleteProduction(job.id)}
                                                    disabled={actionLoading === job.id}
                                                    style={{ marginTop: '16px', width: '100%', padding: '12px', background: '#10B981', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 600, cursor: 'pointer' }}
                                                >
                                                    {actionLoading === job.id ? 'Completing...' : '✅ Complete Job'}
                                                </button>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* Completed Jobs */}
                            {completedJobs.length > 0 && (
                                <div>
                                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#065F46' }}>
                                        ✅ Completed ({completedJobs.length})
                                    </h2>
                                    {completedJobs.map(job => (
                                        <div key={job.id} css={styles.jobCard} style={{ opacity: 0.8 }}>
                                            <div
                                                className="header"
                                                onClick={() => router.push(`/production/jobs/${job.id}`)}
                                                style={{ cursor: 'pointer' }}
                                            >
                                                <div>
                                                    <h3>{job.customerName}</h3>
                                                    <p style={{ color: '#6B7280', fontSize: '14px' }}>
                                                        #{job.jobCode} • {job.shopName}
                                                    </p>
                                                </div>
                                                <span style={{
                                                    padding: '4px 12px',
                                                    borderRadius: '20px',
                                                    fontSize: '12px',
                                                    fontWeight: 500,
                                                    background: getStatusInfo(job.status).bgColor,
                                                    color: getStatusInfo(job.status).color,
                                                }}>
                                                    {getStatusInfo(job.status).label}
                                                </span>
                                            </div>
                                            <div style={{
                                                marginTop: '12px',
                                                padding: '12px',
                                                background: '#D1FAE5',
                                                borderRadius: '8px',
                                                color: '#065F46',
                                                fontSize: '14px',
                                                textAlign: 'center'
                                            }}>
                                                Production complete!
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </>
                    )}
                </div>
            </AppLayout>
        </>
    );
}
