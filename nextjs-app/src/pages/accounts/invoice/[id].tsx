/**
 * Invoice View Page
 * Professional invoice template with print/PDF functionality
 */

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import { css } from '@emotion/react';
import { FaPrint, FaDownload, FaArrowLeft } from 'react-icons/fa';
import { accountsService } from '@/services';

// Types
interface InvoiceData {
    invoiceNumber: string;
    jobCode: string;
    customerName: string;
    shopName: string;
    phone: string;
    address: string;
    signType: string;
    totalAmount: number;
    amountPaid: number;
    payments: Array<{ amount: number; mode: string; date: string }>;
    generatedAt: string;
    status: string;
}

// Styles
const pageStyles = {
    container: css`
        min-height: 100vh;
        background: #f8fafc;
        padding: 24px;
    `,
    header: css`
        max-width: 800px;
        margin: 0 auto 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        
        @media print {
            display: none;
        }
    `,
    backBtn: css`
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 16px;
        border: none;
        border-radius: 8px;
        background: white;
        color: #64748b;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.2s;
        
        &:hover {
            background: #f1f5f9;
            color: #1e293b;
        }
    `,
    actions: css`
        display: flex;
        gap: 12px;
    `,
    actionBtn: (primary: boolean) => css`
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 12px 20px;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        background: ${primary ? '#3b82f6' : 'white'};
        color: ${primary ? 'white' : '#1e293b'};
        box-shadow: 0 2px 8px ${primary ? 'rgba(59, 130, 246, 0.3)' : 'rgba(0,0,0,0.08)'};
        
        &:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 16px ${primary ? 'rgba(59, 130, 246, 0.4)' : 'rgba(0,0,0,0.12)'};
        }
    `,
    invoiceWrapper: css`
        max-width: 800px;
        margin: 0 auto;
        background: white;
        border-radius: 16px;
        box-shadow: 0 4px 24px rgba(0,0,0,0.08);
        overflow: hidden;
        
        @media print {
            box-shadow: none;
            border-radius: 0;
        }
    `,
    invoice: css`
        padding: 48px;
        
        @media print {
            padding: 32px;
        }
    `,
    invoiceHeader: css`
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin: -48px -48px 48px -48px;
        padding: 32px 48px;
        background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        
        @media print {
            margin: -32px -32px 32px -32px;
            padding: 24px 32px;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }
    `,
    companyInfo: css`
        display: flex;
        align-items: center;
        gap: 20px;
        
        img {
            width: 100px;
            height: 100px;
            object-fit: contain;
            background: white;
            padding: 12px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        
        .company-details {
            h1 {
                font-size: 32px;
                font-weight: 700;
                color: white;
                margin-bottom: 8px;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            }
            
            p {
                font-size: 14px;
                color: #e2e8f0;
                line-height: 1.6;
            }
        }
    `,
    invoiceInfo: css`
        text-align: right;
        
        .invoice-number {
            font-size: 12px;
            color: #cbd5e1;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        
        .invoice-value {
            font-size: 28px;
            font-weight: 700;
            color: #60a5fa;
            margin-bottom: 16px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }
        
        .date-label {
            font-size: 12px;
            color: #cbd5e1;
        }
        
        .date-value {
            font-size: 14px;
            color: white;
            font-weight: 500;
        }
    `,
    billTo: css`
        margin-bottom: 48px;
        
        h3 {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #64748b;
            margin-bottom: 12px;
        }
        
        .name {
            font-size: 20px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 8px;
        }
        
        .details {
            font-size: 14px;
            color: #64748b;
            line-height: 1.6;
        }
    `,
    table: css`
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 32px;
        
        th, td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid #f1f5f9;
        }
        
        th {
            background: #f8fafc;
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        td {
            font-size: 14px;
            color: #1e293b;
        }
        
        .description {
            font-weight: 500;
        }
        
        .amount {
            text-align: right;
            font-weight: 600;
        }
    `,
    summary: css`
        display: flex;
        justify-content: flex-end;
        margin-bottom: 48px;
    `,
    summaryBox: css`
        width: 280px;
        
        .row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            
            &.total {
                border-bottom: none;
                padding-top: 16px;
                margin-top: 8px;
                border-top: 2px solid #1e293b;
                
                span:first-of-type {
                    font-weight: 600;
                    color: #1e293b;
                }
                
                span:last-of-type {
                    font-size: 20px;
                    font-weight: 700;
                    color: #10b981;
                }
            }
        }
        
        .label {
            color: #64748b;
        }
        
        .value {
            font-weight: 500;
            color: #1e293b;
        }
    `,
    paymentHistory: css`
        margin-bottom: 48px;
        
        h3 {
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 16px;
        }
    `,
    paymentRow: css`
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 16px;
        background: #f8fafc;
        border-radius: 8px;
        margin-bottom: 8px;
        font-size: 14px;
        
        .mode {
            display: inline-flex;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            background: #dbeafe;
            color: #2563eb;
            text-transform: capitalize;
        }
        
        .date {
            color: #64748b;
        }
        
        .amount {
            font-weight: 600;
            color: #10b981;
        }
    `,
    paidBadge: css`
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 12px 24px;
        background: linear-gradient(135deg, #10b981, #059669);
        color: white;
        font-size: 16px;
        font-weight: 600;
        border-radius: 8px;
        margin-bottom: 48px;
    `,
    footer: css`
        text-align: center;
        padding-top: 24px;
        border-top: 1px solid #f1f5f9;
        
        p {
            font-size: 13px;
            color: #94a3b8;
            
            &:first-of-type {
                font-weight: 500;
                color: #64748b;
                margin-bottom: 4px;
            }
        }
    `,
    loading: css`
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
        
        .spinner {
            width: 48px;
            height: 48px;
            border: 3px solid #e2e8f0;
            border-top-color: #3b82f6;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    `,
    error: css`
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
        gap: 16px;
        
        h2 {
            font-size: 24px;
            color: #1e293b;
        }
        
        p {
            color: #64748b;
        }
    `,
};

export default function InvoicePage() {
    const router = useRouter();
    const { id } = router.query;
    const invoiceRef = useRef<HTMLDivElement>(null);

    const [invoice, setInvoice] = useState<InvoiceData | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (id && typeof id === 'string') {
            loadInvoice(id);
        }
    }, [id]);

    const loadInvoice = async (jobId: string) => {
        setIsLoading(true);
        try {
            // First try to get existing invoice, if not generate new one
            let data = await accountsService.getInvoiceData(jobId);

            if (!data?.invoiceNumber) {
                // Generate new invoice
                const result = await accountsService.generateInvoice(jobId);
                if (result.success && result.invoiceData) {
                    data = { ...result.invoiceData, signType: 'Signboard' };
                } else {
                    setError(result.error || 'Failed to generate invoice');
                    return;
                }
            }

            setInvoice(data);
        } catch (err) {
            console.error('Error loading invoice:', err);
            setError('Failed to load invoice');
        } finally {
            setIsLoading(false);
        }
    };

    const handlePrint = () => {
        window.print();
    };

    const handleSavePDF = () => {
        // Use print dialog with "Save as PDF" option
        window.print();
    };

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP',
            minimumFractionDigits: 2
        }).format(amount);
    };

    const formatDate = (dateStr: string) => {
        if (!dateStr) return '-';
        return new Date(dateStr).toLocaleDateString('en-GB', {
            day: '2-digit',
            month: 'long',
            year: 'numeric'
        });
    };

    const formatPaymentDate = (dateStr: string) => {
        if (!dateStr) return '-';
        return new Date(dateStr).toLocaleDateString('en-GB', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        });
    };

    if (isLoading) {
        return (
            <div css={pageStyles.loading}>
                <div className="spinner" />
            </div>
        );
    }

    if (error || !invoice) {
        return (
            <div css={pageStyles.error}>
                <h2>Invoice Not Found</h2>
                <p>{error || 'Unable to load invoice data'}</p>
                <button css={pageStyles.backBtn} onClick={() => router.push('/accounts/jobs')}>
                    <FaArrowLeft /> Go Back
                </button>
            </div>
        );
    }

    return (
        <>
            <Head>
                <title>Invoice {invoice.invoiceNumber} | Elite Signboard</title>
                <style>{`
                    @media print {
                        body { 
                            -webkit-print-color-adjust: exact !important;
                            print-color-adjust: exact !important;
                        }
                    }
                `}</style>
            </Head>

            <div css={pageStyles.container}>
                {/* Action Bar */}
                <div css={pageStyles.header}>
                    <button css={pageStyles.backBtn} onClick={() => router.push('/accounts/jobs')}>
                        <FaArrowLeft /> Back to Jobs
                    </button>
                    <div css={pageStyles.actions}>
                        <button css={pageStyles.actionBtn(false)} onClick={handleSavePDF}>
                            <FaDownload /> Save as PDF
                        </button>
                        <button css={pageStyles.actionBtn(true)} onClick={handlePrint}>
                            <FaPrint /> Print Invoice
                        </button>
                    </div>
                </div>

                {/* Invoice Document */}
                <div css={pageStyles.invoiceWrapper} ref={invoiceRef}>
                    <div css={pageStyles.invoice}>
                        {/* Header */}
                        <div css={pageStyles.invoiceHeader}>
                            <div css={pageStyles.companyInfo}>
                                <img src="/images/elite_logo.png" alt="Elite Signboard Logo" />
                                <div className="company-details">
                                    <h1>Elite Signboard</h1>
                                    <p>
                                        Premium Sign Manufacturing<br />
                                        United Kingdom<br />
                                        info@elitesignboard.co.uk
                                    </p>
                                </div>
                            </div>
                            <div css={pageStyles.invoiceInfo}>
                                <div className="invoice-number">Invoice Number</div>
                                <div className="invoice-value">{invoice.invoiceNumber}</div>
                                <div className="date-label">Date Issued</div>
                                <div className="date-value">{formatDate(invoice.generatedAt)}</div>
                            </div>
                        </div>

                        {/* Bill To */}
                        <div css={pageStyles.billTo}>
                            <h3>Bill To</h3>
                            <div className="name">{invoice.customerName}</div>
                            <div className="details">
                                {invoice.shopName && <>{invoice.shopName}<br /></>}
                                {invoice.address && <>{invoice.address}<br /></>}
                                {invoice.phone && <>Tel: {invoice.phone}</>}
                            </div>
                        </div>

                        {/* Paid Badge */}
                        <div css={pageStyles.paidBadge}>
                            ✓ PAID IN FULL
                        </div>

                        {/* Line Items */}
                        <table css={pageStyles.table}>
                            <thead>
                                <tr>
                                    <th>Description</th>
                                    <th>Job Code</th>
                                    <th style={{ textAlign: 'right' }}>Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td className="description">
                                        {invoice.signType || 'Signboard'} - Custom Manufacturing & Installation
                                    </td>
                                    <td style={{ fontFamily: 'monospace', color: '#3b82f6' }}>
                                        {invoice.jobCode}
                                    </td>
                                    <td className="amount">{formatCurrency(invoice.totalAmount)}</td>
                                </tr>
                            </tbody>
                        </table>

                        {/* Summary */}
                        <div css={pageStyles.summary}>
                            <div css={pageStyles.summaryBox}>
                                <div className="row">
                                    <span className="label">Subtotal</span>
                                    <span className="value">{formatCurrency(invoice.totalAmount)}</span>
                                </div>
                                <div className="row">
                                    <span className="label">VAT (0%)</span>
                                    <span className="value">{formatCurrency(0)}</span>
                                </div>
                                <div className="row total">
                                    <span>Total Paid</span>
                                    <span>{formatCurrency(invoice.amountPaid)}</span>
                                </div>
                            </div>
                        </div>

                        {/* Payment History */}
                        {invoice.payments && invoice.payments.length > 0 && (
                            <div css={pageStyles.paymentHistory}>
                                <h3>Payment History</h3>
                                {invoice.payments.map((payment, idx) => (
                                    <div key={idx} css={pageStyles.paymentRow}>
                                        <span className="mode">{payment.mode?.replace('_', ' ')}</span>
                                        <span className="date">{formatPaymentDate(payment.date)}</span>
                                        <span className="amount">+{formatCurrency(payment.amount)}</span>
                                    </div>
                                ))}
                            </div>
                        )}

                        {/* Footer */}
                        <div css={pageStyles.footer}>
                            <p>Thank you for your business!</p>
                            <p>Elite Signboard Ltd. • All rights reserved</p>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
}
