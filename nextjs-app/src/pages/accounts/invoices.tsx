/**
 * Accounts - Invoices
 * Manage client invoices
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
// import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { accountsService } from '@/services';
import type { Invoice, InvoiceStatus } from '@/types/accounts';
import * as styles from '@/styles/pages/accounts/invoices.styles';

export default function InvoicesList() {
    const theme = useTheme();
    // const router = useRouter();

    const [invoices, setInvoices] = useState<Invoice[]>([]);
    const [filter, setFilter] = useState<InvoiceStatus | 'all'>('all');
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        async function loadInvoices() {
            setIsLoading(true);
            try {
                const data = await accountsService.getInvoices(filter);
                setInvoices(data);
            } catch (error) {
                console.error('Failed to load invoices:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadInvoices();
    }, [filter]);

    if (isLoading && invoices.length === 0) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loadingContainer}>
                    <div css={styles.spinnerAnimation} />
                </div>
            </AppLayout>
        );
    }

    return (
        <>
            <Head>
                <title>Invoices | Accounts</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <h1>Invoices</h1>
                    </div>

                    <div css={styles.tabs}>
                        {(['all', 'pending', 'paid', 'overdue'] as const).map(tabKey => (
                            <button
                                key={tabKey}
                                css={styles.tab(filter === tabKey)}
                                onClick={() => setFilter(tabKey)}
                            >
                                {tabKey.charAt(0).toUpperCase() + tabKey.slice(1)}
                            </button>
                        ))}
                    </div>

                    <div style={{ overflowX: 'auto' }}>
                        <table css={styles.table}>
                            <thead>
                                <tr>
                                    <th>Invoice #</th>
                                    <th>Customer</th>
                                    <th>Job Code</th>
                                    <th>Amount</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                {invoices.length > 0 ? (
                                    invoices.map(inv => (
                                        <tr key={inv.id}>
                                            <td style={{ fontWeight: 500 }}>{inv.invoiceNumber}</td>
                                            <td>{inv.customerName}</td>
                                            <td style={{ fontFamily: 'monospace', color: '#6B7280' }}>{inv.jobCode}</td>
                                            <td style={{ fontWeight: 600 }}>£{inv.amount.toLocaleString()}</td>
                                            <td>{new Date(inv.dueDate).toLocaleDateString()}</td>
                                            <td>
                                                <span css={styles.statusBadge(inv.status)}>
                                                    {inv.status}
                                                </span>
                                            </td>
                                        </tr>
                                    ))
                                ) : (
                                    <tr>
                                        <td colSpan={6} style={{ textAlign: 'center', color: '#6B7280', padding: '40px' }}>
                                            No invoices found.
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
