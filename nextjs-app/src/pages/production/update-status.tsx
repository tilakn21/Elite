/**
 * Production - Update Status
 * Move jobs through production workflow
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { productionService } from '@/services';
import type { ProductionJob, ProductionJobStatus } from '@/types/production';
import * as styles from '@/styles/pages/production/update-status.styles';

export default function UpdateStatusPage() {
    const theme = useTheme();


    const [jobs, setJobs] = useState<ProductionJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        async function loadJobs() {
            try {
                const data = await productionService.getProductionJobs();
                setJobs(data);
            } catch (error) {
                console.error('Failed to load jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJobs();
    }, []);

    const handleStatusUpdate = async (jobId: string, newStatus: ProductionJobStatus) => {
        try {
            await productionService.updateStatus(jobId, newStatus);
            setJobs(prev => prev.map(job =>
                job.id === jobId ? { ...job, status: newStatus } : job
            ));
        } catch (error) {
            console.error('Update failed:', error);
        }
    };

    const statusOptions: { value: ProductionJobStatus; label: string; color: string }[] = [
        { value: 'pending_production', label: 'Queued', color: '#9CA3AF' },
        { value: 'fabrication', label: 'Fabrication', color: '#3B82F6' },
        { value: 'assembly', label: 'Assembly', color: '#8B5CF6' },
        { value: 'quality_check', label: 'Quality Check', color: '#F59E0B' },
        { value: 'ready_for_install', label: 'Ready', color: '#10B981' },
    ];

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
                <title>Update Status | Production</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <h1>Update Job Status</h1>
                    </div>

                    {jobs.length === 0 ? (
                        <p style={{ color: '#6B7280', textAlign: 'center', marginTop: '40px' }}>
                            No active jobs to update.
                        </p>
                    ) : (
                        jobs.map(job => (
                            <div key={job.id} css={styles.jobCard}>
                                <div className="header">
                                    <h3>{job.customerName} (#{job.jobCode})</h3>
                                    <span>Deadline: {new Date(job.deadline).toLocaleDateString()}</span>
                                </div>
                                <div className="status-row">
                                    {statusOptions.map(option => (
                                        <button
                                            key={option.value}
                                            css={styles.statusButton(job.status === option.value, option.color)}
                                            onClick={() => handleStatusUpdate(job.id, option.value)}
                                        >
                                            {option.label}
                                        </button>
                                    ))}
                                </div>
                            </div>
                        ))
                    )}
                </div>
            </AppLayout>
        </>
    );
}
