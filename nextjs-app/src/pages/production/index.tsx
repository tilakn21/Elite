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
        in_progress: { label: 'In Progress', color: '#1E40AF', bgColor: '#DBEAFE' },
        ready_for_printing: { label: 'Ready for Printing', color: '#065F46', bgColor: '#D1FAE5' },
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

    const handleMarkComplete = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await productionService.markReadyForPrinting(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'ready_for_printing', progress: 100 } : job
                ));
                // Update stats
                setStats(prev => prev ? {
                    ...prev,
                    activeJobs: prev.activeJobs - 1,
                    completedToday: prev.completedToday + 1
                } : prev);
            }
        } catch (error) {
            console.error('Failed to mark complete:', error);
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
    const completedJobs = jobs.filter(j => j.status === 'ready_for_printing');

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
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                {/* Pending Jobs */}
                                {pendingJobs.slice(0, 3).map(job => (
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
                                ))}

                                {/* In Progress Jobs */}
                                {inProgressJobs.slice(0, 3).map(job => (
                                    <div
                                        key={job.id}
                                        style={{
                                            background: 'white',
                                            borderRadius: '12px',
                                            padding: '16px 20px',
                                            boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
                                        }}
                                    >
                                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
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
                                        {/* Progress bar */}
                                        <div style={{ marginTop: '12px' }}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                                                <span style={{ fontSize: '12px', color: '#6B7280' }}>Progress</span>
                                                <span style={{ fontSize: '12px', fontWeight: 600, color: '#3B82F6' }}>{job.progress}%</span>
                                            </div>
                                            <div style={{ height: '6px', background: '#E5E7EB', borderRadius: '3px', overflow: 'hidden' }}>
                                                <div style={{ height: '100%', width: `${job.progress}%`, background: '#3B82F6', borderRadius: '3px' }} />
                                            </div>
                                        </div>
                                        <button
                                            onClick={() => handleMarkComplete(job.id)}
                                            disabled={actionLoading === job.id}
                                            style={{
                                                marginTop: '12px',
                                                width: '100%',
                                                padding: '10px',
                                                background: '#10B981',
                                                color: 'white',
                                                border: 'none',
                                                borderRadius: '8px',
                                                fontWeight: 500,
                                                cursor: 'pointer',
                                                fontSize: '13px',
                                                opacity: actionLoading === job.id ? 0.7 : 1,
                                            }}
                                        >
                                            {actionLoading === job.id ? 'Completing...' : '✅ Mark Ready for Printing'}
                                        </button>
                                    </div>
                                ))}

                                {/* Completed Jobs Preview */}
                                {completedJobs.slice(0, 2).map(job => (
                                    <div
                                        key={job.id}
                                        style={{
                                            background: '#F9FAFB',
                                            borderRadius: '12px',
                                            padding: '16px 20px',
                                            display: 'flex',
                                            justifyContent: 'space-between',
                                            alignItems: 'center',
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
                            </div>
                        )}
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
