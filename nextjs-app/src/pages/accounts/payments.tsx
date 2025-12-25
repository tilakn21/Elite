/**
 * Accounts - Payment History
 * Complete ledger of all payments received
 */

import { type ReactElement, useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { css, useTheme, Theme } from '@emotion/react';
import { FaSearch, FaCalendarAlt } from 'react-icons/fa';
import { AppLayout } from '@/components/layout';
import { accountsService } from '@/services';
import type { NextPageWithLayout } from '../_app';

// Types
interface Payment {
    id: string;
    jobId: string;
    jobCode: string;
    customerName: string;
    amount: number;
    mode: string;
    recordedBy: string;
    recordedAt: string;
    notes?: string;
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
        margin-bottom: 24px;
        
        h1 {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 4px;
        }
        
        p {
            font-size: 14px;
            color: #64748b;
        }
    `,
    summaryCards: css`
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
        
        @media (max-width: 1024px) {
            grid-template-columns: repeat(2, 1fr);
        }
    `,
    summaryCard: (color: string) => css`
        background: white;
        border-radius: 12px;
        padding: 20px;
        border-left: 4px solid ${color};
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        
        .label {
            font-size: 12px;
            color: #64748b;
            text-transform: uppercase;
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
    filters: css`
        display: flex;
        gap: 12px;
        margin-bottom: 24px;
        flex-wrap: wrap;
    `,
    searchBox: css`
        flex: 1;
        min-width: 200px;
        position: relative;
        
        input {
            width: 100%;
            padding: 12px 16px 12px 44px;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.2s;
            
            &:focus {
                outline: none;
                border-color: #3b82f6;
            }
        }
        
        svg {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
    `,
    dateFilter: css`
        display: flex;
        align-items: center;
        gap: 8px;
        
        input {
            padding: 10px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
        }
        
        span {
            color: #64748b;
            font-size: 13px;
        }
    `,
    modeFilter: css`
        display: flex;
        gap: 8px;
    `,
    modeBtn: (isActive: boolean, color: string) => css`
        padding: 8px 16px;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        cursor: pointer;
        background: ${isActive ? color : '#f1f5f9'};
        color: ${isActive ? 'white' : '#64748b'};
        transition: all 0.2s;
        
        &:hover {
            background: ${isActive ? color : '#e2e8f0'};
        }
    `,
    tableContainer: css`
        background: white;
        border-radius: 16px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        overflow: hidden;
    `,
    table: css`
        width: 100%;
        border-collapse: collapse;
        
        th, td {
            padding: 14px 16px;
            text-align: left;
            border-bottom: 1px solid #f1f5f9;
        }
        
        th {
            background: #f8fafc;
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
        }
        
        td {
            font-size: 14px;
            color: #1e293b;
        }
        
        tr:hover td {
            background: #f8fafc;
        }
    `,
    modeBadge: (mode: string) => css`
        display: inline-flex;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 500;
        background: ${mode === 'cash' ? '#dcfce7' : mode === 'card' ? '#dbeafe' : mode === 'upi' ? '#ede9fe' : mode === 'bank_transfer' ? '#fef3c7' : '#f1f5f9'};
        color: ${mode === 'cash' ? '#16a34a' : mode === 'card' ? '#2563eb' : mode === 'upi' ? '#7c3aed' : mode === 'bank_transfer' ? '#d97706' : '#64748b'};
    `,
    emptyState: css`
        text-align: center;
        padding: 60px 20px;
        color: #94a3b8;
    `,
};

const PaymentModes = ['All', 'Cash', 'Card', 'UPI', 'Bank Transfer', 'Cheque'] as const;

const AccountsPaymentsPage: NextPageWithLayout = () => {
    const theme = useTheme();

    const [payments, setPayments] = useState<Payment[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedMode, setSelectedMode] = useState<string>('All');
    const [dateFrom, setDateFrom] = useState('');
    const [dateTo, setDateTo] = useState('');

    useEffect(() => {
        loadPayments();
    }, []);

    const loadPayments = async () => {
        setIsLoading(true);
        try {
            const data = await accountsService.getAllPayments(100);
            setPayments(data);
        } catch (error) {
            console.error('Failed to load payments:', error);
        } finally {
            setIsLoading(false);
        }
    };

    // Filtered payments
    const filteredPayments = useMemo(() => {
        let result = [...payments];

        // Search filter
        if (searchQuery) {
            const query = searchQuery.toLowerCase();
            result = result.filter(p =>
                p.jobCode.toLowerCase().includes(query) ||
                p.customerName.toLowerCase().includes(query)
            );
        }

        // Mode filter
        if (selectedMode !== 'All') {
            const modeKey = selectedMode.toLowerCase().replace(' ', '_');
            result = result.filter(p => p.mode === modeKey);
        }

        // Date range filter
        if (dateFrom) {
            const from = new Date(dateFrom);
            result = result.filter(p => new Date(p.recordedAt) >= from);
        }
        if (dateTo) {
            const to = new Date(dateTo);
            to.setHours(23, 59, 59);
            result = result.filter(p => new Date(p.recordedAt) <= to);
        }

        return result;
    }, [payments, searchQuery, selectedMode, dateFrom, dateTo]);

    // Summary stats
    const summary = useMemo(() => {
        const total = filteredPayments.reduce((acc, p) => acc + p.amount, 0);
        const todayPayments = filteredPayments.filter(p => {
            const today = new Date().toDateString();
            return new Date(p.recordedAt).toDateString() === today;
        });
        const todayTotal = todayPayments.reduce((acc, p) => acc + p.amount, 0);

        // Group by mode
        const byMode: Record<string, number> = {};
        filteredPayments.forEach(p => {
            byMode[p.mode] = (byMode[p.mode] || 0) + p.amount;
        });

        return { total, count: filteredPayments.length, todayTotal, todayCount: todayPayments.length, byMode };
    }, [filteredPayments]);

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP',
            maximumFractionDigits: 0
        }).format(amount);
    };

    const formatDateTime = (dateStr: string) => {
        const date = new Date(dateStr);
        return date.toLocaleString('en-GB', {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const getModeLabel = (mode: string) => {
        const labels: Record<string, string> = {
            cash: 'Cash',
            card: 'Card',
            upi: 'UPI',
            bank_transfer: 'Bank Transfer',
            cheque: 'Cheque'
        };
        return labels[mode] || mode;
    };

    return (
        <>
            <Head>
                <title>Payment History | Accounts</title>
            </Head>

            <div css={pageStyles.container(theme)}>
                {/* Header */}
                <div css={pageStyles.header}>
                    <h1>Payment History</h1>
                    <p>Complete ledger of all payments received</p>
                </div>

                {/* Summary Cards */}
                <div css={pageStyles.summaryCards}>
                    <div css={pageStyles.summaryCard('#10b981')}>
                        <div className="label">Total Collected</div>
                        <div className="value">{formatCurrency(summary.total)}</div>
                        <div className="subtext">{summary.count} payments</div>
                    </div>
                    <div css={pageStyles.summaryCard('#3b82f6')}>
                        <div className="label">Today</div>
                        <div className="value">{formatCurrency(summary.todayTotal)}</div>
                        <div className="subtext">{summary.todayCount} payments</div>
                    </div>
                    <div css={pageStyles.summaryCard('#16a34a')}>
                        <div className="label">Cash</div>
                        <div className="value">{formatCurrency(summary.byMode['cash'] || 0)}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#8b5cf6')}>
                        <div className="label">Digital</div>
                        <div className="value">{formatCurrency((summary.byMode['card'] || 0) + (summary.byMode['upi'] || 0) + (summary.byMode['bank_transfer'] || 0))}</div>
                    </div>
                </div>

                {/* Filters */}
                <div css={pageStyles.filters}>
                    <div css={pageStyles.searchBox}>
                        <FaSearch size={14} />
                        <input
                            type="text"
                            placeholder="Search by job code or customer..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                        />
                    </div>
                    <div css={pageStyles.dateFilter}>
                        <FaCalendarAlt size={14} color="#64748b" />
                        <input
                            type="date"
                            value={dateFrom}
                            onChange={(e) => setDateFrom(e.target.value)}
                        />
                        <span>to</span>
                        <input
                            type="date"
                            value={dateTo}
                            onChange={(e) => setDateTo(e.target.value)}
                        />
                    </div>
                </div>

                {/* Mode Filter Buttons */}
                <div css={pageStyles.modeFilter} style={{ marginBottom: '24px' }}>
                    {PaymentModes.map(mode => (
                        <button
                            key={mode}
                            css={pageStyles.modeBtn(selectedMode === mode, '#3b82f6')}
                            onClick={() => setSelectedMode(mode)}
                        >
                            {mode}
                        </button>
                    ))}
                </div>

                {/* Payments Table */}
                <div css={pageStyles.tableContainer}>
                    <table css={pageStyles.table}>
                        <thead>
                            <tr>
                                <th>Date & Time</th>
                                <th>Job Code</th>
                                <th>Customer</th>
                                <th>Mode</th>
                                <th>Recorded By</th>
                                <th style={{ textAlign: 'right' }}>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            {isLoading ? (
                                <tr><td colSpan={6} style={{ textAlign: 'center', padding: '40px' }}>Loading...</td></tr>
                            ) : filteredPayments.length === 0 ? (
                                <tr><td colSpan={6}><div css={pageStyles.emptyState}>No payments found</div></td></tr>
                            ) : (
                                filteredPayments.map(payment => (
                                    <tr key={payment.id}>
                                        <td style={{ color: '#64748b', fontSize: '13px' }}>
                                            {formatDateTime(payment.recordedAt)}
                                        </td>
                                        <td style={{ fontFamily: 'monospace', fontWeight: 500, color: '#3b82f6' }}>
                                            {payment.jobCode}
                                        </td>
                                        <td>{payment.customerName}</td>
                                        <td>
                                            <span css={pageStyles.modeBadge(payment.mode)}>
                                                {getModeLabel(payment.mode)}
                                            </span>
                                        </td>
                                        <td style={{ color: '#64748b' }}>{payment.recordedBy}</td>
                                        <td style={{ textAlign: 'right', fontWeight: 600, color: '#10b981' }}>
                                            +{formatCurrency(payment.amount)}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};

AccountsPaymentsPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AccountsPaymentsPage;
