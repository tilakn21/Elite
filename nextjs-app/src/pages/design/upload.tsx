/**
 * Design - Job Details
 * View job details, upload designs, and manage workflow
 */

import { useState, useEffect, useRef, useCallback } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { designService } from '@/services';
import { sendImageMessage, sendMessage } from '@/services/chat.service';
import type { DesignJob, DesignJobStatus } from '@/types/design';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/design/upload.styles';

// Status helper
const getStatusInfo = (status: DesignJobStatus) => {
    const statusMap: Record<DesignJobStatus, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' },
        in_progress: { label: 'In Progress', color: '#1E40AF', bgColor: '#DBEAFE' },
        draft_uploaded: { label: 'Awaiting Approval', color: '#5B21B6', bgColor: '#EDE9FE' },
        changes_requested: { label: 'Changes Requested', color: '#DC2626', bgColor: '#FEE2E2' },
        approved: { label: 'Approved', color: '#065F46', bgColor: '#D1FAE5' },
        completed: { label: 'Completed', color: '#047857', bgColor: '#ECFDF5' },
    };
    return statusMap[status] || statusMap.pending;
};

export default function JobDetailsPage() {
    const theme = useTheme();
    const router = useRouter();
    const { jobId } = router.query;
    const { state: authState } = useAuth();
    const fileInputRef = useRef<HTMLInputElement>(null);

    const [job, setJob] = useState<DesignJob | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isStarting, setIsStarting] = useState(false);
    const [isSending, setIsSending] = useState(false);

    // Image upload state
    const [selectedImages, setSelectedImages] = useState<File[]>([]);
    const [imagePreviews, setImagePreviews] = useState<string[]>([]);
    const [showSendModal, setShowSendModal] = useState(false);

    const designerId = authState.user?.employeeId || '';
    const designerName = authState.user?.name || 'Designer';

    // Determine if actions are enabled based on status
    const isPending = job?.status === 'pending';
    const isInProgress = job?.status === 'in_progress';
    const isChangesRequested = job?.status === 'changes_requested';
    const isInReview = job?.status === 'draft_uploaded';
    const isApproved = job?.status === 'approved' || job?.status === 'completed';
    // Allow upload when in_progress OR when changes are requested
    const canUpload = isInProgress || isChangesRequested;
    const canTakeActions = isInProgress || isChangesRequested;

    useEffect(() => {
        if (!jobId) return;

        async function loadJob() {
            try {
                const jobs = await designService.getDesignJobs();
                const found = jobs.find(j => j.id === jobId);
                if (found) setJob(found);
            } catch (error) {
                console.error('Failed to load job:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJob();
    }, [jobId]);

    // Handle starting the job
    const handleStartJob = useCallback(async () => {
        if (!job) return;
        setIsStarting(true);
        try {
            await designService.updateStatus(job.id, 'in_progress');
            setJob({ ...job, status: 'in_progress' });
        } catch (error) {
            console.error('Failed to start job:', error);
        } finally {
            setIsStarting(false);
        }
    }, [job]);

    // Handle image selection
    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const files = e.target.files;
        if (!files) return;

        const newFiles = Array.from(files);
        setSelectedImages(prev => [...prev, ...newFiles]);

        newFiles.forEach(file => {
            const url = URL.createObjectURL(file);
            setImagePreviews(prev => [...prev, url]);
        });
    };

    // Remove an image from selection
    const removeImage = (index: number) => {
        setSelectedImages(prev => prev.filter((_, i) => i !== index));
        setImagePreviews(prev => {
            const urlToRevoke = prev[index];
            if (urlToRevoke) URL.revokeObjectURL(urlToRevoke);
            return prev.filter((_, i) => i !== index);
        });
    };

    // Send designs to customer via chat
    const handleSendToCustomer = useCallback(async () => {
        if (!job || selectedImages.length === 0) return;

        setIsSending(true);
        setShowSendModal(false);

        try {
            // Send a notification message first
            await sendMessage(
                job.id,
                designerId,
                'designer',
                `📐 Design proof submitted for Job #${job.jobCode}. Please review and approve.`,
                designerName
            );

            // Upload each image and send as chat message
            for (const file of selectedImages) {
                await sendImageMessage(job.id, designerId, 'designer', file, designerName);
            }

            // Update job status to in_review
            await designService.updateStatus(job.id, 'draft_uploaded');
            setJob({ ...job, status: 'draft_uploaded' });

            // Clear selected images
            imagePreviews.forEach(url => URL.revokeObjectURL(url));
            setSelectedImages([]);
            setImagePreviews([]);

            alert('Design sent to customer for approval!');
        } catch (error) {
            console.error('Failed to send designs:', error);
            alert('Failed to send designs. Please try again.');
        } finally {
            setIsSending(false);
        }
    }, [job, selectedImages, imagePreviews, designerId, designerName]);

    // Navigate to chat
    const handleChatWithCustomer = () => {
        router.push('/design/chats');
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

    if (!job) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <h1>Job not found</h1>
                    <button onClick={() => router.back()}>Go Back</button>
                </div>
            </AppLayout>
        );
    }

    const statusInfo = getStatusInfo(job.status);

    return (
        <>
            <Head>
                <title>Job Details | {job.customerName}</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Header */}
                    <div css={styles.header}>
                        <div className="back-link" onClick={() => router.push('/design/jobs')}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                <path d="M19 12H5" /><path d="M12 19l-7-7 7-7" />
                            </svg>
                            Back to Jobs
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                            <h1>{job.customerName} - #{job.jobCode}</h1>
                            <span style={{
                                padding: '6px 14px',
                                borderRadius: '20px',
                                fontSize: '13px',
                                fontWeight: 500,
                                background: statusInfo.bgColor,
                                color: statusInfo.color,
                            }}>
                                {statusInfo.label}
                            </span>
                        </div>
                    </div>

                    <div css={styles.grid}>
                        {/* Main Content */}
                        <div>
                            <div css={styles.card}>
                                <h2>Job Specifications</h2>
                                <div css={styles.detailRow}>
                                    <span className="label">Shop Name</span>
                                    <span className="value">{job.shopName || '-'}</span>
                                </div>
                                <div css={styles.detailRow}>
                                    <span className="label">Job Code</span>
                                    <span className="value">{job.jobCode}</span>
                                </div>
                                <div css={styles.detailRow}>
                                    <span className="label">Assigned Date</span>
                                    <span className="value">{new Date(job.assignedDate).toLocaleDateString()}</span>
                                </div>
                                <div css={styles.detailRow}>
                                    <span className="label">Priority</span>
                                    <span className="value" style={{ textTransform: 'capitalize' }}>{job.priority}</span>
                                </div>
                            </div>

                            <div css={styles.card}>
                                <h2>Reference Images from Salesperson</h2>
                                {job.salespersonImages && job.salespersonImages.length > 0 ? (
                                    <div css={styles.imagesGrid}>
                                        {job.salespersonImages.map((img, i) => (
                                            <div key={i} className="image-box">
                                                <img src={img} alt={`Reference ${i + 1}`} />
                                            </div>
                                        ))}
                                    </div>
                                ) : (
                                    <p style={{ color: '#9CA3AF', textAlign: 'center', margin: '20px 0' }}>
                                        No reference images provided
                                    </p>
                                )}
                            </div>
                        </div>

                        {/* Sidebar */}
                        <div>
                            {/* Upload Section */}
                            <div css={styles.card} style={{ opacity: canUpload ? 1 : 0.6 }}>
                                <h2>{isChangesRequested ? 'Upload Modified Design' : 'Upload Design Proof'}</h2>

                                {!canUpload && isPending && (
                                    <div style={{
                                        padding: '16px',
                                        background: '#FEF3C7',
                                        borderRadius: '8px',
                                        color: '#92400E',
                                        marginBottom: '16px',
                                        fontSize: '14px'
                                    }}>
                                        ⚠️ Start the job first to enable uploads
                                    </div>
                                )}

                                {isChangesRequested && (
                                    <div style={{
                                        padding: '16px',
                                        background: '#FEE2E2',
                                        borderRadius: '8px',
                                        color: '#DC2626',
                                        marginBottom: '16px',
                                        fontSize: '14px'
                                    }}>
                                        🔄 Customer requested changes. Please upload the modified design.
                                    </div>
                                )}

                                {isInReview && (
                                    <div style={{
                                        padding: '16px',
                                        background: '#EDE9FE',
                                        borderRadius: '8px',
                                        color: '#5B21B6',
                                        marginBottom: '16px',
                                        fontSize: '14px'
                                    }}>
                                        ⏳ Waiting for customer approval
                                    </div>
                                )}

                                <input
                                    type="file"
                                    ref={fileInputRef}
                                    accept="image/*"
                                    multiple
                                    onChange={handleImageSelect}
                                    style={{ display: 'none' }}
                                    disabled={!canUpload}
                                />

                                <div
                                    css={styles.uploadArea(false)}
                                    onClick={() => canUpload && fileInputRef.current?.click()}
                                    style={{
                                        cursor: canUpload ? 'pointer' : 'not-allowed',
                                        opacity: canUpload ? 1 : 0.5
                                    }}
                                >
                                    <div className="icon">📁</div>
                                    <p>Click to upload images</p>
                                    <span>Supports JPG, PNG (multiple)</span>
                                </div>

                                {/* Image Previews */}
                                {imagePreviews.length > 0 && (
                                    <div style={{ marginTop: '16px' }}>
                                        <div style={{
                                            display: 'grid',
                                            gridTemplateColumns: 'repeat(3, 1fr)',
                                            gap: '8px'
                                        }}>
                                            {imagePreviews.map((url, idx) => (
                                                <div key={idx} style={{ position: 'relative' }}>
                                                    <img
                                                        src={url}
                                                        alt={`Preview ${idx + 1}`}
                                                        style={{
                                                            width: '100%',
                                                            height: '80px',
                                                            objectFit: 'cover',
                                                            borderRadius: '8px'
                                                        }}
                                                    />
                                                    <button
                                                        onClick={() => removeImage(idx)}
                                                        style={{
                                                            position: 'absolute',
                                                            top: '-6px',
                                                            right: '-6px',
                                                            width: '22px',
                                                            height: '22px',
                                                            borderRadius: '50%',
                                                            border: 'none',
                                                            background: '#EF4444',
                                                            color: 'white',
                                                            cursor: 'pointer',
                                                            fontSize: '12px',
                                                        }}
                                                    >
                                                        ×
                                                    </button>
                                                </div>
                                            ))}
                                        </div>

                                        <button
                                            css={styles.button('primary')}
                                            onClick={() => setShowSendModal(true)}
                                            style={{ marginTop: '16px', width: '100%' }}
                                            disabled={isSending}
                                        >
                                            {isSending ? 'Sending...' : `Send ${selectedImages.length} Design(s) to Customer`}
                                        </button>
                                    </div>
                                )}
                            </div>

                            {/* Actions */}
                            <div css={styles.card} style={{ opacity: canTakeActions || isInReview ? 1 : 0.6 }}>
                                <h2>Actions</h2>
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                                    <button
                                        css={styles.button('primary')}
                                        onClick={handleChatWithCustomer}
                                        disabled={!canTakeActions && !isInReview}
                                    >
                                        💬 Chat with Customer
                                    </button>
                                    <button
                                        css={styles.button('secondary')}
                                        onClick={() => window.open(`mailto:?subject=Question regarding job ${job.jobCode}`, '_blank')}
                                        disabled={!canTakeActions}
                                    >
                                        📧 Contact Salesperson
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Bottom action bar for pending jobs */}
                    {isPending && (
                        <div style={{
                            position: 'fixed',
                            bottom: 0,
                            left: '188px',
                            right: 0,
                            padding: '16px 32px',
                            background: 'white',
                            borderTop: '1px solid #E5E7EB',
                            boxShadow: '0 -4px 12px rgba(0,0,0,0.08)',
                            display: 'flex',
                            justifyContent: 'flex-end',
                        }}>
                            <button
                                onClick={handleStartJob}
                                disabled={isStarting}
                                style={{
                                    padding: '14px 40px',
                                    background: '#4F46E5',
                                    color: 'white',
                                    border: 'none',
                                    borderRadius: '10px',
                                    fontSize: '15px',
                                    fontWeight: 600,
                                    cursor: isStarting ? 'not-allowed' : 'pointer',
                                    opacity: isStarting ? 0.7 : 1,
                                }}
                            >
                                {isStarting ? 'Starting...' : '🚀 Start Job'}
                            </button>
                        </div>
                    )}

                    {/* Approved status - move to production */}
                    {isApproved && (
                        <div style={{
                            position: 'fixed',
                            bottom: 0,
                            left: '188px',
                            right: 0,
                            padding: '16px 32px',
                            background: '#D1FAE5',
                            borderTop: '1px solid #10B981',
                            display: 'flex',
                            justifyContent: 'center',
                            alignItems: 'center',
                            gap: '16px'
                        }}>
                            <span style={{ color: '#065F46', fontWeight: 500 }}>
                                ✅ Design Approved! Ready for production.
                            </span>
                        </div>
                    )}
                </div>
            </AppLayout>

            {/* Send to Customer Confirmation Modal */}
            {showSendModal && (
                <div style={{
                    position: 'fixed',
                    inset: 0,
                    background: 'rgba(0,0,0,0.5)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 1000,
                }}>
                    <div style={{
                        background: 'white',
                        borderRadius: '16px',
                        padding: '24px',
                        maxWidth: '400px',
                        width: '90%',
                    }}>
                        <h3 style={{ margin: '0 0 12px', fontSize: '18px' }}>Send Design for Approval?</h3>
                        <p style={{ margin: '0 0 20px', color: '#6B7280' }}>
                            This will send {selectedImages.length} image(s) to the customer via chat
                            and update the job status to &quot;Awaiting Approval&quot;.
                        </p>
                        <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                            <button
                                onClick={() => setShowSendModal(false)}
                                style={{
                                    padding: '10px 20px',
                                    border: '1px solid #E5E7EB',
                                    background: 'white',
                                    borderRadius: '8px',
                                    cursor: 'pointer',
                                }}
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleSendToCustomer}
                                style={{
                                    padding: '10px 20px',
                                    border: 'none',
                                    background: '#4F46E5',
                                    color: 'white',
                                    borderRadius: '8px',
                                    cursor: 'pointer',
                                }}
                            >
                                Send to Customer
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
}
