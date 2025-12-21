/**
 * Accounts Dashboard - Home
 * Overview of financial status
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { accountsService } from '@/services';
import type { AccountsStats } from '@/types/accounts';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/accounts/styles';

export default function AccountsDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<AccountsStats | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    const userName = authState.user?.name || 'Accountant';

    useEffect(() => {
        async function loadStats() {
            try {
                const data = await accountsService.getStats();
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
                <title>Accounts Dashboard | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Welcome Section */}
                    <div css={styles.welcomeSection}>
                        <h1>Finance Overview</h1>
                        <p>Managing invoices and revenue for {userName}</p>
                    </div>

                    {/* Stats Grid */}
                    {stats && (
                        <div css={styles.statsGrid}>
                            <div css={styles.statCard('#3B82F6')}>
                                <div className="label">Today's Revenue</div>
                                <div className="value">£{stats.totalRevenueToday.toLocaleString()}</div>
                            </div>
                            <div css={styles.statCard('#F59E0B')}>
                                <div className="label">Pending Invoices</div>
                                <div className="value">{stats.pendingInvoicesCount}</div>
                            </div>
                            <div css={styles.statCard('#EF4444')}>
                                <div className="label">Total Overdue</div>
                                <div className="value">£{stats.totalOverdueAmount.toLocaleString()}</div>
                            </div>
                            <div css={styles.statCard('#10B981')}>
                                <div className="label">Monthly Revenue</div>
                                <div className="value">£{stats.monthlyRevenue.toLocaleString()}</div>
                            </div>
                        </div>
                    )}

                    {/* Quick Actions */}
                    <h2 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '24px', color: '#1B2330' }}>
                        Actions
                    </h2>
                    <div css={styles.actionGrid}>
                        <div css={styles.actionCard()} onClick={() => navigateTo('/accounts/invoices')}>
                            <div className="icon-box" style={{ background: '#EEF2FF', color: '#4F46E5' }}>
                                🧾
                            </div>
                            <div className="info">
                                <h3>Manage Invoices</h3>
                                <p>Create and track invoices</p>
                            </div>
                        </div>

                        <div css={styles.actionCard()} onClick={() => navigateTo('/accounts/employees')}>
                            <div className="icon-box" style={{ background: '#F0FDF4', color: '#15803D' }}>
                                👥
                            </div>
                            <div className="info">
                                <h3>Employees</h3>
                                <p>Manage staff payroll and expenses</p>
                            </div>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
