/**
 * Production - Assign Labour
 * Assign workers to jobs
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import { } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { productionService } from '@/services';
import type { ProductionJob, Worker } from '@/types/production';
import * as styles from '@/styles/pages/production/assign-labour.styles';

export default function AssignLabourPage() {
    const theme = useTheme();


    const [jobs, setJobs] = useState<ProductionJob[]>([]);
    const [workers, setWorkers] = useState<Worker[]>([]);
    const [selectedJob, setSelectedJob] = useState<string | null>(null);
    const [selectedWorker, setSelectedWorker] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isAssigning, setIsAssigning] = useState(false);

    useEffect(() => {
        async function loadData() {
            try {
                const [jobsData, workersData] = await Promise.all([
                    productionService.getProductionJobs(),
                    productionService.getWorkers()
                ]);
                setJobs(jobsData);
                setWorkers(workersData);
            } catch (error) {
                console.error('Failed to load data:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadData();
    }, []);

    const handleAssign = async () => {
        if (!selectedJob || !selectedWorker) return;

        setIsAssigning(true);
        try {
            await productionService.assignWorker(selectedJob, selectedWorker);
            // Refresh data or optimistic update
            setWorkers(prev => prev.map(w =>
                w.id === selectedWorker ? { ...w, status: 'busy', currentJob: selectedJob } : w
            ));
            alert('Worker assigned successfully!');
            setSelectedWorker(null);
            setSelectedJob(null);
        } catch (error) {
            console.error('Assignments failed:', error);
        } finally {
            setIsAssigning(false);
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
                <title>Assign Labour | Production</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    <div css={styles.header}>
                        <h1>Assign Labour</h1>
                        <p>Select a job and an available worker to assign tasks.</p>
                    </div>

                    <div css={styles.grid}>
                        {/* Job Selection */}
                        <div css={styles.card}>
                            <h2>1. Select Job</h2>
                            {jobs.length === 0 ? (
                                <p style={{ color: '#6B7280' }}>No active jobs in production.</p>
                            ) : (
                                jobs.map(job => (
                                    <div
                                        key={job.id}
                                        css={styles.jobItem(selectedJob === job.id)}
                                        onClick={() => setSelectedJob(job.id)}
                                    >
                                        <h3>{job.customerName} (#{job.jobCode})</h3>
                                        <p>{job.description}</p>
                                    </div>
                                ))
                            )}
                        </div>

                        {/* Worker Selection */}
                        <div css={styles.card}>
                            <h2>2. Select Worker</h2>
                            {workers.length === 0 ? (
                                <p style={{ color: '#6B7280' }}>No workers found.</p>
                            ) : (
                                workers.map(worker => (
                                    <div
                                        key={worker.id}
                                        css={styles.workerItem(selectedWorker === worker.id, worker.status === 'available')}
                                        onClick={() => worker.status === 'available' && setSelectedWorker(worker.id)}
                                    >
                                        <div>
                                            <div className="name">{worker.name}</div>
                                            <div className="role">{worker.role}</div>
                                        </div>
                                        <span className="status">{worker.status}</span>
                                    </div>
                                ))
                            )}

                            <button
                                css={styles.assignButton}
                                disabled={!selectedJob || !selectedWorker || isAssigning}
                                onClick={handleAssign}
                            >
                                {isAssigning ? 'Assigning...' : 'Confirm Assignment'}
                            </button>
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}
