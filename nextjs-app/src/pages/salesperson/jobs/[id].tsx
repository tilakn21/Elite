/**
 * Salesperson Job Details Screen
 * Form to submit job details and collect payment
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { salespersonService } from '@/services/salesperson.service';
import { useAuth } from '@/state';
import { SalespersonData } from '@/types/salesperson';
import * as styles from '@/styles/pages/salesperson/jobs/styles';

interface JobDetails {
    customerName: string;
    jobCode: string;
    id: string;
    dateOfVisit: string;
    shopName: string;
}

export default function JobDetailsPage() {
    const theme = useTheme();
    const router = useRouter();
    const { id } = router.query;
    const { state: authState } = useAuth();
    const salespersonId = authState.user?.employeeId;

    const [isLoading, setIsLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [job, setJob] = useState<JobDetails | null>(null);
    const [showPaymentModal, setShowPaymentModal] = useState(false);

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
        amount: '',
        mode: 'Cash',
    });

    useEffect(() => {
        async function loadJob() {
            if (!id || typeof id !== 'string') return;

            try {
                // Fetch job details by job_code (which is passed as id in URL)
                const data = await salespersonService.getJobDetails(id);
                if (data) {
                    const receptionist = data.receptionist as Record<string, any>;
                    setJob({
                        customerName: receptionist?.customerName || '',
                        jobCode: (data.job_code as string) || (data.id as string),
                        id: data.id as string,
                        dateOfVisit: receptionist?.dateOfVisit || '',
                        shopName: receptionist?.shopName || '',
                    });
                }
            } catch (error) {
                console.error('Failed to load job:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJob();
    }, [id]);

    const updateField = (field: string, value: string) => {
        setFormData(prev => ({ ...prev, [field]: value }));
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
        if (isNaN(amountPaid) || amountPaid <= 0) {
            alert('Please enter a valid amount');
            return;
        }

        setIsSubmitting(true);
        try {
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
                paymentAmount: amountPaid,
                modeOfPayment: paymentData.mode,
                images: [], // TODO: Image upload implementation
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
                        <h1>Job Details</h1>
                    </div>

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
                                    />
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Tools / Nails</label>
                                    <input
                                        css={styles.input(theme)}
                                        value={formData.tools}
                                        onChange={(e) => updateField('tools', e.target.value)}
                                        placeholder="Tools required"
                                    />
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Production Time</label>
                                    <div style={{ display: 'flex', gap: '8px' }}>
                                        <select
                                            css={styles.select(theme)}
                                            style={{ flex: 1 }}
                                            value={formData.productionTimeValue}
                                            onChange={(e) => updateField('productionTimeValue', e.target.value)}
                                        >
                                            {[1, 2, 3, 4, 5, 6, 7, 10, 14, 21, 30].map(n => (
                                                <option key={n} value={n}>{n}</option>
                                            ))}
                                        </select>
                                        <select
                                            css={styles.select(theme)}
                                            style={{ flex: 1 }}
                                            value={formData.productionTimeUnit}
                                            onChange={(e) => updateField('productionTimeUnit', e.target.value)}
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
                                            style={{ flex: 1 }}
                                            value={formData.fittingTimeValue}
                                            onChange={(e) => updateField('fittingTimeValue', e.target.value)}
                                        >
                                            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12].map(n => (
                                                <option key={n} value={n}>{n}</option>
                                            ))}
                                        </select>
                                        <select
                                            css={styles.select(theme)}
                                            style={{ flex: 1 }}
                                            value={formData.fittingTimeUnit}
                                            onChange={(e) => updateField('fittingTimeUnit', e.target.value)}
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
                                    />
                                </div>

                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Window Vinyls</label>
                                    <textarea
                                        css={styles.textArea(theme)}
                                        value={formData.windowMeasurements}
                                        onChange={(e) => updateField('windowMeasurements', e.target.value)}
                                        placeholder="Window measurements..."
                                    />
                                </div>

                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Stick Side</label>
                                    <div css={styles.radioGroup}>
                                        <label>
                                            <input
                                                type="radio"
                                                name="stickSide"
                                                value="Inside"
                                                checked={formData.stickSide === 'Inside'}
                                                onChange={(e) => updateField('stickSide', e.target.value)}
                                            />
                                            Inside
                                        </label>
                                        <label>
                                            <input
                                                type="radio"
                                                name="stickSide"
                                                value="Outside"
                                                checked={formData.stickSide === 'Outside'}
                                                onChange={(e) => updateField('stickSide', e.target.value)}
                                            />
                                            Outside
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* TODO: Image Upload Section */}

                        <div css={styles.buttonRow}>
                            <button
                                type="button"
                                css={styles.button('secondary')}
                                onClick={() => router.back()}
                            >
                                Cancel
                            </button>
                            <button
                                type="submit"
                                css={styles.button('primary')}
                            >
                                Continue to Payment
                            </button>
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
                            <label css={styles.label}>Amount Paid</label>
                            <input
                                type="number"
                                css={styles.input(theme)}
                                value={paymentData.amount}
                                onChange={(e) => setPaymentData({ ...paymentData, amount: e.target.value })}
                                placeholder="Enter amount"
                                autoFocus
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
        </>
    );
}
