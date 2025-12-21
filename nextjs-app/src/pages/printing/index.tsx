/**
 * Printing Dashboard - Home
 * Overview of printing queue and resources
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { printingService } from '@/services';
import type { PrintingStats } from '@/types/printing';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/printing/styles';

export default function PrintingDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<PrintingStats | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    const userName = authState.user?.name || 'Printer';

    useEffect(() => {
        async function loadStats() {
            try {
                const data = await printingService.getStats();
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
                <title>Printing Dashboard | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Welcome Section */}
                    <div css={styles.welcomeSection}>
                        <h1>Printing Hub</h1>
                        <p>Managing large format printing for {userName}</p>
                    </div>

                    {/* Stats Grid */}
                    {stats && (
                        <div css={styles.statsGrid}>
                            <div css={styles.statCard('#3B82F6')}>
                                <div className="label">Jobs in Queue</div>
                                <div className="value">{stats.jobsInQueue}</div>
                            </div>
                            <div css={styles.statCard('#10B981')}>
                                <div className="label">Completed Today</div>
                                <div className="value">{stats.completedToday}</div>
                            </div>
                            <div css={styles.statCard('#EC4899')}>
                                <div className="label">Ink Levels</div>
                                <div css={styles.inkContainer}>
                                    <div css={styles.inkLevel('cyan', stats.inkLevelCyan)} title={`Cyan: ${stats.inkLevelCyan}%`} />
                                    <div css={styles.inkLevel('magenta', stats.inkLevelMagenta)} title={`Magenta: ${stats.inkLevelMagenta}%`} />
                                    <div css={styles.inkLevel('yellow', stats.inkLevelYellow)} title={`Yellow: ${stats.inkLevelYellow}%`} />
                                    <div css={styles.inkLevel('black', stats.inkLevelBlack)} title={`Black: ${stats.inkLevelBlack}%`} />
                                </div>
                            </div>
                        </div>
                    )}

                    {/* Quick Actions */}
                    <h2 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '24px', color: '#1B2330' }}>
                        Operations
                    </h2>
                    <div css={styles.actionGrid}>
                        <div css={styles.actionCard()} onClick={() => navigateTo('/printing/joblist')}>
                            <div className="icon-box" style={{ background: '#EEF2FF', color: '#4F46E5' }}>
                                🖨️
                            </div>
                            <div className="info">
                                <h3>Print Queue</h3>
                                <p>Manage active print jobs and quality checks</p>
                            </div>
                        </div>

                        <div css={styles.actionCard()} onClick={() => navigateTo('/printing/maintenance')}>
                            <div className="icon-box" style={{ background: '#FFF1F2', color: '#BE123C' }}>
                                🔧
                            </div>
                            <div className="info">
                                <h3>Maintenance</h3>
                                <p>Log printer maintenance and issues</p>
                            </div>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
