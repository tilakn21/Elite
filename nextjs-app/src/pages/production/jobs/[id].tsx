/**
 * Production Job Details Page
 * Shows design proofs, salesperson site details, and production actions
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { css } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { supabase } from '@/services/supabase';
import { productionService } from '@/services';

interface JobDetails {
    id: string;
    jobCode: string;
    status: string;
    // Receptionist data
    customerName: string;
    shopName: string;
    phone: string;
    email: string;
    city: string;
    area: string;
    landmark: string;
    // Salesperson data
    typeOfSign: string;
    material: string;
    tools: string;
    productionTime: string;
    fittingTime: string;
    measurements: string;
    windowMeasurements: string;
    stickSide: string;
    extraDetails: string;
    siteImages: string[];
    // Design data
    designStatus: string;
    designProofs: string[];
    // Production data
    productionStatus: string;
    progress: number;
    assignedWorkers: string[];
}

// Styles
const styles = {
    container: css`
        max-width: 1000px;
        margin: 0 auto;
        padding: 24px;
    `,
    header: css`
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
        
        h1 {
            font-size: 24px;
            font-weight: 700;
            margin: 0;
        }
        
        .job-code {
            color: #6B7280;
            font-size: 14px;
            margin-top: 4px;
        }
    `,
    backButton: css`
        padding: 8px 16px;
        background: transparent;
        border: 1px solid #E5E7EB;
        border-radius: 8px;
        cursor: pointer;
        font-size: 14px;
        
        &:hover {
            background: #F9FAFB;
        }
    `,
    section: css`
        background: white;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        
        h2 {
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 16px 0;
            padding-bottom: 12px;
            border-bottom: 1px solid #E5E7EB;
        }
    `,
    grid: css`
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
        
        @media (max-width: 600px) {
            grid-template-columns: 1fr;
        }
    `,
    field: css`
        .label {
            font-size: 12px;
            color: #6B7280;
            margin-bottom: 4px;
        }
        .value {
            font-size: 14px;
            font-weight: 500;
            color: #1F2937;
        }
    `,
    imageGrid: css`
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 12px;
        
        img {
            width: 100%;
            height: 120px;
            object-fit: cover;
            border-radius: 8px;
            cursor: pointer;
            transition: transform 0.2s;
            
            &:hover {
                transform: scale(1.02);
            }
        }
    `,
    actionBar: css`
        display: flex;
        gap: 12px;
        margin-top: 24px;
        
        button {
            flex: 1;
            padding: 14px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            border: none;
            
            &:disabled {
                opacity: 0.6;
                cursor: not-allowed;
            }
        }
    `,
    loading: css`
        display: flex;
        justify-content: center;
        align-items: center;
        height: 300px;
    `,
    statusBadge: (color: string, bgColor: string) => css`
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        background: ${bgColor};
        color: ${color};
    `,
};

// Status helper
const getStatusInfo = (status: string) => {
    const statusMap: Record<string, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' },
        in_progress: { label: 'In Production', color: '#1E40AF', bgColor: '#DBEAFE' },
        at_printing: { label: 'At Printing', color: '#B45309', bgColor: '#FEF3C7' },
        ready_for_framing: { label: 'Ready for Framing', color: '#3730A3', bgColor: '#E0E7FF' },
        framing_in_progress: { label: 'Framing', color: '#4F46E5', bgColor: '#EEF2FF' },
        completed: { label: 'Completed', color: '#065F46', bgColor: '#D1FAE5' },
    };
    return statusMap[status] || { label: status, color: '#6B7280', bgColor: '#F3F4F6' };
};

export default function ProductionJobDetailsPage() {
    const router = useRouter();
    const { id } = router.query;

    const [job, setJob] = useState<JobDetails | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState(false);
    const [fullscreenImage, setFullscreenImage] = useState<string | null>(null);

    useEffect(() => {
        if (!id) return;

        async function loadJob() {
            try {
                const { data, error } = await supabase
                    .from('jobs')
                    .select('*')
                    .eq('id', id)
                    .single();

                if (error || !data) {
                    console.error('Error loading job:', error);
                    return;
                }

                const receptionist = data.receptionist || {};
                const salesperson = data.salesperson || {};
                const design = data.design || {};
                const production = data.production || {};

                // Map main status logic if production status is stale/missing (reuse logic from service ideally, or simplified here)
                let prodStatus = production.status || 'pending';
                if (['printing_queued', 'printing_started'].includes(data.status)) prodStatus = 'at_printing';
                if (data.status === 'printing_completed') prodStatus = 'ready_for_framing';
                if (data.status === 'framing_started') prodStatus = 'framing_in_progress';
                if (data.status === 'production_completed') prodStatus = 'completed';


                setJob({
                    id: data.id,
                    jobCode: data.job_code || data.id,
                    status: data.status,
                    // Receptionist
                    customerName: receptionist.customerName || 'Unknown',
                    shopName: receptionist.shopName || '',
                    phone: receptionist.phone || '',
                    email: receptionist.email || '',
                    city: receptionist.city || '',
                    area: receptionist.area || '',
                    landmark: receptionist.landMark || '',
                    // Salesperson
                    typeOfSign: salesperson.typeOfSign || '',
                    material: salesperson.material || '',
                    tools: salesperson.tools || salesperson.toolsNails || '',
                    productionTime: salesperson.productionTime || salesperson.timeForProduction || '',
                    fittingTime: salesperson.fittingTime || salesperson.timeForFitting || '',
                    measurements: salesperson.measurements || salesperson.signMeasurements || '',
                    windowMeasurements: salesperson.windowMeasurements || salesperson.windowVinylMeasurements || '',
                    stickSide: salesperson.stickSide || '',
                    extraDetails: salesperson.extraDetails || '',
                    siteImages: salesperson.images || [],
                    // Design
                    designStatus: design.status || '',
                    designProofs: design.drafts?.map((d: any) => d.url) || [],
                    // Production
                    productionStatus: prodStatus,
                    progress: production.progress || 0,
                    assignedWorkers: production.assignedWorkers || [],
                });
            } catch (error) {
                console.error('Failed to load job:', error);
            } finally {
                setIsLoading(false);
            }
        }

        loadJob();
    }, [id]);

    const handleStartProduction = async () => {
        if (!job) return;
        setActionLoading(true);
        try {
            const success = await productionService.startProduction(job.id);
            if (success) {
                setJob({ ...job, productionStatus: 'in_progress', progress: 0 });
            }
        } catch (error) {
            console.error('Failed to start production:', error);
        } finally {
            setActionLoading(false);
        }
    };

    const handleSendToPrinting = async () => {
        if (!job) return;
        setActionLoading(true);
        try {
            const success = await productionService.sendToPrinting(job.id);
            if (success) {
                setJob({ ...job, productionStatus: 'at_printing', progress: 50 });
            }
        } catch (error) {
            console.error('Failed to send to printing:', error);
        } finally {
            setActionLoading(false);
        }
    };

    const handleStartFraming = async () => {
        if (!job) return;
        setActionLoading(true);
        try {
            const success = await productionService.startFraming(job.id);
            if (success) {
                setJob({ ...job, productionStatus: 'framing_in_progress', progress: 75 });
            }
        } catch (error) {
            console.error('Failed to start framing:', error);
        } finally {
            setActionLoading(false);
        }
    };

    const handleCompleteProduction = async () => {
        if (!job) return;
        setActionLoading(true);
        try {
            const success = await productionService.completeProduction(job.id);
            if (success) {
                setJob({ ...job, productionStatus: 'completed', progress: 100 });
            }
        } catch (error) {
            console.error('Failed to complete production:', error);
        } finally {
            setActionLoading(false);
        }
    };

    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loading}>
                    <div>Loading...</div>
                </div>
            </AppLayout>
        );
    }

    if (!job) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.container}>
                    <p>Job not found</p>
                    <button onClick={() => router.back()}>Go Back</button>
                </div>
            </AppLayout>
        );
    }

    const statusInfo = getStatusInfo(job.productionStatus);

    return (
        <>
            <Head>
                <title>Job Details | Production</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.container}>
                    {/* Header */}
                    <div css={styles.header}>
                        <div>
                            <h1>{job.customerName}</h1>
                            <div className="job-code">#{job.jobCode} • {job.shopName}</div>
                        </div>
                        <button css={styles.backButton} onClick={() => router.back()}>
                            ← Back
                        </button>
                    </div>

                    {/* Status */}
                    <div css={styles.section}>
                        <h2>Production Status</h2>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                            <span css={styles.statusBadge(statusInfo.color, statusInfo.bgColor)}>
                                {statusInfo.label}
                            </span>
                            {job.productionStatus === 'in_progress' && (
                                <span style={{ fontSize: '14px', color: '#3B82F6', fontWeight: 600 }}>
                                    {job.progress}% Complete
                                </span>
                            )}
                        </div>
                    </div>

                    {/* Design Proofs */}
                    <div css={styles.section}>
                        <h2>📐 Design Proofs</h2>
                        {job.designProofs.length > 0 ? (
                            <div css={styles.imageGrid}>
                                {job.designProofs.map((url, i) => (
                                    <img
                                        key={i}
                                        src={url}
                                        alt={`Design ${i + 1}`}
                                        onClick={() => setFullscreenImage(url)}
                                    />
                                ))}
                            </div>
                        ) : (
                            <p style={{ color: '#6B7280', fontSize: '14px' }}>No design proofs uploaded yet</p>
                        )}
                    </div>

                    {/* Site Details from Salesperson */}
                    <div css={styles.section}>
                        <h2>📋 Site Details (Salesperson)</h2>
                        <div css={styles.grid}>
                            <div css={styles.field}>
                                <div className="label">Type of Sign</div>
                                <div className="value">{job.typeOfSign || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Material</div>
                                <div className="value">{job.material || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Measurements</div>
                                <div className="value">{job.measurements || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Window/Vinyl Measurements</div>
                                <div className="value">{job.windowMeasurements || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Stick Side</div>
                                <div className="value">{job.stickSide || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Tools Required</div>
                                <div className="value">{job.tools || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Production Time</div>
                                <div className="value">{job.productionTime || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Fitting Time</div>
                                <div className="value">{job.fittingTime || '-'}</div>
                            </div>
                        </div>
                        {job.extraDetails && (
                            <div css={styles.field} style={{ marginTop: '16px' }}>
                                <div className="label">Additional Notes</div>
                                <div className="value">{job.extraDetails}</div>
                            </div>
                        )}
                    </div>

                    {/* Site Photos */}
                    <div css={styles.section}>
                        <h2>📸 Site Photos</h2>
                        {job.siteImages.length > 0 ? (
                            <div css={styles.imageGrid}>
                                {job.siteImages.map((url, i) => (
                                    <img
                                        key={i}
                                        src={url}
                                        alt={`Site ${i + 1}`}
                                        onClick={() => setFullscreenImage(url)}
                                    />
                                ))}
                            </div>
                        ) : (
                            <p style={{ color: '#6B7280', fontSize: '14px' }}>No site photos available</p>
                        )}
                    </div>

                    {/* Customer & Location */}
                    <div css={styles.section}>
                        <h2>📍 Customer & Location</h2>
                        <div css={styles.grid}>
                            <div css={styles.field}>
                                <div className="label">Phone</div>
                                <div className="value">{job.phone || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Email</div>
                                <div className="value">{job.email || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">City</div>
                                <div className="value">{job.city || '-'}</div>
                            </div>
                            <div css={styles.field}>
                                <div className="label">Area</div>
                                <div className="value">{job.area || '-'}</div>
                            </div>
                            {job.landmark && (
                                <div css={styles.field}>
                                    <div className="label">Landmark</div>
                                    <div className="value">{job.landmark}</div>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Action Buttons */}
                    <div css={styles.actionBar}>
                        {job.productionStatus === 'pending' && (
                            <button
                                onClick={handleStartProduction}
                                disabled={actionLoading}
                                style={{ background: '#3B82F6', color: 'white' }}
                            >
                                {actionLoading ? 'Starting...' : '▶️ Start Production'}
                            </button>
                        )}
                        {job.productionStatus === 'in_progress' && (
                            <button
                                onClick={handleSendToPrinting}
                                disabled={actionLoading}
                                style={{ background: '#F59E0B', color: 'white' }}
                            >
                                {actionLoading ? 'Sending...' : '📤 Send to Printing'}
                            </button>
                        )}
                        {job.productionStatus === 'at_printing' && (
                            <button
                                disabled
                                style={{ background: '#FEF3C7', color: '#B45309', cursor: 'default' }}
                            >
                                ⏳ At Printing
                            </button>
                        )}
                        {job.productionStatus === 'ready_for_framing' && (
                            <button
                                onClick={handleStartFraming}
                                disabled={actionLoading}
                                style={{ background: '#4F46E5', color: 'white' }}
                            >
                                {actionLoading ? 'Starting...' : '🖼️ Start Framing'}
                            </button>
                        )}
                        {job.productionStatus === 'framing_in_progress' && (
                            <button
                                onClick={handleCompleteProduction}
                                disabled={actionLoading}
                                style={{ background: '#10B981', color: 'white' }}
                            >
                                {actionLoading ? 'Completing...' : '✅ Complete Job'}
                            </button>
                        )}
                        {job.productionStatus === 'completed' && (
                            <button
                                disabled
                                style={{ background: '#D1FAE5', color: '#065F46' }}
                            >
                                ✅ Production Completed
                            </button>
                        )}
                    </div>
                </div>
            </AppLayout>

            {/* Fullscreen Image Viewer */}
            {fullscreenImage && (
                <div
                    style={{
                        position: 'fixed',
                        inset: 0,
                        background: 'rgba(0, 0, 0, 0.9)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        zIndex: 2000,
                        cursor: 'pointer',
                    }}
                    onClick={() => setFullscreenImage(null)}
                >
                    <button
                        onClick={() => setFullscreenImage(null)}
                        style={{
                            position: 'absolute',
                            top: '20px',
                            right: '20px',
                            background: 'rgba(255,255,255,0.2)',
                            border: 'none',
                            color: 'white',
                            fontSize: '28px',
                            width: '44px',
                            height: '44px',
                            borderRadius: '50%',
                            cursor: 'pointer',
                        }}
                    >
                        ×
                    </button>
                    <img
                        src={fullscreenImage}
                        alt="Full size"
                        style={{
                            maxWidth: '95%',
                            maxHeight: '95%',
                            objectFit: 'contain',
                            borderRadius: '8px',
                        }}
                        onClick={(e) => e.stopPropagation()}
                    />
                </div>
            )}
        </>
    );
}
