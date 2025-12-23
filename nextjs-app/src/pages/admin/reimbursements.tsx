import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { css, useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard } from '@/components/dashboard';
import { Table, Button, Badge, Modal } from '@/components/ui';
import { getReimbursements, updateReimbursementStatus } from '@/services';
import type { Reimbursement, ReimbursementStatus } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/reimbursements.styles';

/**
 * Admin Reimbursements Page
 * Review and manage expense claims
 */

const AdminReimbursementsPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const [reimbursements, setReimbursements] = useState<Reimbursement[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedReimbursement, setSelectedReimbursement] = useState<Reimbursement | null>(null);
    const [isUpdating, setIsUpdating] = useState(false);

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

    const handleStatusUpdate = async (id: string, status: ReimbursementStatus) => {
        setIsUpdating(true);
        try {
            const success = await updateReimbursementStatus(id, status);
            if (success) {
                // Refresh list and close modal
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
        { key: 'reimbursement_date', header: 'Date', width: '120px' },
        { key: 'purpose', header: 'Purpose' },
        {
            key: 'amount', header: 'Amount', width: '100px', render: (row: Reimbursement) => (
                <span css={styles.amount}>£{row.amount.toFixed(2)}</span>
            )
        },
        {
            key: 'status', header: 'Status', width: '120px', render: (row: Reimbursement) => (
                <Badge
                    variant={
                        row.status === 'approved' || row.status === 'paid' ? 'success' :
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
            key: 'actions', header: 'Actions', width: '100px', render: (row: Reimbursement) => (
                <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => setSelectedReimbursement(row)}
                >
                    View
                </Button>
            )
        },
    ];

    return (
        <>
            <Head>
                <title>Reimbursements | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                <h1 style={{ fontSize: '24px', fontWeight: 'bold' }}>Reimbursements</h1>

                <SectionCard title="Expense Claims" iconColor="#10b981">
                    <Table
                        columns={columns}
                        data={reimbursements}
                        loading={loading}
                        emptyMessage="No reimbursement requests found."
                    />
                </SectionCard>
            </div>

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
                        {selectedReimbursement?.status !== 'pending' && (
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
                                    selectedReimbursement.status === 'approved' || selectedReimbursement.status === 'paid' ? 'success' :
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
