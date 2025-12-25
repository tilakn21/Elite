/**
 * Accounts - Jobs Management
 * View all jobs with payment status, record payments, set amounts
 */

import { type ReactElement, useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { css, useTheme, Theme } from '@emotion/react';
import { FaSearch, FaMoneyBillWave, FaFileInvoice, FaTimes } from 'react-icons/fa';
import { AppLayout } from '@/components/layout';
import { Modal, Button } from '@/components/ui';
import { accountsService } from '@/services';
import type { PaymentRecord } from '@/types/database';
import type { NextPageWithLayout } from '../_app';

// Types
interface JobForAccounts {
    id: string;
    jobCode: string;
    customerName: string;
    shopName: string;
    phone: string;
    status: string;
    totalAmount: number;
    amountPaid: number;
    paymentStatus: string;
    createdAt: string;
    updatedAt: string;
}

type PaymentFilter = 'all' | 'pending' | 'partial' | 'paid';

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
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
        flex-wrap: wrap;
        gap: 16px;
        
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
    searchRow: css`
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
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
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
    filterTabs: css`
        display: flex;
        gap: 8px;
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
    summaryCards: css`
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 24px;
        
        @media (max-width: 1024px) {
            grid-template-columns: repeat(2, 1fr);
        }
        
        @media (max-width: 640px) {
            grid-template-columns: 1fr;
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
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        
        .value {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
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
            letter-spacing: 0.5px;
        }
        
        td {
            font-size: 14px;
            color: #1e293b;
        }
        
        tr:hover td {
            background: #f8fafc;
        }
    `,
    jobCode: css`
        font-family: monospace;
        font-weight: 600;
        color: #3b82f6;
        cursor: pointer;
        
        &:hover {
            text-decoration: underline;
        }
    `,
    statusBadge: (status: string) => css`
        display: inline-flex;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        background: ${status === 'paid' ? '#dcfce7' : status === 'partial' ? '#fef3c7' : '#fee2e2'};
        color: ${status === 'paid' ? '#16a34a' : status === 'partial' ? '#d97706' : '#dc2626'};
    `,
    amountCell: css`
        text-align: right;
        
        .total {
            font-weight: 600;
            color: #1e293b;
        }
        
        .paid {
            font-size: 12px;
            color: #10b981;
        }
        
        .remaining {
            font-size: 12px;
            color: #f59e0b;
        }
    `,
    actions: css`
        display: flex;
        gap: 8px;
        justify-content: flex-end;
    `,
    actionBtn: (color: string) => css`
        padding: 6px 12px;
        border: none;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 6px;
        background: ${color}15;
        color: ${color};
        
        &:hover {
            background: ${color}25;
        }
    `,
    emptyState: css`
        text-align: center;
        padding: 60px 20px;
        color: #94a3b8;
        
        h3 {
            font-size: 18px;
            color: #64748b;
            margin-bottom: 8px;
        }
    `,
    modalContent: css`
        padding: 20px 0;
    `,
    formGroup: css`
        margin-bottom: 20px;
        
        label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 6px;
        }
        
        input, select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            
            &:focus {
                outline: none;
                border-color: #3b82f6;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            }
        }
        
        textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            resize: vertical;
            min-height: 80px;
            
            &:focus {
                outline: none;
                border-color: #3b82f6;
            }
        }
    `,
    modalFooter: css`
        display: flex;
        gap: 12px;
        justify-content: flex-end;
        margin-top: 24px;
    `,
    loadingContainer: css`
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 400px;
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

const AccountsJobsPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const router = useRouter();

    const [jobs, setJobs] = useState<JobForAccounts[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [filter, setFilter] = useState<PaymentFilter>('all');
    const [searchQuery, setSearchQuery] = useState('');

    // Modal states
    const [selectedJob, setSelectedJob] = useState<JobForAccounts | null>(null);
    const [showPaymentModal, setShowPaymentModal] = useState(false);
    const [showAmountModal, setShowAmountModal] = useState(false);

    // Form states
    const [paymentAmount, setPaymentAmount] = useState('');
    const [paymentMode, setPaymentMode] = useState<PaymentRecord['mode']>('cash');
    const [paymentNotes, setPaymentNotes] = useState('');
    const [newAmount, setNewAmount] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        loadJobs();
    }, [filter]);

    const loadJobs = async () => {
        setIsLoading(true);
        try {
            const data = await accountsService.getJobsForAccounts(filter);
            setJobs(data);
        } catch (error) {
            console.error('Failed to load jobs:', error);
        } finally {
            setIsLoading(false);
        }
    };

    // Filtered jobs based on search
    const filteredJobs = useMemo(() => {
        if (!searchQuery) return jobs;
        const query = searchQuery.toLowerCase();
        return jobs.filter(job =>
            job.jobCode.toLowerCase().includes(query) ||
            job.customerName.toLowerCase().includes(query) ||
            job.shopName.toLowerCase().includes(query)
        );
    }, [jobs, searchQuery]);

    // Summary stats
    const summary = useMemo(() => {
        const totalJobs = jobs.length;
        const pendingJobs = jobs.filter(j => j.paymentStatus === 'pending').length;
        const partialJobs = jobs.filter(j => j.paymentStatus === 'partial').length;
        const paidJobs = jobs.filter(j => j.paymentStatus === 'paid').length;
        const totalReceivable = jobs.reduce((acc, j) => acc + (j.totalAmount - j.amountPaid), 0);
        return { totalJobs, pendingJobs, partialJobs, paidJobs, totalReceivable };
    }, [jobs]);

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP',
            maximumFractionDigits: 0
        }).format(amount);
    };

    const handleRecordPayment = async () => {
        if (!selectedJob || !paymentAmount) return;

        setIsSubmitting(true);
        try {
            const result = await accountsService.recordPayment(
                selectedJob.id,
                parseFloat(paymentAmount),
                paymentMode,
                'Accountant', // TODO: Use actual user name
                paymentNotes || undefined
            );

            if (result.success) {
                setShowPaymentModal(false);
                setPaymentAmount('');
                setPaymentMode('cash');
                setPaymentNotes('');
                setSelectedJob(null);
                loadJobs();
            }
        } catch (error) {
            console.error('Failed to record payment:', error);
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleSetAmount = async () => {
        if (!selectedJob || !newAmount) return;

        setIsSubmitting(true);
        try {
            const success = await accountsService.setJobAmount(selectedJob.id, parseFloat(newAmount));
            if (success) {
                setShowAmountModal(false);
                setNewAmount('');
                setSelectedJob(null);
                loadJobs();
            }
        } catch (error) {
            console.error('Failed to set amount:', error);
        } finally {
            setIsSubmitting(false);
        }
    };

    const openPaymentModal = (job: JobForAccounts) => {
        setSelectedJob(job);
        setPaymentAmount('');
        setShowPaymentModal(true);
    };

    const openAmountModal = (job: JobForAccounts) => {
        setSelectedJob(job);
        setNewAmount(job.totalAmount.toString());
        setShowAmountModal(true);
    };

    if (isLoading && jobs.length === 0) {
        return (
            <div css={pageStyles.loadingContainer}>
                <div css={pageStyles.spinner} />
            </div>
        );
    }

    return (
        <>
            <Head>
                <title>Jobs | Accounts</title>
            </Head>

            <div css={pageStyles.container(theme)}>
                {/* Header */}
                <div css={pageStyles.header}>
                    <div>
                        <h1>Jobs & Payments</h1>
                        <p>Manage job payments and amounts</p>
                    </div>
                </div>

                {/* Summary Cards */}
                <div css={pageStyles.summaryCards}>
                    <div css={pageStyles.summaryCard('#3b82f6')}>
                        <div className="label">Total Jobs</div>
                        <div className="value">{summary.totalJobs}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#ef4444')}>
                        <div className="label">Pending Payment</div>
                        <div className="value">{summary.pendingJobs}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#f59e0b')}>
                        <div className="label">Partially Paid</div>
                        <div className="value">{summary.partialJobs}</div>
                    </div>
                    <div css={pageStyles.summaryCard('#10b981')}>
                        <div className="label">Total Receivable</div>
                        <div className="value">{formatCurrency(summary.totalReceivable)}</div>
                    </div>
                </div>

                {/* Search & Filters */}
                <div css={pageStyles.searchRow}>
                    <div css={pageStyles.searchBox}>
                        <FaSearch size={14} />
                        <input
                            type="text"
                            placeholder="Search by job code, customer, shop..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                        />
                    </div>
                    <div css={pageStyles.filterTabs}>
                        {(['all', 'pending', 'partial', 'paid'] as const).map(f => (
                            <button
                                key={f}
                                css={pageStyles.filterTab(filter === f)}
                                onClick={() => setFilter(f)}
                            >
                                {f === 'all' ? 'All' : f === 'pending' ? 'Pending' : f === 'partial' ? 'Partial' : 'Paid'}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Jobs Table */}
                <div css={pageStyles.tableContainer}>
                    <table css={pageStyles.table}>
                        <thead>
                            <tr>
                                <th>Job Code</th>
                                <th>Customer</th>
                                <th>Status</th>
                                <th>Payment Status</th>
                                <th style={{ textAlign: 'right' }}>Amount</th>
                                <th style={{ textAlign: 'right' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredJobs.length === 0 ? (
                                <tr>
                                    <td colSpan={6}>
                                        <div css={pageStyles.emptyState}>
                                            <h3>No jobs found</h3>
                                            <p>Try adjusting your search or filter</p>
                                        </div>
                                    </td>
                                </tr>
                            ) : (
                                filteredJobs.map(job => (
                                    <tr key={job.id}>
                                        <td>
                                            <span
                                                css={pageStyles.jobCode}
                                                onClick={() => router.push(`/admin/jobs/${job.id}`)}
                                            >
                                                {job.jobCode}
                                            </span>
                                        </td>
                                        <td>
                                            <div style={{ fontWeight: 500 }}>{job.customerName}</div>
                                            {job.shopName && (
                                                <div style={{ fontSize: '12px', color: '#64748b' }}>{job.shopName}</div>
                                            )}
                                        </td>
                                        <td style={{ textTransform: 'capitalize', fontSize: '13px', color: '#64748b' }}>
                                            {job.status.replace(/_/g, ' ')}
                                        </td>
                                        <td>
                                            <span css={pageStyles.statusBadge(job.paymentStatus)}>
                                                {job.paymentStatus}
                                            </span>
                                        </td>
                                        <td css={pageStyles.amountCell}>
                                            <div className="total">{formatCurrency(job.totalAmount)}</div>
                                            {job.amountPaid > 0 && (
                                                <div className="paid">Paid: {formatCurrency(job.amountPaid)}</div>
                                            )}
                                            {job.totalAmount - job.amountPaid > 0 && job.totalAmount > 0 && (
                                                <div className="remaining">
                                                    Due: {formatCurrency(job.totalAmount - job.amountPaid)}
                                                </div>
                                            )}
                                        </td>
                                        <td>
                                            <div css={pageStyles.actions}>
                                                {job.paymentStatus !== 'paid' && (
                                                    <button
                                                        css={pageStyles.actionBtn('#10b981')}
                                                        onClick={() => openPaymentModal(job)}
                                                    >
                                                        <FaMoneyBillWave size={12} />
                                                        Record Payment
                                                    </button>
                                                )}
                                                {job.paymentStatus === 'paid' && (
                                                    <button
                                                        css={pageStyles.actionBtn('#8b5cf6')}
                                                        onClick={() => window.open(`/accounts/invoice/${job.id}`, '_blank')}
                                                    >
                                                        <FaFileInvoice size={12} />
                                                        Generate Invoice
                                                    </button>
                                                )}
                                                <button
                                                    css={pageStyles.actionBtn('#3b82f6')}
                                                    onClick={() => openAmountModal(job)}
                                                >
                                                    <FaFileInvoice size={12} />
                                                    Set Amount
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Record Payment Modal */}
            <Modal
                isOpen={showPaymentModal}
                onClose={() => setShowPaymentModal(false)}
                title={`Record Payment - ${selectedJob?.jobCode}`}
                width="450px"
            >
                <div css={pageStyles.modalContent}>
                    {selectedJob && (
                        <div style={{ padding: '12px', background: '#f8fafc', borderRadius: '8px', marginBottom: '20px' }}>
                            <div style={{ fontSize: '14px', color: '#64748b' }}>
                                {selectedJob.customerName}
                                {selectedJob.shopName && ` • ${selectedJob.shopName}`}
                            </div>
                            <div style={{ fontSize: '18px', fontWeight: '600', marginTop: '4px' }}>
                                Total: {formatCurrency(selectedJob.totalAmount)} |
                                Due: {formatCurrency(selectedJob.totalAmount - selectedJob.amountPaid)}
                            </div>
                        </div>
                    )}
                    <div css={pageStyles.formGroup}>
                        <label>Payment Amount (£)</label>
                        <input
                            type="number"
                            value={paymentAmount}
                            onChange={(e) => setPaymentAmount(e.target.value)}
                            placeholder="Enter amount"
                            min="0"
                            step="0.01"
                        />
                    </div>
                    <div css={pageStyles.formGroup}>
                        <label>Payment Mode</label>
                        <select
                            value={paymentMode}
                            onChange={(e) => setPaymentMode(e.target.value as PaymentRecord['mode'])}
                        >
                            <option value="cash">Cash</option>
                            <option value="card">Card</option>
                            <option value="upi">UPI</option>
                            <option value="bank_transfer">Bank Transfer</option>
                            <option value="cheque">Cheque</option>
                        </select>
                    </div>
                    <div css={pageStyles.formGroup}>
                        <label>Notes (Optional)</label>
                        <textarea
                            value={paymentNotes}
                            onChange={(e) => setPaymentNotes(e.target.value)}
                            placeholder="Any additional notes..."
                        />
                    </div>
                </div>
                <div css={pageStyles.modalFooter}>
                    <Button variant="ghost" onClick={() => setShowPaymentModal(false)}>
                        <FaTimes style={{ marginRight: '6px' }} /> Cancel
                    </Button>
                    <Button
                        onClick={handleRecordPayment}
                        disabled={!paymentAmount || isSubmitting}
                    >
                        {isSubmitting ? 'Recording...' : 'Record Payment'}
                    </Button>
                </div>
            </Modal>

            {/* Set Amount Modal */}
            <Modal
                isOpen={showAmountModal}
                onClose={() => setShowAmountModal(false)}
                title={`Set Job Amount - ${selectedJob?.jobCode}`}
                width="400px"
            >
                <div css={pageStyles.modalContent}>
                    {selectedJob && (
                        <div style={{ padding: '12px', background: '#f8fafc', borderRadius: '8px', marginBottom: '20px' }}>
                            <div style={{ fontSize: '14px', color: '#64748b' }}>
                                {selectedJob.customerName}
                            </div>
                            <div style={{ fontSize: '14px', marginTop: '4px' }}>
                                Current Amount: <strong>{formatCurrency(selectedJob.totalAmount)}</strong>
                            </div>
                        </div>
                    )}
                    <div css={pageStyles.formGroup}>
                        <label>New Amount (£)</label>
                        <input
                            type="number"
                            value={newAmount}
                            onChange={(e) => setNewAmount(e.target.value)}
                            placeholder="Enter amount"
                            min="0"
                            step="0.01"
                        />
                    </div>
                </div>
                <div css={pageStyles.modalFooter}>
                    <Button variant="ghost" onClick={() => setShowAmountModal(false)}>
                        Cancel
                    </Button>
                    <Button
                        onClick={handleSetAmount}
                        disabled={!newAmount || isSubmitting}
                    >
                        {isSubmitting ? 'Updating...' : 'Update Amount'}
                    </Button>
                </div>
            </Modal>
        </>
    );
};

AccountsJobsPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AccountsJobsPage;
