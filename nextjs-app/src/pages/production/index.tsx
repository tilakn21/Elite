/**
 * Production Dashboard - Home
 * Overview of manufacturing status with job list
 */

import { useState, useEffect, useCallback } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { productionService } from '@/services';
import type { ProductionStats, ProductionJob } from '@/types/production';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/production/styles';

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

export default function ProductionDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<ProductionStats | null>(null);
    const [jobs, setJobs] = useState<ProductionJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    const userName = authState.user?.name || 'Manager';

    const loadData = useCallback(async () => {
        try {
            const [statsData, jobsData] = await Promise.all([
                productionService.getStats(),
                productionService.getProductionJobs()
            ]);
            setStats(statsData);
            setJobs(jobsData);
        } catch (error) {
            console.error('Failed to load data:', error);
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        loadData();
    }, [loadData]);

    const handleStartProduction = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await productionService.startProduction(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'in_progress', progress: 0 } : job
                ));
                // Update stats
                setStats(prev => prev ? {
                    ...prev,
                    pendingJobs: prev.pendingJobs - 1,
                    activeJobs: prev.activeJobs + 1
                } : prev);
            }
        } catch (error) {
            console.error('Failed to start production:', error);
        } finally {
            setActionLoading(null);
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
                // Update stats
                setStats(prev => prev ? {
                    ...prev,
                    activeJobs: prev.activeJobs - 1,
                    completedToday: prev.completedToday + 1
                } : prev);
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

    // Group jobs
    const pendingJobs = jobs.filter(j => j.status === 'pending');
    const inProgressJobs = jobs.filter(j => j.status === 'in_progress');
    const atPrintingJobs = jobs.filter(j => j.status === 'at_printing');
    const framingJobs = jobs.filter(j => j.status === 'ready_for_framing' || j.status === 'framing_in_progress');
    const completedJobs = jobs.filter(j => j.status === 'completed');

    return (
        <>
            <Head>
                <title>Production Dashboard | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Welcome Section */}
                    <div css={styles.welcomeSection}>
                        <h1>Production Overview</h1>
                        <p>Managing manufacturing workflow for {userName}</p>
                    </div>

                    {/* Stats Grid */}
                    {stats && (
                        <div css={styles.statsGrid}>
                            <div css={styles.statCard('#F59E0B')}>
                                <div className="label">Pending Jobs</div>
                                <div className="value">{stats.pendingJobs}</div>
                            </div>
                            <div css={styles.statCard('#3B82F6')}>
                                <div className="label">Active Jobs</div>
                                <div className="value">{stats.activeJobs}</div>
                            </div>
                            <div css={styles.statCard('#10B981')}>
                                <div className="label">Completed Today</div>
                                <div className="value">{stats.completedToday}</div>
                            </div>
                            <div css={styles.statCard('#8B5CF6')}>
                                <div className="label">Available Workers</div>
                                <div className="value">{stats.availableWorkers}</div>
                            </div>
                        </div>
                    )}

                    {/* Job List */}
                    <div style={{ marginTop: '32px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                            <h2 style={{ fontSize: '20px', fontWeight: 600, color: '#1B2330', margin: 0 }}>
                                Production Jobs
                            </h2>
                            <button
                                onClick={() => router.push('/production/jobs')}
                                style={{
                                    padding: '8px 16px',
                                    background: 'transparent',
                                    border: '1px solid #E5E7EB',
                                    borderRadius: '8px',
                                    cursor: 'pointer',
                                    fontSize: '14px',
                                    fontWeight: 500,
                                }}
                            >
                                View All →
                            </button>
                        </div>

                        {jobs.length === 0 ? (
                            <div style={{
                                textAlign: 'center',
                                padding: '40px 20px',
                                background: '#F9FAFB',
                                borderRadius: '12px',
                                color: '#6B7280'
                            }}>
                                <p style={{ fontSize: '16px', marginBottom: '8px' }}>No production jobs</p>
                                <p style={{ fontSize: '14px' }}>Jobs will appear here after design approval</p>
                            </div>
                        ) : (
                            <>
                                {/* Pending Jobs */}
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                    <h3 style={{ fontSize: '18px', fontWeight: 600, color: '#1B2330', marginBottom: '8px' }}>
                                        📋 Pending Production
                                    </h3>
                                    {pendingJobs.length === 0 ? (
                                        <p style={{ color: '#9CA3AF', fontStyle: 'italic', marginBottom: '16px' }}>No pending jobs</p>
                                    ) : (
                                        pendingJobs.slice(0, 3).map(job => (
                                            <div
                                                key={job.id}
                                                style={{
                                                    background: 'white',
                                                    borderRadius: '12px',
                                                    padding: '16px 20px',
                                                    boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
                                                    display: 'flex',
                                                    justifyContent: 'space-between',
                                                    alignItems: 'center',
                                                    marginBottom: '16px'
                                                }}
                                            >
                                                <div
                                                    style={{ cursor: 'pointer' }}
                                                    onClick={() => router.push(`/production/jobs/${job.id}`)}
                                                >
                                                    <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                                                    <div style={{ color: '#6B7280', fontSize: '14px' }}>
                                                        #{job.jobCode} • {job.shopName}
                                                    </div>
                                                </div>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
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
                                                    <button
                                                        onClick={() => handleStartProduction(job.id)}
                                                        disabled={actionLoading === job.id}
                                                        style={{
                                                            padding: '8px 16px',
                                                            background: '#3B82F6',
                                                            color: 'white',
                                                            border: 'none',
                                                            borderRadius: '8px',
                                                            fontWeight: 500,
                                                            cursor: 'pointer',
                                                            fontSize: '13px',
                                                            opacity: actionLoading === job.id ? 0.7 : 1,
                                                        }}
                                                    >
                                                        {actionLoading === job.id ? '...' : 'Start'}
                                                    </button>
                                                </div>
                                            </div>
                                        ))
                                    )}
                                </div>

                                {/* In Progress Jobs */}
                                {inProgressJobs.length > 0 && (
                                    <div style={{ marginTop: '32px' }}>
                                        <h3 style={{ fontSize: '18px', fontWeight: 600, color: '#1B2330', marginBottom: '16px' }}>
                                            🏭 In Production ({inProgressJobs.length})
                                        </h3>
                                        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                            {inProgressJobs.map(job => (
                                                <div key={job.id} style={{ background: 'white', borderRadius: '12px', padding: '16px 20px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
                                                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                        <div style={{ cursor: 'pointer' }} onClick={() => router.push(`/production/jobs/${job.id}`)}>
                                                            <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                                                            <div style={{ color: '#6B7280', fontSize: '14px' }}>#{job.jobCode} • {job.shopName}</div>
                                                        </div>
                                                        <span style={{ padding: '4px 12px', borderRadius: '20px', fontSize: '12px', fontWeight: 500, background: getStatusInfo(job.status).bgColor, color: getStatusInfo(job.status).color }}>
                                                            {getStatusInfo(job.status).label}
                                                        </span>
                                                    </div>
                                                    <button
                                                        onClick={() => handleSendToPrinting(job.id)}
                                                        disabled={actionLoading === job.id}
                                                        style={{ marginTop: '12px', width: '100%', padding: '10px', background: '#F59E0B', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 500, cursor: 'pointer', fontSize: '13px', opacity: actionLoading === job.id ? 0.7 : 1 }}
                                                    >
                                                        {actionLoading === job.id ? 'Sending...' : '📤 Send to Printing'}
                                                    </button>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* At Printing (Read Only) */}
                                {atPrintingJobs.length > 0 && (
                                    <div style={{ marginTop: '32px' }}>
                                        <h3 style={{ fontSize: '18px', fontWeight: 600, color: '#1B2330', marginBottom: '16px' }}>
                                            🖨️ At Printing ({atPrintingJobs.length})
                                        </h3>
                                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '16px' }}>
                                            {atPrintingJobs.map(job => (
                                                <div key={job.id} style={{ background: '#F9FAFB', borderRadius: '12px', padding: '16px', border: '1px solid #E5E7EB' }}>
                                                    <div style={{ fontWeight: 600 }}>{job.customerName}</div>
                                                    <div style={{ fontSize: '14px', color: '#6B7280' }}>#{job.jobCode}</div>
                                                    <div style={{ marginTop: '8px', fontSize: '13px', color: '#B45309', background: '#FEF3C7', padding: '4px 8px', borderRadius: '4px', display: 'inline-block' }}>
                                                        Wait for Printing Completion
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Framing & Assembly */}
                                {framingJobs.length > 0 && (
                                    <div style={{ marginTop: '32px' }}>
                                        <h3 style={{ fontSize: '18px', fontWeight: 600, color: '#1B2330', marginBottom: '16px' }}>
                                            🖼️ Framing & Assembly ({framingJobs.length})
                                        </h3>
                                        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                            {framingJobs.map(job => (
                                                <div key={job.id} style={{ background: 'white', borderRadius: '12px', padding: '16px 20px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderLeft: '4px solid #4F46E5' }}>
                                                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                        <div>
                                                            <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                                                            <div style={{ color: '#6B7280', fontSize: '14px' }}>#{job.jobCode}</div>
                                                        </div>
                                                        {job.status === 'ready_for_framing' ? (
                                                            <button
                                                                onClick={() => handleStartFraming(job.id)}
                                                                disabled={actionLoading === job.id}
                                                                style={{ padding: '8px 16px', background: '#4F46E5', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 500 }}
                                                            >
                                                                {actionLoading === job.id ? 'Starting...' : 'Start Framing'}
                                                            </button>
                                                        ) : (
                                                            <button
                                                                onClick={() => handleCompleteProduction(job.id)}
                                                                disabled={actionLoading === job.id}
                                                                style={{ padding: '8px 16px', background: '#059669', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 500 }}
                                                            >
                                                                {actionLoading === job.id ? 'Completing...' : '✅ Complete Job'}
                                                            </button>
                                                        )}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Completed Jobs Preview */}
                                {completedJobs.length > 0 && completedJobs.slice(0, 2).map(job => (
                                    <div
                                        key={job.id}
                                        style={{
                                            background: '#F9FAFB',
                                            borderRadius: '12px',
                                            padding: '16px 20px',
                                            display: 'flex',
                                            justifyContent: 'space-between',
                                            alignItems: 'center',
                                            marginTop: '16px',
                                            opacity: 0.8,
                                        }}
                                    >
                                        <div
                                            style={{ cursor: 'pointer' }}
                                            onClick={() => router.push(`/production/jobs/${job.id}`)}
                                        >
                                            <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                                            <div style={{ color: '#6B7280', fontSize: '14px' }}>
                                                #{job.jobCode} • {job.shopName}
                                            </div>
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
                                ))}
                            </>
                        )}
                    </div>
                </div>
            </AppLayout >
        </>
    );
}
