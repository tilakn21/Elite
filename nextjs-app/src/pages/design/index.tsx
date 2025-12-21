/**
 * Design Dashboard - Home
 * Overview of design department status
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { designService } from '@/services';
import type { DesignStats } from '@/types/design';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/design/styles';

export default function DesignDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<DesignStats | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    const designerName = authState.user?.name || 'Designer';

    useEffect(() => {
        async function loadStats() {
            try {
                const data = await designService.getStats();
                setStats(data);
            } catch (error) {
                console.error('Failed to load stats:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadStats();
    }, []);

    const navigateTo = (path: string) => {
        router.push(path);
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

                    {/* Quick Actions */}
                    <h2 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '24px', color: '#1B2330' }}>
                        Quick Actions
                    </h2>
                    <div css={styles.actionGrid}>
                        <div css={styles.actionCard()} onClick={() => navigateTo('/design/joblist')}>
                            <div className="icon-box">
                                <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
                            </div>
                            <div className="info">
                                <h3>View Job List</h3>
                                <p>Check assigned jobs and start working</p>
                            </div>
                        </div>

                        <div css={styles.actionCard()} onClick={() => navigateTo('/design/calendar')}>
                            <div className="icon-box" style={{ background: '#FFF7ED', color: '#EA580C' }}>
                                <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                            </div>
                            <div className="info">
                                <h3>Calendar</h3>
                                <p>View deadlines and appointments</p>
                            </div>
                        </div>

                        <div css={styles.actionCard()} onClick={() => navigateTo('/design/reimbursement_request')}>
                            <div className="icon-box" style={{ background: '#ECFDF5', color: '#059669' }}>
                                <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                            </div>
                            <div className="info">
                                <h3>Reimbursements</h3>
                                <p>Manage expense claims</p>
                            </div>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
