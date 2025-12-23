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

    // Get current local date in YYYY-MM-DD format
    const getLocalDateString = () => {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    // Form state
    const [formData, setFormData] = useState<NewJobRequestData>({
        customerName: '',
        phone: '',
        shopName: '',
        streetAddress: '',
        streetNumber: '',
        town: '',
        postcode: '',
        dateOfAppointment: getLocalDateString(),
        dateOfVisit: '',
        timeOfVisit: '',
        assignedSalesperson: undefined,
    });

    const [errors, setErrors] = useState<Record<string, boolean>>({});

    const receptionistId = authState.user?.employeeId;

    // Load salespersons based on selected date
    useEffect(() => {
        async function loadSalespersons() {
            try {
                setIsLoading(true);
                // Use date-based availability if a date is selected
                const date = formData.dateOfVisit || formData.dateOfAppointment;
                if (date) {
                    const data = await receptionistService.getSalespersonsForDate(date);
                    setSalespersons(data);
                } else {
                    const data = await receptionistService.getSalespersons();
                    setSalespersons(data);
                }
            } catch (error) {
                console.error('Failed to load salespersons:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadSalespersons();
    }, [formData.dateOfVisit, formData.dateOfAppointment]); // Re-fetch when date changes

    // Update field and clear selected salesperson if date changes
    const updateField = (field: keyof NewJobRequestData, value: string) => {
        setFormData(prev => {
            const updated = { ...prev, [field]: value };
            // Clear salesperson selection if date changes (availability may change)
            if (field === 'dateOfVisit') {
                updated.assignedSalesperson = undefined;
            }
            return updated;
        });
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
                                    <select
                                        value={formData.timeOfVisit}
                                        onChange={e => updateField('timeOfVisit', e.target.value)}
                                        css={styles.input(errors.timeOfVisit ?? false, theme)}
                                    >
                                        <option value="">Select time</option>
                                        <option value="07:00">7:00 AM</option>
                                        <option value="07:30">7:30 AM</option>
                                        <option value="08:00">8:00 AM</option>
                                        <option value="08:30">8:30 AM</option>
                                        <option value="09:00">9:00 AM</option>
                                        <option value="09:30">9:30 AM</option>
                                        <option value="10:00">10:00 AM</option>
                                        <option value="10:30">10:30 AM</option>
                                        <option value="11:00">11:00 AM</option>
                                        <option value="11:30">11:30 AM</option>
                                        <option value="12:00">12:00 PM</option>
                                        <option value="12:30">12:30 PM</option>
                                        <option value="13:00">1:00 PM</option>
                                        <option value="13:30">1:30 PM</option>
                                        <option value="14:00">2:00 PM</option>
                                        <option value="14:30">2:30 PM</option>
                                        <option value="15:00">3:00 PM</option>
                                        <option value="15:30">3:30 PM</option>
                                        <option value="16:00">4:00 PM</option>
                                        <option value="16:30">4:30 PM</option>
                                        <option value="17:00">5:00 PM</option>
                                        <option value="17:30">5:30 PM</option>
                                        <option value="18:00">6:00 PM</option>
                                        <option value="18:30">6:30 PM</option>
                                        <option value="19:00">7:00 PM</option>
                                        <option value="19:30">7:30 PM</option>
                                        <option value="20:00">8:00 PM</option>
                                        <option value="20:30">8:30 PM</option>
                                        <option value="21:00">9:00 PM</option>
                                    </select>
                                    {errors.timeOfVisit && <span css={styles.errorText}>Required</span>}
                                </div>
                            </div>
                        </div>

                        {/* Assign Salesperson - only show after date of visit is selected */}
                        {formData.dateOfVisit ? (
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
                                                    <span>{sp.numberOfJobs} jobs on this date</span>
                                                    <span css={styles.statusBadge(sp.isAvailable)}>
                                                        {sp.isAvailable ? 'Available' : 'Busy'}
                                                    </span>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>
                        ) : (
                            <div css={styles.formSection}>
                                <h3>Assign Salesperson *</h3>
                                <p style={{ color: '#666', fontSize: '14px' }}>
                                    Please select a date of visit first to see available salespersons.
                                </p>
                            </div>
                        )}

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
