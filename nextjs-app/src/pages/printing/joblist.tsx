/**
 * Printing - Job List & Quality Check
 * manage print queue
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
// import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { printingService } from '@/services';
import type { PrintingJob, PrintingJobStatus } from '@/types/printing';
import * as styles from '@/styles/pages/printing/joblist.styles';

export default function PrintingJobList() {
    const theme = useTheme();
    // const router = useRouter(); // Keeping router for now if we add navigation later

    const [jobs, setJobs] = useState<PrintingJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        async function loadJobs() {
            try {
                const data = await printingService.getPrintingJobs('all');
                setJobs(data);
            } catch (error) {
                console.error('Failed to load jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJobs();
    }, []);

    const handleStatusUpdate = async (jobId: string, newStatus: PrintingJobStatus) => {
        try {
            await printingService.updateStatus(jobId, newStatus);
            setJobs(prev => prev.map(job =>
                job.id === jobId ? { ...job, status: newStatus } : job
            ));
        } catch (error) {
            alert('Failed to update status');
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

    return (
        <>
            <Head>
                <title>Print Queue | Printing</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <h1>Print Queue</h1>
                    </div>

                    <div css={styles.grid}>
                        {jobs.map(job => (
                            <div key={job.id} css={styles.jobCard(job.status)}>
                                <div className="header">
                                    <h3>{job.jobCode}</h3>
                                    <span>{job.status.replace(/_/g, ' ').toUpperCase()}</span>
                                </div>
                                <div className="details">
                                    <p><strong>Customer:</strong> {job.customerName}</p>
                                    <p><strong>Material:</strong> {job.material}</p>
                                    <p><strong>Size:</strong> {job.dimensions}</p>
                                    <p><strong>Qty:</strong> {job.quantity}</p>
                                    <p>{job.description}</p>
                                </div>
                                <div className="actions">
                                    {job.status === 'ready_for_print' && (
                                        <button
                                            css={styles.button('primary')}
                                            onClick={() => handleStatusUpdate(job.id, 'printing')}
                                        >
                                            Start Printing
                                        </button>
                                    )}
                                    {job.status === 'printing' && (
                                        <button
                                            css={styles.button('success')}
                                            onClick={() => handleStatusUpdate(job.id, 'completed')}
                                        >
                                            Mark Printed
                                        </button>
                                    )}
                                    {job.status === 'completed' && (
                                        <button
                                            css={styles.button('success')}
                                            onClick={() => handleStatusUpdate(job.id, 'quality_check_passed')}
                                        >
                                            QC Pass
                                        </button>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
