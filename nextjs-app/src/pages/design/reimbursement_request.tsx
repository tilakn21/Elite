/**
 * Designer Reimbursement Request Screen
 * Form to submit expense reimbursement requests
 */

import { useState, useEffect, useCallback } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
// Use existing salesperson service for profile fetching, or generalize later
import { createReimbursement } from '@/services/reimbursements.service';
import { useAuth } from '@/state';
// Resuing salesperson styles which are generic form styles
import * as styles from '@/styles/pages/salesperson/reimbursement.styles';

// Icons
function ReceiptIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M4 2v20l4-2 4 2 4-2 4 2V2l-4 2-4-2-4 2-4-2z" />
            <line x1="16" y1="8" x2="8" y2="8" />
            <line x1="16" y1="12" x2="8" y2="12" />
            <line x1="12" y1="16" x2="8" y2="16" />
        </svg>
    );
}

function UploadIcon() {
    return (
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="17 8 12 3 7 8" />
            <line x1="12" y1="3" x2="12" y2="15" />
        </svg>
    );
}

export default function ReimbursementPage() {
    const theme = useTheme();
    const { state: authState } = useAuth(); // Assume designer auth state works similarly

    const [employeeName, setEmployeeName] = useState('');
    const [amount, setAmount] = useState('');
    const [purpose, setPurpose] = useState('');
    const [expenseDate, setExpenseDate] = useState('');
    const [remarks, setRemarks] = useState('');
    const [_receiptFile, setReceiptFile] = useState<File | null>(null);
    const [receiptPreview, setReceiptPreview] = useState<string | null>(null);

    const [errors, setErrors] = useState<Record<string, boolean>>({});
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [submitStatus, setSubmitStatus] = useState<{ success: boolean; message: string } | null>(null);

    const employeeId = authState.user?.employeeId;

    // Fetch employee name on mount
    useEffect(() => {
        if (authState.user?.name) {
            setEmployeeName(authState.user.name);
        }
    }, [authState.user]);

    // Handle file upload
    const handleFileChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            setReceiptFile(file);
            setReceiptPreview(URL.createObjectURL(file));
            setErrors(prev => ({ ...prev, receipt: false }));
        }
    }, []);

    // Remove receipt
    const removeReceipt = useCallback(() => {
        setReceiptFile(null);
        setReceiptPreview(null);
    }, []);

    // Validate form
    const validateForm = (): boolean => {
        const newErrors: Record<string, boolean> = {};

        if (!amount.trim()) newErrors.amount = true;
        if (!purpose.trim()) newErrors.purpose = true;
        if (!expenseDate) newErrors.date = true;
        if (!_receiptFile) newErrors.receipt = true;

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    // Submit form
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!validateForm() || !employeeId) return;

        setIsSubmitting(true);
        setSubmitStatus(null);

        try {
            const result = await createReimbursement({
                emp_id: employeeId,
                emp_name: employeeName,
                amount: parseFloat(amount),
                purpose: purpose,
                remarks: remarks || undefined,
                reimbursement_date: expenseDate,
            });

            if (result) {
                setSubmitStatus({ success: true, message: 'Reimbursement request submitted successfully!' });
                // Clear form
                setAmount('');
                setPurpose('');
                setExpenseDate('');
                setRemarks('');
                setReceiptFile(null);
                setReceiptPreview(null);
            } else {
                setSubmitStatus({ success: false, message: 'Failed to submit request. Please try again.' });
            }
        } catch (error) {
            console.error('Submit error:', error);
            setSubmitStatus({ success: false, message: 'An error occurred. Please try again.' });
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <>
            <Head>
                <title>Reimbursement | Designer</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.formCard}>
                        <div css={styles.formHeader}>
                            <ReceiptIcon />
                            <h1>New Reimbursement Request</h1>
                        </div>

                        <form onSubmit={handleSubmit}>
                            <div css={styles.formGrid}>
                                {/* Employee Name */}
                                <div css={styles.formField}>
                                    <label css={styles.label}>Employee Name</label>
                                    <input
                                        type="text"
                                        value={employeeName}
                                        readOnly
                                        placeholder="Loading..."
                                        css={styles.input(false, theme)}
                                    />
                                </div>

                                {/* Amount */}
                                <div css={styles.formField}>
                                    <label css={styles.label}>Amount (£)</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        value={amount}
                                        onChange={(e) => {
                                            setAmount(e.target.value);
                                            setErrors(prev => ({ ...prev, amount: false }));
                                        }}
                                        placeholder="Enter amount (e.g., 125.50)"
                                        css={styles.input(errors.amount ?? false, theme)}
                                    />
                                    {errors.amount && <span css={styles.errorText}>Amount is required</span>}
                                </div>

                                {/* Purpose */}
                                <div css={styles.formField}>
                                    <label css={styles.label}>Purpose</label>
                                    <input
                                        type="text"
                                        value={purpose}
                                        onChange={(e) => {
                                            setPurpose(e.target.value);
                                            setErrors(prev => ({ ...prev, purpose: false }));
                                        }}
                                        placeholder="Enter purpose of expense"
                                        css={styles.input(errors.purpose ?? false, theme)}
                                    />
                                    {errors.purpose && <span css={styles.errorText}>Purpose is required</span>}
                                </div>

                                {/* Date */}
                                <div css={styles.formField}>
                                    <label css={styles.label}>Date of Expense</label>
                                    <input
                                        type="date"
                                        value={expenseDate}
                                        onChange={(e) => {
                                            setExpenseDate(e.target.value);
                                            setErrors(prev => ({ ...prev, date: false }));
                                        }}
                                        max={new Date().toISOString().split('T')[0]}
                                        css={styles.input(errors.date ?? false, theme)}
                                    />
                                    {errors.date && <span css={styles.errorText}>Date is required</span>}
                                </div>

                                {/* Remarks */}
                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Remarks (Optional)</label>
                                    <textarea
                                        value={remarks}
                                        onChange={(e) => setRemarks(e.target.value)}
                                        placeholder="Enter any additional remarks"
                                        css={styles.textarea(false, theme)}
                                    />
                                </div>

                                {/* Receipt Upload */}
                                <div css={[styles.formField, styles.fullWidth]}>
                                    <label css={styles.label}>Upload Receipt</label>
                                    {receiptPreview ? (
                                        <div css={styles.uploadPreview}>
                                            <img src={receiptPreview} alt="Receipt preview" />
                                            <button type="button" onClick={removeReceipt}>×</button>
                                        </div>
                                    ) : (
                                        <label css={styles.uploadArea(errors.receipt ?? false)}>
                                            <input
                                                type="file"
                                                accept="image/*"
                                                onChange={handleFileChange}
                                                style={{ display: 'none' }}
                                            />
                                            <UploadIcon />
                                            <p>Click to upload receipt</p>
                                        </label>
                                    )}
                                    {errors.receipt && <span css={styles.errorText}>Receipt is required</span>}
                                </div>
                            </div>

                            <button type="submit" css={styles.submitButton} disabled={isSubmitting}>
                                {isSubmitting ? 'Submitting...' : 'Submit Request'}
                            </button>

                            {submitStatus && (
                                <div css={styles.statusMessage(submitStatus.success)}>
                                    {submitStatus.success ? '✓' : '✗'} {submitStatus.message}
                                </div>
                            )}
                        </form>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
