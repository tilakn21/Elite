/**
 * Production Dashboard - Home
 * Overview of manufacturing status
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { productionService } from '@/services';
import type { ProductionStats } from '@/types/production';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/production/styles';

export default function ProductionDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<ProductionStats | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    const userName = authState.user?.name || 'Manager';

    useEffect(() => {
        async function loadStats() {
            try {
                const data = await productionService.getStats();
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
                            <div css={styles.statCard('#3B82F6')}>
                                <div className="label">Active Jobs</div>
                                <div className="value">{stats.activeJobs}</div>
                            </div>
                            <div css={styles.statCard('#10B981')}>
                                <div className="label">Available Workers</div>
                                <div className="value">{stats.availableWorkers}</div>
                            </div>
                            <div css={styles.statCard('#8B5CF6')}>
                                <div className="label">Completed Today</div>
                                <div className="value">{stats.completedToday}</div>
                            </div>
                            <div css={styles.statCard('#EF4444')}>
                                <div className="label">Delayed Jobs</div>
                                <div className="value">{stats.delayedJobs}</div>
                            </div>
                        </div>
                    )}

                    {/* Quick Actions */}
                    <h2 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '24px', color: '#1B2330' }}>
                        Production Managment
                    </h2>
                    <div css={styles.actionGrid}>
                        <div css={styles.actionCard(theme)} onClick={() => navigateTo('/production/assign-labour')}>
                            <div className="icon-box" style={{ background: '#E0E7FF', color: '#3730A3' }}>
                                👷‍♂️
                            </div>
                            <div className="info">
                                <h3>Assign Labour</h3>
                                <p>Allocate workers to active jobs</p>
                            </div>
                        </div>

                        <div css={styles.actionCard(theme)} onClick={() => navigateTo('/production/update-status')}>
                            <div className="icon-box" style={{ background: '#ECFDF5', color: '#065F46' }}>
                                📊
                            </div>
                            <div className="info">
                                <h3>Update Status</h3>
                                <p>Move jobs through workflow stages</p>
                            </div>
                        </div>

                        <div css={styles.actionCard(theme)} onClick={() => navigateTo('/production/calendar')}>
                            <div className="icon-box" style={{ background: '#FFF7ED', color: '#9A3412' }}>
                                📅
                            </div>
                            <div className="info">
                                <h3>Schedule</h3>
                                <p>View production timeline</p>
                            </div>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
