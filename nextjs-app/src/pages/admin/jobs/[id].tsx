import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { Button, Badge } from '@/components/ui';
import { JobStages } from '@/components/jobs';
import { getJobById } from '@/services';
import { getCurrentDepartment, getStatusLabel, getStatusColor, getWorkflowProgress } from '@/utils/status-utils';
import type { Job } from '@/types';
import type { NextPageWithLayout } from '../../_app';
import { FaArrowLeft, FaEdit, FaDownload } from 'react-icons/fa';
import * as styles from '@/styles/pages/admin/jobs/styles';

/**
 * Admin Job Details Page
 * Displays full details of a job including all stages.
 */

const JobDetailsPage: NextPageWithLayout = () => {
    const router = useRouter();
    const theme = useTheme();
    const { id } = router.query;
    const [job, setJob] = useState<Job | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (id) {
            loadJob(id as string);
        }
    }, [id]);

    const loadJob = async (jobId: string) => {
        try {
            setLoading(true);
            const data = await getJobById(jobId);
            if (data) {
                setJob(data);
            } else {
                setError('Job not found');
            }
        } catch (err: any) {
            console.error('Failed to load job:', err);
            setError(err.message || 'Failed to load job');
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div style={{ padding: '40px', textAlign: 'center' }}>
                Loading job details...
            </div>
        );
    }

    if (error || !job) {
        return (
            <div style={{ padding: '40px', textAlign: 'center' }}>
                <h2 style={{ color: '#ef4444' }}>Error</h2>
                <p>{error || 'Job not found'}</p>
                <Button variant="secondary" onClick={() => router.back()}>Go Back</Button>
            </div>
        );
    }

    return (
        <>
            <Head>
                <title>Job {job.job_code} | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                {/* Header */}
                <div css={styles.header}>
                    <div css={styles.headerLeft}>
                        <button css={styles.backButton(theme)} onClick={() => router.back()}>
                            <FaArrowLeft />
                        </button>
                        <div css={styles.titleSection}>
                            <h1 css={styles.jobTitle}>Job #{job.job_code}</h1>
                            <div css={styles.subtitle}>
                                {job.receptionist?.client_name || 'Unknown Client'} • {new Date(job.created_at).toLocaleDateString()}
                            </div>
                        </div>
                    </div>
                    <div css={styles.headerActions}>
                        <Button variant="outline" size="sm">
                            <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <FaDownload /> Export
                            </span>
                        </Button>
                        <Button variant="primary" size="sm">
                            <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <FaEdit /> Edit Job
                            </span>
                        </Button>
                    </div>
                </div>

                <div css={styles.contentLayout}>
                    {/* Main Stage Timeline */}
                    <div css={styles.mainContent}>
                        <JobStages job={job} />
                    </div>

                    {/* Sidebar Overview */}
                    <div css={styles.sidebar}>
                        <div css={styles.overviewCard}>
                            <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '16px' }}>Overview</h3>

                            {/* Current Department Highlight */}
                            <div style={{
                                padding: '12px',
                                background: `${getStatusColor(job.status)}15`,
                                border: `1px solid ${getStatusColor(job.status)}`,
                                borderRadius: '8px',
                                marginBottom: '16px'
                            }}>
                                <div style={{ fontSize: '11px', color: '#6b7280', marginBottom: '4px' }}>Currently at</div>
                                <div style={{
                                    fontSize: '16px',
                                    fontWeight: '600',
                                    color: getStatusColor(job.status)
                                }}>
                                    {getCurrentDepartment(job.status)}
                                </div>
                            </div>

                            <div style={{ marginBottom: '16px' }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '14px' }}>
                                    <span style={{ color: '#6b7280' }}>Progress</span>
                                    <span style={{ fontWeight: '600', color: getStatusColor(job.status) }}>
                                        {getWorkflowProgress(job.status)}%
                                    </span>
                                </div>
                                <div style={{ height: '8px', background: '#e5e7eb', borderRadius: '4px', overflow: 'hidden' }}>
                                    <div style={{
                                        width: `${getWorkflowProgress(job.status)}%`,
                                        background: getStatusColor(job.status),
                                        height: '100%',
                                        transition: 'width 0.3s ease'
                                    }} />
                                </div>
                            </div>

                            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
                                    <span style={{ color: '#6b7280' }}>Status</span>
                                    <Badge variant={job.status.includes('completed') || job.status === 'out_for_delivery' ? 'success' : 'info'} size="sm">
                                        {getStatusLabel(job.status)}
                                    </Badge>
                                </div>
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
                                    <span style={{ color: '#6b7280' }}>Branch</span>
                                    <span>{job.branch_id}</span>
                                </div>
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
                                    <span style={{ color: '#6b7280' }}>Amount</span>
                                    <span style={{ fontWeight: '600' }}>£{job.amount}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
};

JobDetailsPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default JobDetailsPage;
