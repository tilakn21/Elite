/**
 * Receptionist - New Job Request Form
 * Create new job requests and assign salesperson
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { useAuth } from '@/state';
import { receptionistService } from '@/services/receptionist.service';
import type { Salesperson, NewJobRequestData } from '@/types/receptionist';
import * as styles from '@/styles/pages/receptionist/new-job.styles';

export default function NewJobPage() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [salespersons, setSalespersons] = useState<Salesperson[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [toastMessage, setToastMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

    // Form state
    const [formData, setFormData] = useState<NewJobRequestData>({
        customerName: '',
        phone: '',
        shopName: '',
        streetAddress: '',
        streetNumber: '',
        town: '',
        postcode: '',
        dateOfAppointment: new Date().toISOString().split('T')[0],
        dateOfVisit: '',
        timeOfVisit: '',
        assignedSalesperson: undefined,
    });

    const [errors, setErrors] = useState<Record<string, boolean>>({});

    const receptionistId = authState.user?.employeeId;

    // Load salespersons
    useEffect(() => {
        async function loadSalespersons() {
            try {
                const data = await receptionistService.getSalespersons();
                setSalespersons(data);
            } catch (error) {
                console.error('Failed to load salespersons:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadSalespersons();
    }, []);

    // Update field
    const updateField = (field: keyof NewJobRequestData, value: string) => {
        setFormData(prev => ({ ...prev, [field]: value }));
        if (errors[field]) {
            setErrors(prev => ({ ...prev, [field]: false }));
        }
    };

    // Validate
    const validate = (): boolean => {
        const newErrors: Record<string, boolean> = {};

        if (!formData.customerName.trim()) newErrors.customerName = true;
        if (!formData.phone.trim()) newErrors.phone = true;
        if (!formData.shopName.trim()) newErrors.shopName = true;
        if (!formData.streetAddress.trim()) newErrors.streetAddress = true;
        if (!formData.town.trim()) newErrors.town = true;
        if (!formData.postcode.trim()) newErrors.postcode = true;
        if (!formData.dateOfVisit) newErrors.dateOfVisit = true;
        if (!formData.timeOfVisit) newErrors.timeOfVisit = true;
        if (!formData.assignedSalesperson) newErrors.assignedSalesperson = true;

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    // Submit
    const handleSubmit = async () => {
        if (!validate() || !receptionistId) return;

        setIsSubmitting(true);

        try {
            const result = await receptionistService.createJobRequest(formData, receptionistId);

            if (result.success) {
                setToastMessage({ text: 'Job request created successfully!', type: 'success' });
                setTimeout(() => router.push('/receptionist/jobs'), 1500);
            } else {
                setToastMessage({ text: result.error || 'Failed to create job', type: 'error' });
            }
        } catch (error) {
            setToastMessage({ text: 'An error occurred', type: 'error' });
        } finally {
            setIsSubmitting(false);
            setTimeout(() => setToastMessage(null), 3000);
        }
    };

    return (
        <>
            <Head>
                <title>New Job Request | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.formCard}>
                        <div css={styles.formHeader}>
                            <h1>New Job Request</h1>
                        </div>

                        {/* Customer Details */}
                        <div css={styles.formSection}>
                            <h3>Customer Details</h3>
                            <div css={styles.formGrid}>
                                <div css={styles.formField}>
                                    <label css={styles.label}>Customer Name *</label>
                                    <input
                                        type="text"
                                        value={formData.customerName}
                                        onChange={e => updateField('customerName', e.target.value)}
                                        placeholder="Enter customer name"
                                        css={styles.input(errors.customerName ?? false, theme)}
                                    />
                                    {errors.customerName && <span css={styles.errorText}>Required</span>}
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Phone Number *</label>
                                    <input
                                        type="tel"
                                        value={formData.phone}
                                        onChange={e => updateField('phone', e.target.value)}
                                        placeholder="Enter phone number"
                                        css={styles.input(errors.phone ?? false, theme)}
                                    />
                                    {errors.phone && <span css={styles.errorText}>Required</span>}
                                </div>

                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Shop Name *</label>
                                    <input
                                        type="text"
                                        value={formData.shopName}
                                        onChange={e => updateField('shopName', e.target.value)}
                                        placeholder="Enter shop/business name"
                                        css={styles.input(errors.shopName ?? false, theme)}
                                    />
                                    {errors.shopName && <span css={styles.errorText}>Required</span>}
                                </div>
                            </div>
                        </div>

                        {/* Address */}
                        <div css={styles.formSection}>
                            <h3>Address</h3>
                            <div css={styles.formGrid}>
                                <div css={styles.formField}>
                                    <label css={styles.label}>Street Number</label>
                                    <input
                                        type="text"
                                        value={formData.streetNumber}
                                        onChange={e => updateField('streetNumber', e.target.value)}
                                        placeholder="e.g. 123"
                                        css={styles.input(false, theme)}
                                    />
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Street Address *</label>
                                    <input
                                        type="text"
                                        value={formData.streetAddress}
                                        onChange={e => updateField('streetAddress', e.target.value)}
                                        placeholder="Enter street name"
                                        css={styles.input(errors.streetAddress ?? false, theme)}
                                    />
                                    {errors.streetAddress && <span css={styles.errorText}>Required</span>}
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Town *</label>
                                    <input
                                        type="text"
                                        value={formData.town}
                                        onChange={e => updateField('town', e.target.value)}
                                        placeholder="Enter town/city"
                                        css={styles.input(errors.town ?? false, theme)}
                                    />
                                    {errors.town && <span css={styles.errorText}>Required</span>}
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Postcode *</label>
                                    <input
                                        type="text"
                                        value={formData.postcode}
                                        onChange={e => updateField('postcode', e.target.value)}
                                        placeholder="e.g. SW1A 1AA"
                                        css={styles.input(errors.postcode ?? false, theme)}
                                    />
                                    {errors.postcode && <span css={styles.errorText}>Required</span>}
                                </div>
                            </div>
                        </div>

                        {/* Schedule */}
                        <div css={styles.formSection}>
                            <h3>Schedule</h3>
                            <div css={styles.formGrid}>
                                <div css={styles.formField}>
                                    <label css={styles.label}>Date of Appointment</label>
                                    <input
                                        type="date"
                                        value={formData.dateOfAppointment}
                                        readOnly
                                        css={[styles.input(false, theme), { backgroundColor: '#f3f4f6', cursor: 'not-allowed' }]}
                                    />
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Date of Visit *</label>
                                    <input
                                        type="date"
                                        value={formData.dateOfVisit}
                                        onChange={e => updateField('dateOfVisit', e.target.value)}
                                        css={styles.input(errors.dateOfVisit ?? false, theme)}
                                    />
                                    {errors.dateOfVisit && <span css={styles.errorText}>Required</span>}
                                </div>

                                <div css={styles.formField}>
                                    <label css={styles.label}>Time of Visit *</label>
                                    <input
                                        type="time"
                                        value={formData.timeOfVisit}
                                        onChange={e => updateField('timeOfVisit', e.target.value)}
                                        css={styles.input(errors.timeOfVisit ?? false, theme)}
                                    />
                                    {errors.timeOfVisit && <span css={styles.errorText}>Required</span>}
                                </div>
                            </div>
                        </div>

                        {/* Assign Salesperson */}
                        <div css={styles.formSection}>
                            <h3>Assign Salesperson *</h3>
                            {errors.assignedSalesperson && (
                                <p css={styles.errorText} style={{ marginBottom: '12px' }}>Please select a salesperson</p>
                            )}

                            {isLoading ? (
                                <p style={{ color: '#666' }}>Loading salespersons...</p>
                            ) : (
                                <div css={styles.salespersonGrid}>
                                    {salespersons.map(sp => (
                                        <div
                                            key={sp.id}
                                            css={styles.salespersonOption(
                                                formData.assignedSalesperson === sp.id,
                                                !sp.isAvailable
                                            )}
                                            onClick={() => {
                                                if (sp.isAvailable) {
                                                    updateField('assignedSalesperson', sp.id);
                                                }
                                            }}
                                        >
                                            <div className="name">{sp.name}</div>
                                            <div className="meta">
                                                <span>{sp.numberOfJobs} jobs</span>
                                                <span css={styles.statusBadge(sp.isAvailable)}>
                                                    {sp.isAvailable ? 'Available' : 'Busy'}
                                                </span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Buttons */}
                        <div css={styles.buttonRow}>
                            <button
                                type="button"
                                css={styles.button('secondary')}
                                onClick={() => router.back()}
                            >
                                Cancel
                            </button>
                            <button
                                type="button"
                                css={styles.button('primary')}
                                onClick={handleSubmit}
                                disabled={isSubmitting}
                            >
                                {isSubmitting ? 'Creating...' : 'Create Job Request'}
                            </button>
                        </div>
                    </div>
                </div>
            </AppLayout>

            {/* Toast */}
            {toastMessage && (
                <div css={styles.toast(toastMessage.type)}>{toastMessage.text}</div>
            )}
        </>
    );
}
