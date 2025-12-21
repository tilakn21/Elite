/**
 * Design - Upload Draft
 * View job details and upload design proofs
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { designService } from '@/services';
import type { DesignJob } from '@/types/design';
import { } from '@/state';
import * as styles from '@/styles/pages/design/upload.styles';

export default function UploadDraftPage() {
    const theme = useTheme();
    const router = useRouter();
    const { jobId } = router.query;

    const [job, setJob] = useState<DesignJob | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isUploading, setIsUploading] = useState(false);
    const [dragActive, setDragActive] = useState(false);

    useEffect(() => {
        if (!jobId) return;

        // Mock loading job details from list since we don't have getJobById in service yet
        // In real app, we should fetch by ID. Here we'll fetch all and find.
        async function loadJob() {
            try {
                const jobs = await designService.getDesignJobs();
                const found = jobs.find(j => j.id === jobId);
                if (found) setJob(found);
                else {
                    // Fallback to fetch single if list doesn't have it (or redirect)
                    console.error('Job not found');
                }
            } catch (error) {
                console.error('Failed to load job:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJob();
    }, [jobId]);

    const handleFile = async (file: File) => {
        if (!job) return;
        setIsUploading(true);
        try {
            const url = await designService.uploadDraft(job.id, file);
            if (url) {
                // Ideally refresh drafts list here
                await designService.updateStatus(job.id, 'draft_uploaded');
                router.push('/design/joblist');
            }
        } catch (error) {
            console.error('Upload failed:', error);
        } finally {
            setIsUploading(false);
        }
    };

    const handleDrop = (e: React.DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        setDragActive(false);
        if (e.dataTransfer.files && e.dataTransfer.files[0]) {
            handleFile(e.dataTransfer.files[0]);
        }
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

    return (
        <>
            <Head>
                <title>Upload Draft | {job.customerName}</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <div className="back-link" onClick={() => router.back()}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5" /><path d="M12 19l-7-7 7-7" /></svg>
                            Back to Job List
                        </div>
                        <h1>{job.customerName} - Design Draft</h1>
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
                                <h2>Reference Images</h2>
                                {job.salespersonImages && job.salespersonImages.length > 0 ? (
                                    <div css={styles.imagesGrid}>
                                        {job.salespersonImages.map((img, i) => (
                                            <div key={i} className="image-box">
                                                <img src={img} alt={`Reference ${i + 1}`} />
                                            </div>
                                        ))}
                                    </div>
                                ) : (
                                    <p style={{ color: '#9CA3AF', textAlign: 'center', margin: '20px 0' }}>No reference images provided</p>
                                )}
                            </div>
                        </div>

                        {/* Sidebar */}
                        <div>
                            <div css={styles.card}>
                                <h2>Upload Proof</h2>
                                <div
                                    css={styles.uploadArea(dragActive)}
                                    onDragEnter={() => setDragActive(true)}
                                    onDragLeave={() => setDragActive(false)}
                                    onDragOver={e => e.preventDefault()}
                                    onDrop={handleDrop}
                                    onClick={() => document.getElementById('file-input')?.click()}
                                >
                                    <div className="icon">☁️</div>
                                    <p>Click or drag to upload</p>
                                    <span>Supports JPG, PNG, PDF</span>
                                    <input
                                        id="file-input"
                                        type="file"
                                        hidden
                                        accept="image/*,.pdf"
                                        onChange={e => e.target.files?.[0] && handleFile(e.target.files[0])}
                                    />
                                </div>

                                {isUploading && (
                                    <div style={{ marginTop: '16px', textAlign: 'center', color: '#4F46E5' }}>
                                        Uploading...
                                    </div>
                                )}
                            </div>

                            <div css={styles.card}>
                                <h2>Actions</h2>
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                                    <button
                                        css={styles.button('primary')}
                                        onClick={() => designService.updateStatus(job.id, 'draft_uploaded').then(() => router.push('/design/jobs'))}
                                    >
                                        Mark as Uploaded
                                    </button>
                                    <button
                                        css={styles.button('secondary')}
                                        onClick={() => window.open(`mailto:?subject=Question regarding job ${job.jobCode}`, '_blank')}
                                    >
                                        Contact Salesperson
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
