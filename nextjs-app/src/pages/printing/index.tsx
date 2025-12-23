/**
 * Printing Dashboard - Home
 * Overview with stats and print queue
 */

import { useState, useEffect, useCallback } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { printingService } from '@/services';
import type { PrintingStats, PrintingJob } from '@/types/printing';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/printing/styles';

// Status badge helper
const getStatusInfo = (status: string): { label: string; color: string; bgColor: string } => {
    const statusMap: Record<string, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'In Queue', color: '#92400E', bgColor: '#FEF3C7' },
        print_started: { label: 'Printing', color: '#1E40AF', bgColor: '#DBEAFE' },
        print_completed: { label: 'Completed', color: '#065F46', bgColor: '#D1FAE5' },
    };
    return statusMap[status] || { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' };
};

export default function PrintingDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<PrintingStats | null>(null);
    const [jobs, setJobs] = useState<PrintingJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    const userName = authState.user?.name || 'Operator';

    const loadData = useCallback(async () => {
        try {
            const [statsData, jobsData] = await Promise.all([
                printingService.getStats(),
                printingService.getPrintingJobs()
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

    const handleStartPrinting = async (jobId: string) => {
        setActionLoading(jobId);
        try {
            const success = await printingService.startPrinting(jobId);
            if (success) {
                setJobs(prev => prev.map(job =>
                    job.id === jobId ? { ...job, status: 'print_started' } : job
                ));
                setStats(prev => prev ? {
                    ...prev,
                    pendingJobs: prev.pendingJobs - 1,
                    activeJobs: prev.activeJobs + 1
                } : prev);
            }
        } catch (error) {
            console.error('Failed to start printing:', error);
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
    const activeJobs = jobs.filter(j => j.status === 'print_started');
    const completedJobs = jobs.filter(j => j.status === 'print_completed');

    return (
        <>
            <Head>
                <title>Printing Dashboard | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Welcome Section */}
                    <div css={styles.welcomeSection}>
                        <h1>Printing Dashboard</h1>
                        <p>Managing print jobs for {userName}</p>
                    </div>

                    {/* Stats Grid */}
                    {stats && (
                        <div css={styles.statsGrid}>
                            <div css={styles.statCard('#F59E0B')}>
                                <div className="label">In Queue</div>
                                <div className="value">{stats.pendingJobs}</div>
                            </div>
                            <div css={styles.statCard('#3B82F6')}>
                                <div className="label">Currently Printing</div>
                                <div className="value">{stats.activeJobs}</div>
                            </div>
                            <div css={styles.statCard('#10B981')}>
                                <div className="label">Completed Today</div>
                                <div className="value">{stats.completedToday}</div>
                            </div>
                        </div>
                    )}

                    {/* Print Queue */}
                    <div style={{ marginTop: '32px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                            <h2 style={{ fontSize: '20px', fontWeight: 600, color: '#1B2330', margin: 0 }}>
                                🖨️ Print Queue
                            </h2>
                            <button
                                onClick={() => router.push('/printing/jobs')}
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
                                <p style={{ fontSize: '16px', marginBottom: '8px' }}>No print jobs</p>
                                <p style={{ fontSize: '14px' }}>Jobs will appear here after production is complete</p>
                            </div>
                        ) : (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                {/* Pending Jobs (Queue) */}
                                {pendingJobs.map(job => (
                                    <div
                                        key={job.id}
                                        style={{
                                            background: 'white',
                                            borderRadius: '12px',
                                            padding: '16px',
                                            boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
                                            display: 'flex',
                                            gap: '16px',
                                            alignItems: 'center',
                                        }}
                                    >
                                        {/* Queue Number */}
                                        <div style={{
                                            width: '48px',
                                            height: '48px',
                                            background: '#FEF3C7',
                                            borderRadius: '12px',
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontWeight: 700,
                                            fontSize: '20px',
                                            color: '#92400E',
                                            flexShrink: 0,
                                        }}>
                                            #{job.queueNumber}
                                        </div>

                                        {/* Design Thumbnail */}
                                        {job.designImageUrl && (
                                            <img
                                                src={job.designImageUrl}
                                                alt="Design"
                                                onClick={() => router.push(`/printing/jobs/${job.id}`)}
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
                                        <div
                                            style={{ flex: 1, cursor: 'pointer' }}
                                            onClick={() => router.push(`/printing/jobs/${job.id}`)}
                                        >
                                            <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                                            <div style={{ color: '#6B7280', fontSize: '14px' }}>
                                                #{job.jobCode} • {job.shopName}
                                            </div>
                                            {job.material && (
                                                <div style={{ color: '#9CA3AF', fontSize: '12px', marginTop: '4px' }}>
                                                    {job.material} • {job.dimensions}
                                                </div>
                                            )}
                                        </div>

                                        {/* Status + Action */}
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
                                                onClick={(e) => { e.stopPropagation(); handleStartPrinting(job.id); }}
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
                                                {actionLoading === job.id ? '...' : '▶️ Start'}
                                            </button>
                                        </div>
                                    </div>
                                ))}

                                {/* Active Jobs */}
                                {activeJobs.map(job => (
                                    <div
                                        key={job.id}
                                        style={{
                                            background: 'linear-gradient(135deg, #EFF6FF 0%, white 100%)',
                                            borderRadius: '12px',
                                            padding: '16px',
                                            border: '2px solid #3B82F6',
                                            display: 'flex',
                                            gap: '16px',
                                            alignItems: 'center',
                                        }}
                                    >
                                        {/* Printing Indicator */}
                                        <div style={{
                                            width: '48px',
                                            height: '48px',
                                            background: '#3B82F6',
                                            borderRadius: '12px',
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontSize: '24px',
                                            flexShrink: 0,
                                        }}>
                                            🖨️
                                        </div>

                                        {/* Design Thumbnail */}
                                        {job.designImageUrl && (
                                            <img
                                                src={job.designImageUrl}
                                                alt="Design"
                                                onClick={() => router.push(`/printing/jobs/${job.id}`)}
                                                style={{
                                                    width: '80px',
                                                    height: '60px',
                                                    objectFit: 'cover',
                                                    borderRadius: '8px',
                                                    cursor: 'pointer',
                                                    flexShrink: 0,
                                                    border: '1px solid #93C5FD',
                                                }}
                                            />
                                        )}

                                        {/* Job Info */}
                                        <div
                                            style={{ flex: 1, cursor: 'pointer' }}
                                            onClick={() => router.push(`/printing/jobs/${job.id}`)}
                                        >
                                            <div style={{ fontWeight: 600, fontSize: '16px' }}>{job.customerName}</div>
                                            <div style={{ color: '#6B7280', fontSize: '14px' }}>
                                                #{job.jobCode} • {job.shopName}
                                            </div>
                                            <div style={{ color: '#3B82F6', fontSize: '12px', marginTop: '4px', fontWeight: 500 }}>
                                                🔄 Currently printing...
                                            </div>
                                        </div>

                                        {/* Complete Button */}
                                        <button
                                            onClick={(e) => { e.stopPropagation(); handleMarkComplete(job.id); }}
                                            disabled={actionLoading === job.id}
                                            style={{
                                                padding: '10px 20px',
                                                background: '#10B981',
                                                color: 'white',
                                                border: 'none',
                                                borderRadius: '8px',
                                                fontWeight: 600,
                                                cursor: 'pointer',
                                                fontSize: '13px',
                                                opacity: actionLoading === job.id ? 0.7 : 1,
                                            }}
                                        >
                                            {actionLoading === job.id ? '...' : '✅ Complete'}
                                        </button>
                                    </div>
                                ))}

                                {/* Completed Jobs (show last 2) */}
                                {completedJobs.slice(0, 2).map(job => (
                                    <div
                                        key={job.id}
                                        style={{
                                            background: '#F9FAFB',
                                            borderRadius: '12px',
                                            padding: '16px',
                                            display: 'flex',
                                            gap: '16px',
                                            alignItems: 'center',
                                            opacity: 0.7,
                                        }}
                                    >
                                        {/* Completed Icon */}
                                        <div style={{
                                            width: '48px',
                                            height: '48px',
                                            background: '#D1FAE5',
                                            borderRadius: '12px',
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontSize: '24px',
                                            flexShrink: 0,
                                        }}>
                                            ✅
                                        </div>

                                        {/* Job Info */}
                                        <div style={{ flex: 1 }}>
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
