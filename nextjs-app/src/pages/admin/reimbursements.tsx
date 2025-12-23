import { type ReactElement, useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { css, useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard, StatCard } from '@/components/dashboard';
import { Table, Button, Badge, Modal, Select } from '@/components/ui';
import { getReimbursements, updateReimbursementStatus } from '@/services';
import type { Reimbursement, ReimbursementStatus } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/reimbursements.styles';

/**
 * Admin Reimbursements Page
 * Review and manage expense claims with filtering
 */

const AdminReimbursementsPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const [reimbursements, setReimbursements] = useState<Reimbursement[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedReimbursement, setSelectedReimbursement] = useState<Reimbursement | null>(null);
    const [isUpdating, setIsUpdating] = useState(false);

    // Filters
    const [statusFilter, setStatusFilter] = useState<string>('');

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            setLoading(true);
            const data = await getReimbursements();
            setReimbursements(data);
        } catch (error) {
            console.error('Failed to load reimbursements:', error);
        } finally {
            setLoading(false);
        }
    };

    // Filtered data
    const filteredReimbursements = useMemo(() => {
        if (!statusFilter) return reimbursements;
        return reimbursements.filter(r => r.status === statusFilter);
    }, [reimbursements, statusFilter]);

    // Summary stats
    const stats = useMemo(() => {
        const pending = reimbursements.filter(r => r.status === 'pending');
        const approved = reimbursements.filter(r => r.status === 'approved');
        const paid = reimbursements.filter(r => r.status === 'paid');

        return {
            pendingCount: pending.length,
            pendingAmount: pending.reduce((sum, r) => sum + r.amount, 0),
            approvedCount: approved.length,
            approvedAmount: approved.reduce((sum, r) => sum + r.amount, 0),
            paidCount: paid.length,
            paidAmount: paid.reduce((sum, r) => sum + r.amount, 0),
            totalAmount: reimbursements.reduce((sum, r) => sum + r.amount, 0),
        };
    }, [reimbursements]);

    const handleStatusUpdate = async (id: string, status: ReimbursementStatus) => {
        setIsUpdating(true);
        try {
            const success = await updateReimbursementStatus(id, status);
            if (success) {
                await loadData();
                setSelectedReimbursement(null);
            } else {
                alert('Failed to update status. Please try again.');
            }
        } catch (error) {
            console.error('Error updating status:', error);
            alert('An error occurred.');
        } finally {
            setIsUpdating(false);
        }
    };

    const columns = [
        { key: 'emp_name', header: 'Employee' },
        { key: 'reimbursement_date', header: 'Date', width: '110px' },
        {
            key: 'purpose',
            header: 'Purpose',
            render: (row: Reimbursement) => (
                <span style={{
                    maxWidth: '200px',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                    display: 'block'
                }}>
                    {row.purpose}
                </span>
            )
        },
        {
            key: 'amount', header: 'Amount', width: '100px', render: (row: Reimbursement) => (
                <span css={styles.amount}>£{row.amount.toFixed(2)}</span>
            )
        },
        {
            key: 'status', header: 'Status', width: '110px', render: (row: Reimbursement) => (
                <Badge
                    variant={
                        row.status === 'paid' ? 'success' :
                            row.status === 'approved' ? 'info' :
                                row.status === 'rejected' ? 'error' : 'warning'
                    }
                    size="sm"
                    className={css({ textTransform: 'capitalize' }).toString()}
                >
                    {row.status}
                </Badge>
            )
        },
        {
            key: 'actions', header: 'Actions', width: '140px', render: (row: Reimbursement) => (
                <div style={{ display: 'flex', gap: '4px' }}>
                    <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => setSelectedReimbursement(row)}
                    >
                        View
                    </Button>
                    {row.status === 'approved' && (
                        <Button
                            size="sm"
                            variant="primary"
                            onClick={() => handleStatusUpdate(row.id, 'paid')}
                        >
                            Pay
                        </Button>
                    )}
                </div>
            )
        },
    ];

    return (
        <>
            <Head>
                <title>Reimbursements | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                <h1 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '24px' }}>Reimbursements</h1>

                {/* Summary Stats */}
                <div style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
                    gap: '16px',
                    marginBottom: '24px'
                }}>
                    <StatCard
                        label="Pending"
                        value={`${stats.pendingCount}`}
                        change={`£${stats.pendingAmount.toFixed(0)}`}
                        positive={false}
                    />
                    <StatCard
                        label="Approved (Awaiting Payment)"
                        value={`${stats.approvedCount}`}
                        change={`£${stats.approvedAmount.toFixed(0)}`}
                        positive={true}
                    />
                    <StatCard
                        label="Paid"
                        value={`${stats.paidCount}`}
                        change={`£${stats.paidAmount.toFixed(0)}`}
                        positive={true}
                    />
                </div>

                <SectionCard title="Expense Claims" iconColor="#10b981">
                    {/* Filters */}
                    <div style={{
                        display: 'flex',
                        gap: '12px',
                        marginBottom: '16px',
                        alignItems: 'center'
                    }}>
                        <div style={{ width: '180px' }}>
                            <Select
                                value={statusFilter}
                                onChange={(e) => setStatusFilter(e.target.value)}
                                options={[
                                    { value: '', label: 'All Statuses' },
                                    { value: 'pending', label: 'Pending' },
                                    { value: 'approved', label: 'Approved' },
                                    { value: 'rejected', label: 'Rejected' },
                                    { value: 'paid', label: 'Paid' },
                                ]}
                                size="sm"
                            />
                        </div>
                        <span style={{ fontSize: '13px', color: '#6b7280' }}>
                            Showing {filteredReimbursements.length} of {reimbursements.length} claims
                        </span>
                    </div>

                    <Table
                        columns={columns}
                        data={filteredReimbursements}
                        loading={loading}
                        emptyMessage="No reimbursement requests found."
                    />
                </SectionCard>
            </div>

            {/* Detail Modal */}
            <Modal
                isOpen={!!selectedReimbursement}
                onClose={() => setSelectedReimbursement(null)}
                title="Reimbursement Details"
                footer={
                    <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        {selectedReimbursement?.status === 'pending' && (
                            <>
                                <Button
                                    variant="outline"
                                    onClick={() => handleStatusUpdate(selectedReimbursement.id, 'rejected')}
                                    disabled={isUpdating}
                                >
                                    Reject
                                </Button>
                                <Button
                                    variant="primary"
                                    onClick={() => handleStatusUpdate(selectedReimbursement.id, 'approved')}
                                    disabled={isUpdating}
                                >
                                    {isUpdating ? 'Updating...' : 'Approve'}
                                </Button>
                            </>
                        )}
                        {selectedReimbursement?.status === 'approved' && (
                            <Button
                                variant="primary"
                                onClick={() => handleStatusUpdate(selectedReimbursement.id, 'paid')}
                                disabled={isUpdating}
                            >
                                {isUpdating ? 'Updating...' : 'Mark as Paid'}
                            </Button>
                        )}
                        {(selectedReimbursement?.status === 'paid' || selectedReimbursement?.status === 'rejected') && (
                            <Button onClick={() => setSelectedReimbursement(null)}>
                                Close
                            </Button>
                        )}
                    </div>
                }
            >
                {selectedReimbursement && (
                    <div css={styles.modalContent}>
                        <div css={styles.detailRow}>
                            <span css={styles.label}>Employee</span>
                            <span css={styles.value}>{selectedReimbursement.emp_name} ({selectedReimbursement.emp_id})</span>
                        </div>

                        <div css={styles.detailRow}>
                            <span css={styles.label}>Date</span>
                            <span css={styles.value}>{selectedReimbursement.reimbursement_date}</span>
                        </div>

                        <div css={styles.detailRow}>
                            <span css={styles.label}>Amount</span>
                            <span css={styles.amount}>£{selectedReimbursement.amount.toFixed(2)}</span>
                        </div>

                        <div css={styles.detailRow}>
                            <span css={styles.label}>Status</span>
                            <Badge
                                variant={
                                    selectedReimbursement.status === 'paid' ? 'success' :
                                        selectedReimbursement.status === 'approved' ? 'info' :
                                            selectedReimbursement.status === 'rejected' ? 'error' : 'warning'
                                }
                                size="sm"
                                className={css({ textTransform: 'capitalize' }).toString()}
                            >
                                {selectedReimbursement.status}
                            </Badge>
                        </div>

                        <div css={styles.detailRow}>
                            <span css={styles.label}>Purpose</span>
                            <span css={styles.value}>{selectedReimbursement.purpose}</span>
                        </div>

                        {selectedReimbursement.receipt_url && (
                            <div css={styles.detailRow}>
                                <span css={styles.label}>Receipt</span>
                                <a
                                    href={selectedReimbursement.receipt_url}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    css={styles.receiptLink}
                                >
                                    View Receipt ↗
                                </a>
                            </div>
                        )}

                        {selectedReimbursement.remarks && (
                            <div css={styles.remarksContainer}>
                                <span>Remarks:</span>
                                <p>{selectedReimbursement.remarks}</p>
                            </div>
                        )}
                    </div>
                )}
            </Modal>
        </>
    );
};

AdminReimbursementsPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AdminReimbursementsPage;
