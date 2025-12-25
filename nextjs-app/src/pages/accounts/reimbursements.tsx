/**
 * Accounts - Reimbursements
 * Review and manage employee expense claims
 */

import { type ReactElement, useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { css, useTheme, Theme } from '@emotion/react';
import { FaCheck, FaTimes, FaMoneyBill, FaEye } from 'react-icons/fa';
import { AppLayout } from '@/components/layout';
import { Modal, Button } from '@/components/ui';
import { reimbursementsService } from '@/services';
import type { Reimbursement, ReimbursementStatus } from '@/types/database';
import type { NextPageWithLayout } from '../_app';

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
    `,
    filterTabs: css`
        display: flex;
        gap: 8px;
        margin-bottom: 24px;
    `,
    filterTab: (isActive: boolean) => css`
        padding: 10px 20px;
        border: none;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        background: ${isActive ? '#3b82f6' : '#f1f5f9'};
        color: ${isActive ? 'white' : '#64748b'};
        
        &:hover {
            background: ${isActive ? '#2563eb' : '#e2e8f0'};
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
    statusBadge: (status: ReimbursementStatus) => css`
        display: inline-flex;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        background: ${status === 'paid' ? '#dcfce7' : status === 'approved' ? '#dbeafe' : status === 'rejected' ? '#fee2e2' : '#fef3c7'};
        color: ${status === 'paid' ? '#16a34a' : status === 'approved' ? '#2563eb' : status === 'rejected' ? '#dc2626' : '#d97706'};
    `,
    actions: css`
        display: flex;
        gap: 8px;
    `,
    actionBtn: (color: string) => css`
        padding: 6px 10px;
        border: none;
        border-radius: 6px;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 4px;
        background: ${color}15;
        color: ${color};
        
        &:hover {
            background: ${color}25;
        }
    `,
    modalContent: css`
        padding: 20px 0;
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
            
            .label {
                font-size: 13px;
                color: #64748b;
            }
            
            .value {
                font-size: 14px;
                font-weight: 500;
                color: #1e293b;
            }
        }
    `,
    receiptImage: css`
        max-width: 100%;
        max-height: 300px;
        border-radius: 8px;
        margin-top: 16px;
    `,
    emptyState: css`
        text-align: center;
        padding: 60px 20px;
        color: #94a3b8;
    `,
};

const AccountsReimbursementsPage: NextPageWithLayout = () => {
    const theme = useTheme();

    const [reimbursements, setReimbursements] = useState<Reimbursement[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [filter, setFilter] = useState<ReimbursementStatus | 'all'>('all');
    const [selectedClaim, setSelectedClaim] = useState<Reimbursement | null>(null);

    useEffect(() => {
        loadData();
    }, [filter]);

    const loadData = async () => {
        setIsLoading(true);
        try {
            const data = await reimbursementsService.getReimbursements();
            // Filter client-side
            const filtered = filter === 'all'
                ? data
                : data.filter(r => r.status === filter);
            setReimbursements(filtered);
        } catch (error) {
            console.error('Failed to load reimbursements:', error);
        } finally {
            setIsLoading(false);
        }
    };

    // Summary stats
    const summary = useMemo(() => {
        const pending = reimbursements.filter(r => r.status === 'pending');
        const approved = reimbursements.filter(r => r.status === 'approved');
        const paid = reimbursements.filter(r => r.status === 'paid');

        return {
            pendingCount: pending.length,
            pendingAmount: pending.reduce((acc, r) => acc + r.amount, 0),
            approvedCount: approved.length,
            approvedAmount: approved.reduce((acc, r) => acc + r.amount, 0),
            paidCount: paid.length,
            paidAmount: paid.reduce((acc, r) => acc + r.amount, 0),
        };
    }, [reimbursements]);

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP',
            maximumFractionDigits: 0
        }).format(amount);
    };

    const formatDate = (dateStr: string) => {
        return new Date(dateStr).toLocaleDateString('en-GB', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        });
    };

    const handleStatusUpdate = async (id: string, status: ReimbursementStatus) => {
        try {
            await reimbursementsService.updateReimbursementStatus(id, status);
            loadData();
        } catch (error) {
            console.error('Failed to update status:', error);
        }
    };

    return (
        <>
            <Head>
                <title>Reimbursements | Accounts</title>
            </Head>

            <div css={pageStyles.container(theme)}>
                {/* Header */}
                <div css={pageStyles.header}>
                    <h1>Reimbursements</h1>
                    <p>Review and manage employee expense claims</p>
                </div>

                {/* Summary Cards */}
                <div css={pageStyles.summaryCards}>
                    <div css={pageStyles.summaryCard('#f59e0b')}>
                        <div className="label">Pending Claims</div>
                        <div className="value">{summary.pendingCount}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#f59e0b')}>
                        <div className="label">Pending Amount</div>
                        <div className="value">{formatCurrency(summary.pendingAmount)}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#3b82f6')}>
                        <div className="label">Approved (Unpaid)</div>
                        <div className="value">{formatCurrency(summary.approvedAmount)}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#10b981')}>
                        <div className="label">Total Paid</div>
                        <div className="value">{formatCurrency(summary.paidAmount)}</div>
                    </div>
                </div>

                {/* Filter Tabs */}
                <div css={pageStyles.filterTabs}>
                    {(['all', 'pending', 'approved', 'paid', 'rejected'] as const).map(f => (
                        <button
                            key={f}
                            css={pageStyles.filterTab(filter === f)}
                            onClick={() => setFilter(f)}
                        >
                            {f.charAt(0).toUpperCase() + f.slice(1)}
                        </button>
                    ))}
                </div>

                {/* Table */}
                <div css={pageStyles.tableContainer}>
                    <table css={pageStyles.table}>
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Purpose</th>
                                <th>Amount</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {isLoading ? (
                                <tr><td colSpan={6} style={{ textAlign: 'center', padding: '40px' }}>Loading...</td></tr>
                            ) : reimbursements.length === 0 ? (
                                <tr><td colSpan={6}><div css={pageStyles.emptyState}>No reimbursements found</div></td></tr>
                            ) : (
                                reimbursements.map(claim => (
                                    <tr key={claim.id}>
                                        <td style={{ fontWeight: 500 }}>{claim.emp_name}</td>
                                        <td>{claim.purpose}</td>
                                        <td style={{ fontWeight: 600 }}>{formatCurrency(claim.amount)}</td>
                                        <td>{formatDate(claim.reimbursement_date)}</td>
                                        <td>
                                            <span css={pageStyles.statusBadge(claim.status)}>
                                                {claim.status}
                                            </span>
                                        </td>
                                        <td>
                                            <div css={pageStyles.actions}>
                                                <button
                                                    css={pageStyles.actionBtn('#64748b')}
                                                    onClick={() => setSelectedClaim(claim)}
                                                >
                                                    <FaEye size={12} /> View
                                                </button>
                                                {claim.status === 'pending' && (
                                                    <>
                                                        <button
                                                            css={pageStyles.actionBtn('#10b981')}
                                                            onClick={() => handleStatusUpdate(claim.id, 'approved')}
                                                        >
                                                            <FaCheck size={12} /> Approve
                                                        </button>
                                                        <button
                                                            css={pageStyles.actionBtn('#ef4444')}
                                                            onClick={() => handleStatusUpdate(claim.id, 'rejected')}
                                                        >
                                                            <FaTimes size={12} /> Reject
                                                        </button>
                                                    </>
                                                )}
                                                {claim.status === 'approved' && (
                                                    <button
                                                        css={pageStyles.actionBtn('#8b5cf6')}
                                                        onClick={() => handleStatusUpdate(claim.id, 'paid')}
                                                    >
                                                        <FaMoneyBill size={12} /> Mark Paid
                                                    </button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Detail Modal */}
            <Modal
                isOpen={!!selectedClaim}
                onClose={() => setSelectedClaim(null)}
                title="Reimbursement Details"
                width="500px"
            >
                {selectedClaim && (
                    <div css={pageStyles.modalContent}>
                        <div className="detail-row">
                            <span className="label">Employee</span>
                            <span className="value">{selectedClaim.emp_name}</span>
                        </div>
                        <div className="detail-row">
                            <span className="label">Purpose</span>
                            <span className="value">{selectedClaim.purpose}</span>
                        </div>
                        <div className="detail-row">
                            <span className="label">Amount</span>
                            <span className="value" style={{ color: '#10b981', fontWeight: 600 }}>
                                {formatCurrency(selectedClaim.amount)}
                            </span>
                        </div>
                        <div className="detail-row">
                            <span className="label">Date</span>
                            <span className="value">{formatDate(selectedClaim.reimbursement_date)}</span>
                        </div>
                        <div className="detail-row">
                            <span className="label">Status</span>
                            <span css={pageStyles.statusBadge(selectedClaim.status)}>
                                {selectedClaim.status}
                            </span>
                        </div>
                        {selectedClaim.remarks && (
                            <div className="detail-row">
                                <span className="label">Remarks</span>
                                <span className="value">{selectedClaim.remarks}</span>
                            </div>
                        )}
                        {selectedClaim.receipt_url && (
                            <div style={{ marginTop: '16px' }}>
                                <div style={{ fontSize: '13px', color: '#64748b', marginBottom: '8px' }}>Receipt</div>
                                <img
                                    src={selectedClaim.receipt_url}
                                    alt="Receipt"
                                    css={pageStyles.receiptImage}
                                />
                            </div>
                        )}
                    </div>
                )}
                <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '16px' }}>
                    <Button variant="ghost" onClick={() => setSelectedClaim(null)}>Close</Button>
                </div>
            </Modal>
        </>
    );
};

AccountsReimbursementsPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AccountsReimbursementsPage;
