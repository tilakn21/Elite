/**
 * Accounts Dashboard - Home
 * Enhanced with Quick Stats, Activity Log, and Pending Jobs widgets
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme, css, Theme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { accountsService } from '@/services';
import type { AccountsStats } from '@/types/accounts';
import { useAuth } from '@/state';

// Types
interface WeeklyStats {
    weeklyCollection: number;
    weekPayments: number;
    overdueCount: number;
    overdueAmount: number;
}

interface RecentPayment {
    id: string;
    jobCode: string;
    customerName: string;
    amount: number;
    mode: string;
    recordedAt: string;
}

interface PendingJob {
    id: string;
    jobCode: string;
    customerName: string;
    shopName: string;
    amount: number;
    status: string;
}

// Styles
const pageStyles = {
    container: (theme: Theme) => css`
        padding: 32px;
        max-width: 1400px;
        margin: 0 auto;
        background: ${theme.colors.background};
        min-height: 100vh;
    `,
    header: css`
        margin-bottom: 32px;
        
        h1 {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 8px;
        }
        
        p {
            font-size: 15px;
            color: #64748b;
        }
    `,
    statsGrid: css`
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 20px;
        margin-bottom: 32px;
        
        @media (max-width: 1024px) {
            grid-template-columns: repeat(2, 1fr);
        }
        
        @media (max-width: 640px) {
            grid-template-columns: 1fr;
        }
    `,
    statCard: (color: string) => css`
        background: white;
        border-radius: 16px;
        padding: 24px;
        border-left: 4px solid ${color};
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        transition: all 0.2s;
        
        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.1);
        }
        
        .label {
            font-size: 13px;
            font-weight: 500;
            color: #64748b;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .value {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
        }
        
        .subtext {
            font-size: 12px;
            color: ${color};
            margin-top: 4px;
            font-weight: 500;
        }
    `,
    quickStatsContainer: css`
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
        margin-bottom: 32px;
        
        @media (max-width: 768px) {
            grid-template-columns: 1fr;
        }
    `,
    quickStatCard: (color: string, isAlert: boolean) => css`
        background: ${isAlert ? `${color}10` : 'white'};
        border: 1px solid ${isAlert ? color : '#e2e8f0'};
        border-radius: 16px;
        padding: 24px;
        display: flex;
        align-items: center;
        gap: 16px;
        transition: all 0.2s;
        
        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px ${color}20;
        }
    `,
    iconBox: (color: string) => css`
        width: 56px;
        height: 56px;
        border-radius: 14px;
        background: ${color};
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        color: white;
    `,
    quickStatContent: css`
        flex: 1;
        
        .label {
            font-size: 13px;
            color: #64748b;
            margin-bottom: 4px;
        }
        
        .value {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
        }
        
        .subtext {
            font-size: 12px;
            color: #94a3b8;
            margin-top: 2px;
        }
    `,
    contentGrid: css`
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 24px;
        margin-bottom: 32px;
        
        @media (max-width: 1024px) {
            grid-template-columns: 1fr;
        }
    `,
    card: css`
        background: white;
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
    `,
    cardHeader: css`
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
        
        h3 {
            font-size: 18px;
            font-weight: 600;
            color: #1e293b;
        }
        
        .badge {
            background: #f1f5f9;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
        }
    `,
    paymentItem: css`
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 0;
        border-bottom: 1px solid #f1f5f9;
        
        &:last-child {
            border-bottom: none;
        }
    `,
    paymentDot: (mode: string) => css`
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: ${mode === 'cash' ? '#10b981' : mode === 'card' ? '#3b82f6' : mode === 'upi' ? '#8b5cf6' : '#f59e0b'};
        flex-shrink: 0;
    `,
    paymentContent: css`
        flex: 1;
        min-width: 0;
        
        .title {
            font-size: 14px;
            font-weight: 500;
            color: #1e293b;
            margin-bottom: 2px;
        }
        
        .meta {
            font-size: 12px;
            color: #94a3b8;
        }
    `,
    paymentAmount: css`
        font-size: 15px;
        font-weight: 600;
        color: #10b981;
    `,
    jobItem: css`
        padding: 14px;
        background: #f8fafc;
        border-radius: 10px;
        margin-bottom: 10px;
        cursor: pointer;
        transition: all 0.2s;
        
        &:hover {
            background: #f1f5f9;
            transform: translateX(4px);
        }
        
        &:last-child {
            margin-bottom: 0;
        }
    `,
    jobHeader: css`
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 6px;
        
        .code {
            font-size: 14px;
            font-weight: 600;
            color: #3b82f6;
        }
        
        .amount {
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
        }
    `,
    jobMeta: css`
        font-size: 13px;
        color: #64748b;
    `,
    actionGrid: css`
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        
        @media (max-width: 768px) {
            grid-template-columns: 1fr;
        }
    `,
    actionCard: css`
        background: white;
        border-radius: 16px;
        padding: 24px;
        display: flex;
        align-items: center;
        gap: 16px;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        
        &:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 32px rgba(0,0,0,0.12);
        }
        
        .icon-box {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        
        .info {
            h3 {
                font-size: 16px;
                font-weight: 600;
                color: #1e293b;
                margin-bottom: 4px;
            }
            
            p {
                font-size: 13px;
                color: #64748b;
            }
        }
    `,
    emptyState: css`
        text-align: center;
        padding: 32px;
        color: #94a3b8;
        font-size: 14px;
    `,
    loadingContainer: css`
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
    `,
    spinner: css`
        width: 40px;
        height: 40px;
        border: 3px solid #e2e8f0;
        border-top-color: #3b82f6;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    `,
};

export default function AccountsDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [stats, setStats] = useState<AccountsStats | null>(null);
    const [weeklyStats, setWeeklyStats] = useState<WeeklyStats | null>(null);
    const [recentPayments, setRecentPayments] = useState<RecentPayment[]>([]);
    const [pendingJobs, setPendingJobs] = useState<PendingJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    const userName = authState.user?.name || 'Accountant';

    useEffect(() => {
        async function loadData() {
            try {
                const [statsData, weeklyData, paymentsData, jobsData] = await Promise.all([
                    accountsService.getStats(),
                    accountsService.getWeeklyStats(),
                    accountsService.getRecentPayments(8),
                    accountsService.getPendingInvoiceJobs(),
                ]);
                setStats(statsData);
                setWeeklyStats(weeklyData);
                setRecentPayments(paymentsData);
                setPendingJobs(jobsData);
            } catch (error) {
                console.error('Failed to load data:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadData();
    }, []);

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP',
            maximumFractionDigits: 0
        }).format(amount);
    };

    const formatTime = (timestamp: string): string => {
        const date = new Date(timestamp);
        const now = new Date();
        const diff = now.getTime() - date.getTime();
        const mins = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);

        if (mins < 60) return `${mins}m ago`;
        if (hours < 24) return `${hours}h ago`;
        if (days < 7) return `${days}d ago`;
        return date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
    };

    const getModeLabel = (mode: string) => {
        const labels: Record<string, string> = {
            cash: 'Cash',
            card: 'Card',
            upi: 'UPI',
            bank_transfer: 'Bank Transfer',
            cheque: 'Cheque',
        };
        return labels[mode] || mode;
    };

    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={pageStyles.loadingContainer}>
                    <div css={pageStyles.spinner} />
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
                <div css={pageStyles.container(theme)}>
                    {/* Header */}
                    <div css={pageStyles.header}>
                        <h1>Finance Overview</h1>
                        <p>Welcome back, {userName}. Here&apos;s your financial summary.</p>
                    </div>

                    {/* Main Stats Grid */}
                    {stats && (
                        <div css={pageStyles.statsGrid}>
                            <div css={pageStyles.statCard('#3b82f6')}>
                                <div className="label">Today&apos;s Revenue</div>
                                <div className="value">{formatCurrency(stats.totalRevenueToday)}</div>
                            </div>
                            <div css={pageStyles.statCard('#f59e0b')}>
                                <div className="label">Pending Invoices</div>
                                <div className="value">{stats.pendingInvoicesCount}</div>
                            </div>
                            <div css={pageStyles.statCard('#ef4444')}>
                                <div className="label">Total Overdue</div>
                                <div className="value">{formatCurrency(stats.totalOverdueAmount)}</div>
                            </div>
                            <div css={pageStyles.statCard('#10b981')}>
                                <div className="label">Monthly Revenue</div>
                                <div className="value">{formatCurrency(stats.monthlyRevenue)}</div>
                            </div>
                        </div>
                    )}

                    {/* Quick Stats Section */}
                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#1e293b' }}>
                        This Week
                    </h2>
                    {weeklyStats && (
                        <div css={pageStyles.quickStatsContainer}>
                            <div css={pageStyles.quickStatCard('#10b981', false)}>
                                <div css={pageStyles.iconBox('#10b981')}>💷</div>
                                <div css={pageStyles.quickStatContent}>
                                    <div className="label">Weekly Collections</div>
                                    <div className="value">{formatCurrency(weeklyStats.weeklyCollection)}</div>
                                    <div className="subtext">{weeklyStats.weekPayments} payments received</div>
                                </div>
                            </div>
                            <div css={pageStyles.quickStatCard('#f59e0b', weeklyStats.overdueCount > 0)}>
                                <div css={pageStyles.iconBox('#f59e0b')}>⚠️</div>
                                <div css={pageStyles.quickStatContent}>
                                    <div className="label">Overdue Invoices</div>
                                    <div className="value">{weeklyStats.overdueCount}</div>
                                    <div className="subtext">{formatCurrency(weeklyStats.overdueAmount)} outstanding</div>
                                </div>
                            </div>
                            <div css={pageStyles.quickStatCard('#8b5cf6', false)}>
                                <div css={pageStyles.iconBox('#8b5cf6')}>📋</div>
                                <div css={pageStyles.quickStatContent}>
                                    <div className="label">Pending Invoices</div>
                                    <div className="value">{pendingJobs.length}</div>
                                    <div className="subtext">Jobs awaiting invoice</div>
                                </div>
                            </div>
                        </div>
                    )}

                    {/* Content Grid - Payments & Pending Jobs */}
                    <div css={pageStyles.contentGrid}>
                        {/* Recent Payments */}
                        <div css={pageStyles.card}>
                            <div css={pageStyles.cardHeader}>
                                <h3>Recent Payments</h3>
                                <span className="badge">{recentPayments.length} payments</span>
                            </div>
                            {recentPayments.length === 0 ? (
                                <div css={pageStyles.emptyState}>No recent payments</div>
                            ) : (
                                recentPayments.map(payment => (
                                    <div key={payment.id} css={pageStyles.paymentItem}>
                                        <div css={pageStyles.paymentDot(payment.mode)} />
                                        <div css={pageStyles.paymentContent}>
                                            <div className="title">{payment.customerName}</div>
                                            <div className="meta">
                                                {payment.jobCode} • {getModeLabel(payment.mode)} • {formatTime(payment.recordedAt)}
                                            </div>
                                        </div>
                                        <div css={pageStyles.paymentAmount}>
                                            +{formatCurrency(payment.amount)}
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>

                        {/* Pending Invoice Jobs */}
                        <div css={pageStyles.card}>
                            <div css={pageStyles.cardHeader}>
                                <h3>Jobs Awaiting Invoice</h3>
                                <span className="badge">{pendingJobs.length} jobs</span>
                            </div>
                            {pendingJobs.length === 0 ? (
                                <div css={pageStyles.emptyState}>All jobs have invoices generated</div>
                            ) : (
                                <div style={{ maxHeight: '350px', overflowY: 'auto' }}>
                                    {pendingJobs.slice(0, 8).map(job => (
                                        <div
                                            key={job.id}
                                            css={pageStyles.jobItem}
                                            onClick={() => router.push(`/accounts/invoices?job=${job.id}`)}
                                        >
                                            <div css={pageStyles.jobHeader}>
                                                <span className="code">{job.jobCode}</span>
                                                <span className="amount">{formatCurrency(job.amount)}</span>
                                            </div>
                                            <div css={pageStyles.jobMeta}>
                                                {job.customerName}{job.shopName && ` • ${job.shopName}`}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Quick Actions */}
                    <h2 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '16px', color: '#1e293b' }}>
                        Quick Actions
                    </h2>
                    <div css={pageStyles.actionGrid}>
                        <div css={pageStyles.actionCard} onClick={() => router.push('/accounts/invoices')}>
                            <div className="icon-box" style={{ background: '#eef2ff', color: '#4f46e5' }}>
                                🧾
                            </div>
                            <div className="info">
                                <h3>Manage Invoices</h3>
                                <p>Create and track invoices</p>
                            </div>
                        </div>

                        <div css={pageStyles.actionCard} onClick={() => router.push('/admin/reimbursements')}>
                            <div className="icon-box" style={{ background: '#fef3c7', color: '#d97706' }}>
                                💳
                            </div>
                            <div className="info">
                                <h3>Reimbursements</h3>
                                <p>Review employee claims</p>
                            </div>
                        </div>

                        <div css={pageStyles.actionCard} onClick={() => router.push('/admin/employees')}>
                            <div className="icon-box" style={{ background: '#f0fdf4', color: '#15803d' }}>
                                👥
                            </div>
                            <div className="info">
                                <h3>Employees</h3>
                                <p>Manage staff records</p>
                            </div>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
