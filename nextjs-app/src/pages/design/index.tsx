/**
 * Design Dashboard - Home
 * Overview of design department status with job list
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { designService } from '@/services';
import type { DesignStats, DesignJob } from '@/types/design';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/design/styles';

// Status badge colors
const getStatusStyle = (status: string) => {
    switch (status) {
        case 'pending':
            return { background: '#FEF3C7', color: '#92400E' };
        case 'in_progress':
            return { background: '#DBEAFE', color: '#1E40AF' };
        case 'draft_uploaded':
            return { background: '#E0E7FF', color: '#3730A3' };
        case 'approved':
            return { background: '#D1FAE5', color: '#065F46' };
        case 'completed':
            return { background: '#ECFDF5', color: '#047857' };
        default:
            return { background: '#F3F4F6', color: '#374151' };
    }
};

const formatStatus = (status: string) => {
    return status.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

export default function DesignDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<DesignStats | null>(null);
    const [jobs, setJobs] = useState<DesignJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    const designerName = authState.user?.name || 'Designer';

    useEffect(() => {
        async function loadData() {
            try {
                const [statsData, jobsData] = await Promise.all([
                    designService.getStats(),
                    designService.getDesignJobs()
                ]);
                setStats(statsData);
                setJobs(jobsData);
            } catch (error) {
                console.error('Failed to load data:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadData();
    }, []);

    const handleJobClick = (jobId: string) => {
        router.push(`/design/jobs?id=${jobId}`);
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

    return (
        <>
            <Head>
                <title>Design Dashboard | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Welcome Section */}
                    <div css={styles.welcomeSection}>
                        <h1>Welcome back, {designerName}</h1>
                        <p>Here's what's happening in the studio today.</p>
                    </div>

                    {/* Stats Grid */}
                    {stats && (
                        <div css={styles.statsGrid}>
                            <div css={styles.statCard('#F59E0B')}>
                                <div className="label">Pending Jobs</div>
                                <div className="value">{stats.pendingJobs}</div>
                            </div>
                            <div css={styles.statCard('#10B981')}>
                                <div className="label">Approved Today</div>
                                <div className="value">{stats.approvedToday}</div>
                            </div>
                            <div css={styles.statCard('#EF4444')}>
                                <div className="label">Corrections</div>
                                <div className="value">{stats.correctionsHere}</div>
                            </div>
                            <div css={styles.statCard('#3B82F6')}>
                                <div className="label">Total Completed</div>
                                <div className="value">{stats.totalCompleted}</div>
                            </div>
                        </div>
                    )}

                    {/* Job List Section */}
                    <h2 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '16px', color: '#1B2330' }}>
                        Jobs ({jobs.length})
                    </h2>

                    {jobs.length === 0 ? (
                        <div style={{
                            padding: '40px',
                            textAlign: 'center',
                            background: '#F9FAFB',
                            borderRadius: '12px',
                            color: '#6B7280'
                        }}>
                            No jobs assigned yet
                        </div>
                    ) : (
                        <div style={{
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '12px',
                        }}>
                            {jobs.map((job) => (
                                <div
                                    key={job.id}
                                    onClick={() => handleJobClick(job.id)}
                                    style={{
                                        display: 'flex',
                                        justifyContent: 'space-between',
                                        alignItems: 'center',
                                        padding: '16px 20px',
                                        background: 'white',
                                        borderRadius: '12px',
                                        boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
                                        cursor: 'pointer',
                                        transition: 'all 0.2s ease',
                                    }}
                                    onMouseEnter={(e) => {
                                        e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.12)';
                                        e.currentTarget.style.transform = 'translateY(-2px)';
                                    }}
                                    onMouseLeave={(e) => {
                                        e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.08)';
                                        e.currentTarget.style.transform = 'translateY(0)';
                                    }}
                                >
                                    <div style={{ flex: 1 }}>
                                        <div style={{ fontWeight: 600, color: '#1B2330', marginBottom: '4px' }}>
                                            {job.jobCode}
                                        </div>
                                        <div style={{ fontSize: '14px', color: '#6B7280' }}>
                                            {job.customerName} • {job.shopName || 'No shop'}
                                        </div>
                                    </div>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                        <span style={{
                                            padding: '4px 12px',
                                            borderRadius: '20px',
                                            fontSize: '12px',
                                            fontWeight: 500,
                                            ...getStatusStyle(job.status)
                                        }}>
                                            {formatStatus(job.status)}
                                        </span>
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" strokeWidth="2">
                                            <polyline points="9 18 15 12 9 6" />
                                        </svg>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </AppLayout>
        </>
    );
}
