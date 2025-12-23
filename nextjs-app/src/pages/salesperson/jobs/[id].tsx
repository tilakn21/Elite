/**
 * Salesperson Job Details Screen
 * Form to submit job details and collect payment
 */

import { useState, useEffect, useRef } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { salespersonService } from '@/services/salesperson.service';
import { supabase } from '@/services/supabase';
import { useAuth } from '@/state';
import { SalespersonData } from '@/types/salesperson';
import * as styles from '@/styles/pages/salesperson/jobs/styles';

interface JobDetails {
    customerName: string;
    jobCode: string;
    id: string;
    dateOfVisit: string;
    shopName: string;
    salespersonData?: {
        typeOfSign?: string;
        material?: string;
        tools?: string;
        productionTime?: string;
        fittingTime?: string;
        extraDetails?: string;
        measurements?: string;
        windowMeasurements?: string;
        stickSide?: string;
        paymentAmount?: number;
        modeOfPayment?: string;
        submittedAt?: string;
        images?: string[];
    };
}

export default function JobDetailsPage() {
    const theme = useTheme();
    const router = useRouter();
    const { id, view } = router.query;
    const { state: authState } = useAuth();
    const salespersonId = authState.user?.employeeId;

    // Check if in view-only mode
    const isViewMode = view === 'true';

    const [isLoading, setIsLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [job, setJob] = useState<JobDetails | null>(null);
    const [showPaymentModal, setShowPaymentModal] = useState(false);
    const [fullscreenImage, setFullscreenImage] = useState<string | null>(null);

    // Form State
    const [formData, setFormData] = useState({
        typeOfSign: 'design',
        material: '',
        tools: '',
        productionTimeValue: '1',
        productionTimeUnit: 'Days',
        fittingTimeValue: '1',
        fittingTimeUnit: 'Hours',
        extraDetails: '',
        measurements: '',
        windowMeasurements: '',
        stickSide: 'Inside',
    });

    const [paymentData, setPaymentData] = useState({
        totalAmount: '',
        amount: '',
        mode: 'Cash',
    });

    // Image upload state
    const [selectedImages, setSelectedImages] = useState<File[]>([]);
    const [imagePreviewUrls, setImagePreviewUrls] = useState<string[]>([]);
    const [isUploadingImages, setIsUploadingImages] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
        async function loadJob() {
            if (!id || typeof id !== 'string') return;

            try {
                // Fetch job details by job_code (which is passed as id in URL)
                const data = await salespersonService.getJobDetails(id);
                if (data) {
                    const receptionist = data.receptionist as Record<string, any>;
                    const salesperson = data.salesperson as Record<string, any> | null;

                    setJob({
                        customerName: receptionist?.customerName || '',
                        jobCode: (data.job_code as string) || (data.id as string),
                        id: data.id as string,
                        dateOfVisit: receptionist?.dateOfVisit || '',
                        shopName: receptionist?.shopName || '',
                        salespersonData: salesperson ? {
                            typeOfSign: salesperson.typeOfSign,
                            material: salesperson.material,
                            tools: salesperson.tools,
                            productionTime: salesperson.productionTime,
                            fittingTime: salesperson.fittingTime,
                            extraDetails: salesperson.extraDetails,
                            measurements: salesperson.measurements,
                            windowMeasurements: salesperson.windowMeasurements,
                            stickSide: salesperson.stickSide,
                            paymentAmount: salesperson.paymentAmount,
                            modeOfPayment: salesperson.modeOfPayment,
                            submittedAt: salesperson.submittedAt,
                            images: salesperson.images || [],
                        } : undefined,
                    });

                    // If in view mode and has salesperson data, pre-fill form
                    if (isViewMode && salesperson) {
                        const [prodVal, prodUnit] = (salesperson.productionTime || '1 Days').split(' ');
                        const [fitVal, fitUnit] = (salesperson.fittingTime || '1 Hours').split(' ');

                        setFormData({
                            typeOfSign: salesperson.typeOfSign || 'design',
                            material: salesperson.material || '',
                            tools: salesperson.tools || '',
                            productionTimeValue: prodVal || '1',
                            productionTimeUnit: prodUnit || 'Days',
                            fittingTimeValue: fitVal || '1',
                            fittingTimeUnit: fitUnit || 'Hours',
                            extraDetails: salesperson.extraDetails || '',
                            measurements: salesperson.measurements || '',
                            windowMeasurements: salesperson.windowMeasurements || '',
                            stickSide: salesperson.stickSide || 'Inside',
                        });

                        setPaymentData({
                            totalAmount: salesperson.totalAmount?.toString() || salesperson.paymentAmount?.toString() || '',
                            amount: salesperson.paymentAmount?.toString() || '',
                            mode: salesperson.modeOfPayment || 'Cash',
                        });
                    }
                }
            } catch (error) {
                console.error('Failed to load job:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJob();
    }, [id, isViewMode]);

    const updateField = (field: string, value: string) => {
        setFormData(prev => ({ ...prev, [field]: value }));
    };

    // Handle image selection
    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const files = e.target.files;
        if (!files) return;

        const newFiles = Array.from(files);
        setSelectedImages(prev => [...prev, ...newFiles]);

        // Create preview URLs
        newFiles.forEach(file => {
            const url = URL.createObjectURL(file);
            setImagePreviewUrls(prev => [...prev, url]);
        });
    };

    // Remove a selected image
    const removeImage = (index: number) => {
        setSelectedImages(prev => prev.filter((_, i) => i !== index));
        setImagePreviewUrls(prev => {
            const urlToRevoke = prev[index];
            if (urlToRevoke) URL.revokeObjectURL(urlToRevoke);
            return prev.filter((_, i) => i !== index);
        });
    };

    // Upload images to Supabase storage
    const uploadImagesToSupabase = async (): Promise<string[]> => {
        if (selectedImages.length === 0) return [];

        setIsUploadingImages(true);
        const uploadedUrls: string[] = [];

        try {
            for (const file of selectedImages) {
                const fileExt = file.name.split('.').pop();
                const fileName = `${job?.jobCode}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}.${fileExt}`;
                const filePath = `site-photos/${fileName}`;

                const { error: uploadError } = await supabase.storage
                    .from('job-images')
                    .upload(filePath, file);

                if (uploadError) {
                    console.error('Upload error:', uploadError);
                    continue;
                }

                // Get public URL
                const { data: urlData } = supabase.storage
                    .from('job-images')
                    .getPublicUrl(filePath);

                if (urlData?.publicUrl) {
                    uploadedUrls.push(urlData.publicUrl);
                }
            }
        } catch (error) {
            console.error('Error uploading images:', error);
        } finally {
            setIsUploadingImages(false);
        }

        return uploadedUrls;
    };


    const handleInitialSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        // Validate: Cannot complete job before Visit Date
        if (job) {
            const currentDate = new Date().toLocaleDateString('en-CA');
            // Compare string dates YYYY-MM-DD
            if (currentDate < job.dateOfVisit) {
                alert(`Cannot complete job before the Appointment Date (${job.dateOfVisit}).`);
                return;
            }
        }

        setShowPaymentModal(true);
    };

    const handleFinalSubmit = async () => {
        if (!job || !salespersonId) return;

        const amountPaid = parseFloat(paymentData.amount);
        const totalAmount = parseFloat(paymentData.totalAmount);

        if (isNaN(totalAmount) || totalAmount <= 0) {
            alert('Please enter a valid total amount');
            return;
        }
        if (isNaN(amountPaid) || amountPaid < 0) {
            alert('Please enter a valid amount received');
            return;
        }

        setIsSubmitting(true);
        try {
            // Upload images first
            const uploadedImageUrls = await uploadImagesToSupabase();

            const dataToSubmit: SalespersonData = {
                status: 'completed',
                typeOfSign: formData.typeOfSign,
                material: formData.material,
                tools: formData.tools,
                productionTime: `${formData.productionTimeValue} ${formData.productionTimeUnit}`,
                fittingTime: `${formData.fittingTimeValue} ${formData.fittingTimeUnit}`,
                extraDetails: formData.extraDetails,
                measurements: formData.measurements,
                windowMeasurements: formData.windowMeasurements,
                stickSide: formData.stickSide,
                totalAmount: totalAmount,
                paymentAmount: amountPaid,
                modeOfPayment: paymentData.mode,
                images: uploadedImageUrls,
                submittedAt: new Date().toISOString(),
            };

            const success = await salespersonService.submitJobDetails(job.jobCode, dataToSubmit);

            if (success) {
                // Also update availability
                await salespersonService.setSalespersonAvailable(salespersonId);
                alert('Job submitted successfully!');
                router.push('/salesperson');
            } else {
                alert('Failed to submit job. Please try again.');
            }
        } catch (error) {
            console.error('Submit error:', error);
            alert('An error occurred');
        } finally {
            setIsSubmitting(false);
            setShowPaymentModal(false);
        }
    };

    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loadingContainer}>
                    <div css={styles.spinner} />
                </div>
            </AppLayout>
        );
    }

    if (!job) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.errorMessage}>Job not found</div>
                </div>
            </AppLayout>
        );
    }

    return (
        <>
            <Head>
                <title>Job Details | {job.jobCode}</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <h1>{isViewMode ? 'Submitted Details' : 'Job Details'}</h1>
                    </div>

                    {/* View Mode Banner */}
                    {isViewMode && job.salespersonData && (
                        <div style={{
                            background: '#D1FAE5',
                            border: '1px solid #10B981',
                            borderRadius: '12px',
                            padding: '16px',
                            marginBottom: '20px',
                        }}>
                            <div style={{ fontWeight: 600, color: '#059669', marginBottom: '8px' }}>
                                ✓ Job Submitted
                            </div>
                            <div style={{ fontSize: '14px', color: '#065F46' }}>
                                <span>Payment: £{job.salespersonData.paymentAmount || 0} ({job.salespersonData.modeOfPayment || 'N/A'})</span>
                                {job.salespersonData.submittedAt && (
                                    <span style={{ marginLeft: '16px' }}>
                                        Submitted: {new Date(job.salespersonData.submittedAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                                    </span>
                                )}
                            </div>
                        </div>
                    )}

                    {/* Job Info Section */}
                    <div css={styles.section}>
                        <div css={styles.infoGrid}>
                            <div css={styles.infoItem}>
                                <label>Customer</label>
                                <span>{job.customerName}</span>
                            </div>
                            <div css={styles.infoItem}>
                                <label>Job Number</label>
                                <span>{job.jobCode}</span>
                            </div>
                            <div css={styles.infoItem}>
                                <label>Shop Name</label>
                                <span>{job.shopName}</span>
                            </div>
                            <div css={styles.infoItem}>
                                <label>Date of Visit</label>
                                <span>{job.dateOfVisit}</span>
                            </div>
                        </div>
                    </div>

                    {/* Details Form */}
                    <form onSubmit={handleInitialSubmit}>
                        <div css={styles.section}>
                            <div css={styles.sectionTitle}>Job Specification</div>
                            <div css={styles.formGrid}>
                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Type of Sign</label>
                                    <select
                                        css={styles.select(theme)}
                                        value={formData.typeOfSign}
                                        onChange={(e) => updateField('typeOfSign', e.target.value)}
                                        disabled={isViewMode}
                                        style={isViewMode ? { backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : {}}
                                    >
                                        <option value="design">Design</option>
                                        <option value="board">Board</option>
                                        <option value="banner">Banner</option>
                                        <option value="sticker">Sticker</option>
                                    </select>
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Material</label>
                                    <input
                                        css={styles.input(theme)}
                                        value={formData.material}
                                        onChange={(e) => updateField('material', e.target.value)}
                                        placeholder="e.g. Vinyl, Acrylic"
                                        disabled={isViewMode}
                                        style={isViewMode ? { backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : {}}
                                    />
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Tools / Nails</label>
                                    <input
                                        css={styles.input(theme)}
                                        value={formData.tools}
                                        onChange={(e) => updateField('tools', e.target.value)}
                                        placeholder="Tools required"
                                        disabled={isViewMode}
                                        style={isViewMode ? { backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : {}}
                                    />
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Production Time</label>
                                    <div style={{ display: 'flex', gap: '8px' }}>
                                        <select
                                            css={styles.select(theme)}
                                            style={isViewMode ? { flex: 1, backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : { flex: 1 }}
                                            value={formData.productionTimeValue}
                                            onChange={(e) => updateField('productionTimeValue', e.target.value)}
                                            disabled={isViewMode}
                                        >
                                            {[1, 2, 3, 4, 5, 6, 7, 10, 14, 21, 30].map(n => (
                                                <option key={n} value={n}>{n}</option>
                                            ))}
                                        </select>
                                        <select
                                            css={styles.select(theme)}
                                            style={isViewMode ? { flex: 1, backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : { flex: 1 }}
                                            value={formData.productionTimeUnit}
                                            onChange={(e) => updateField('productionTimeUnit', e.target.value)}
                                            disabled={isViewMode}
                                        >
                                            <option value="Days">Days</option>
                                            <option value="Weeks">Weeks</option>
                                        </select>
                                    </div>
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Fitting Time</label>
                                    <div style={{ display: 'flex', gap: '8px' }}>
                                        <select
                                            css={styles.select(theme)}
                                            style={isViewMode ? { flex: 1, backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : { flex: 1 }}
                                            value={formData.fittingTimeValue}
                                            onChange={(e) => updateField('fittingTimeValue', e.target.value)}
                                            disabled={isViewMode}
                                        >
                                            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12].map(n => (
                                                <option key={n} value={n}>{n}</option>
                                            ))}
                                        </select>
                                        <select
                                            css={styles.select(theme)}
                                            style={isViewMode ? { flex: 1, backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : { flex: 1 }}
                                            value={formData.fittingTimeUnit}
                                            onChange={(e) => updateField('fittingTimeUnit', e.target.value)}
                                            disabled={isViewMode}
                                        >
                                            <option value="Hours">Hours</option>
                                            <option value="Days">Days</option>
                                        </select>
                                    </div>
                                </div>

                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Extra Details</label>
                                    <textarea
                                        css={styles.textArea(theme)}
                                        value={formData.extraDetails}
                                        onChange={(e) => updateField('extraDetails', e.target.value)}
                                        placeholder="Frame, bracket, or additional requirements..."
                                        disabled={isViewMode}
                                        style={isViewMode ? { backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : {}}
                                    />
                                </div>
                            </div>
                        </div>

                        <div css={styles.section}>
                            <div css={styles.sectionTitle}>Measurements</div>
                            <div css={styles.formGrid}>
                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Sign Measurements</label>
                                    <p style={{ margin: 0, fontSize: 12, color: '#666', fontStyle: 'italic' }}>
                                        Put an X to mark drill holes and nails
                                    </p>
                                    <textarea
                                        css={styles.textArea(theme)}
                                        value={formData.measurements}
                                        onChange={(e) => updateField('measurements', e.target.value)}
                                        placeholder="Enter measurements and markings..."
                                        disabled={isViewMode}
                                        style={isViewMode ? { backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : {}}
                                    />
                                </div>

                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Window Vinyls</label>
                                    <textarea
                                        css={styles.textArea(theme)}
                                        value={formData.windowMeasurements}
                                        onChange={(e) => updateField('windowMeasurements', e.target.value)}
                                        placeholder="Window measurements..."
                                        disabled={isViewMode}
                                        style={isViewMode ? { backgroundColor: '#f3f4f6', cursor: 'not-allowed' } : {}}
                                    />
                                </div>

                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Stick Side</label>
                                    <div css={styles.radioGroup}>
                                        <label style={isViewMode ? { opacity: 0.7, cursor: 'not-allowed' } : {}}>
                                            <input
                                                type="radio"
                                                name="stickSide"
                                                value="Inside"
                                                checked={formData.stickSide === 'Inside'}
                                                onChange={(e) => updateField('stickSide', e.target.value)}
                                                disabled={isViewMode}
                                            />
                                            Inside
                                        </label>
                                        <label style={isViewMode ? { opacity: 0.7, cursor: 'not-allowed' } : {}}>
                                            <input
                                                type="radio"
                                                name="stickSide"
                                                value="Outside"
                                                checked={formData.stickSide === 'Outside'}
                                                onChange={(e) => updateField('stickSide', e.target.value)}
                                                disabled={isViewMode}
                                            />
                                            Outside
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Site Photos Section */}
                        <div css={styles.section}>
                            <div css={styles.sectionTitle}>Site Photos</div>
                            <div css={styles.formGrid}>
                                {/* View Mode: Show uploaded images */}
                                {isViewMode && job.salespersonData?.images && job.salespersonData.images.length > 0 && (
                                    <div css={[styles.formField, styles.fullWidth]}>
                                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))', gap: '12px' }}>
                                            {job.salespersonData.images.map((url, idx) => (
                                                <div
                                                    key={idx}
                                                    style={{ position: 'relative', borderRadius: '8px', overflow: 'hidden', cursor: 'pointer' }}
                                                    onClick={() => setFullscreenImage(url)}
                                                >
                                                    <img
                                                        src={url}
                                                        alt={`Site photo ${idx + 1}`}
                                                        style={{ width: '100%', height: '150px', objectFit: 'cover' }}
                                                    />
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* View Mode: No images message */}
                                {isViewMode && (!job.salespersonData?.images || job.salespersonData.images.length === 0) && (
                                    <div css={[styles.formField, styles.fullWidth]}>
                                        <p style={{ color: '#666', fontSize: '14px', margin: 0 }}>No site photos uploaded</p>
                                    </div>
                                )}

                                {/* Edit Mode: Upload interface */}
                                {!isViewMode && (
                                    <div css={[styles.formField, styles.fullWidth]}>
                                        {/* Hidden file input */}
                                        <input
                                            ref={fileInputRef}
                                            type="file"
                                            accept="image/*"
                                            multiple
                                            onChange={handleImageSelect}
                                            style={{ display: 'none' }}
                                        />

                                        {/* Upload button */}
                                        <button
                                            type="button"
                                            onClick={() => fileInputRef.current?.click()}
                                            style={{
                                                padding: '12px 20px',
                                                background: '#F3F4F6',
                                                border: '2px dashed #D1D5DB',
                                                borderRadius: '8px',
                                                cursor: 'pointer',
                                                width: '100%',
                                                fontSize: '14px',
                                                color: '#6B7280',
                                            }}
                                        >
                                            📷 Click to upload site photos
                                        </button>

                                        {/* Image previews */}
                                        {imagePreviewUrls.length > 0 && (
                                            <div style={{
                                                display: 'grid',
                                                gridTemplateColumns: 'repeat(auto-fill, minmax(120px, 1fr))',
                                                gap: '12px',
                                                marginTop: '16px'
                                            }}>
                                                {imagePreviewUrls.map((url, idx) => (
                                                    <div key={idx} style={{ position: 'relative', borderRadius: '8px', overflow: 'hidden' }}>
                                                        <img
                                                            src={url}
                                                            alt={`Preview ${idx + 1}`}
                                                            style={{ width: '100%', height: '100px', objectFit: 'cover' }}
                                                        />
                                                        <button
                                                            type="button"
                                                            onClick={() => removeImage(idx)}
                                                            style={{
                                                                position: 'absolute',
                                                                top: '4px',
                                                                right: '4px',
                                                                background: 'rgba(0,0,0,0.6)',
                                                                color: 'white',
                                                                border: 'none',
                                                                borderRadius: '50%',
                                                                width: '24px',
                                                                height: '24px',
                                                                cursor: 'pointer',
                                                                fontSize: '14px',
                                                            }}
                                                        >
                                                            ×
                                                        </button>
                                                    </div>
                                                ))}
                                            </div>
                                        )}

                                        {/* Upload progress */}
                                        {isUploadingImages && (
                                            <p style={{ color: '#5A6CEA', marginTop: '8px', fontSize: '14px' }}>
                                                Uploading images...
                                            </p>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>

                        {/* Buttons - different for view mode */}
                        <div css={styles.buttonRow}>
                            <button
                                type="button"
                                css={styles.button('secondary')}
                                onClick={() => router.back()}
                            >
                                {isViewMode ? 'Back' : 'Cancel'}
                            </button>
                            {!isViewMode && (
                                <button
                                    type="submit"
                                    css={styles.button('primary')}
                                >
                                    Continue to Payment
                                </button>
                            )}
                        </div>
                    </form>
                </div>
            </AppLayout>

            {/* Payment Modal */}
            {showPaymentModal && (
                <div css={styles.modalOverlay}>
                    <div css={styles.modalContent}>
                        <h2>Payment Details</h2>
                        <div css={styles.formField}>
                            <label css={styles.label}>Total Payment Amount</label>
                            <input
                                type="number"
                                css={styles.input(theme)}
                                value={paymentData.totalAmount}
                                onChange={(e) => setPaymentData({ ...paymentData, totalAmount: e.target.value })}
                                placeholder="Enter total amount"
                                autoFocus
                            />
                        </div>
                        <div css={styles.formField} style={{ marginTop: 16 }}>
                            <label css={styles.label}>Amount Received</label>
                            <input
                                type="number"
                                css={styles.input(theme)}
                                value={paymentData.amount}
                                onChange={(e) => setPaymentData({ ...paymentData, amount: e.target.value })}
                                placeholder="Enter amount received"
                            />
                        </div>
                        <div css={styles.formField} style={{ marginTop: 16 }}>
                            <label css={styles.label}>Mode of Payment</label>
                            <select
                                css={styles.select(theme)}
                                value={paymentData.mode}
                                onChange={(e) => setPaymentData({ ...paymentData, mode: e.target.value })}
                            >
                                <option value="Cash">Cash</option>
                                <option value="UPI">UPI</option>
                                <option value="Card">Card</option>
                                <option value="Bank Transfer">Bank Transfer</option>
                            </select>
                        </div>

                        <div css={styles.modalActions}>
                            <button
                                type="button"
                                css={styles.button('secondary')}
                                onClick={() => setShowPaymentModal(false)}
                            >
                                Cancel
                            </button>
                            <button
                                type="button"
                                css={styles.button('primary')}
                                onClick={handleFinalSubmit}
                                disabled={isSubmitting}
                            >
                                {isSubmitting ? 'Submitting...' : 'Submit Job'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

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
