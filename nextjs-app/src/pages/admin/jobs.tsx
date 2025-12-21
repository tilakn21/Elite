import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard } from '@/components/dashboard';
import { Table, Button, Select } from '@/components/ui';
import { getJobSummaries } from '@/services';
import type { JobSummary } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/jobs.styles';

/**
 * Jobs Listing Page
 * View and filter all jobs
 */

const JobsPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const router = useRouter();

    // Data State
    const [jobs, setJobs] = useState<JobSummary[]>([]);
    const [loading, setLoading] = useState(true);
    const [totalJobs, setTotalJobs] = useState(0);

    // Filters State
    const [statusFilter, setStatusFilter] = useState('');
    const [page, setPage] = useState(1);
    const limit = 10;

    useEffect(() => {
        loadData();
    }, [page, statusFilter]);

    const loadData = async () => {
        try {
            setLoading(true);
            const { jobs: fetchedJobs, total } = await getJobSummaries({
                page,
                limit,
                status: statusFilter || undefined
            });
            setJobs(fetchedJobs);
            setTotalJobs(total);
        } catch (error) {
            console.error('Failed to load jobs:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleJobClick = (job: JobSummary) => {
        router.push(`/admin/jobs/${job.id}`);
    };

    const columns = [
        { key: 'job_code', header: 'Job #', width: '100px' },
        { key: 'title', header: 'Title' },
        { key: 'client', header: 'Client' },
        { key: 'date', header: 'Created', width: '120px' },
        { key: 'status', header: 'Status', width: '140px' },
    ];

    const totalPages = Math.ceil(totalJobs / limit);

    return (
        <>
            <Head>
                <title>All Jobs | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                <div css={styles.header}>
                    <h1 css={styles.title(theme)}>All Jobs</h1>

                    <div css={styles.filters}>
                        <div style={{ width: '200px' }}>
                            <Select
                                value={statusFilter}
                                onChange={(e) => {
                                    setStatusFilter(e.target.value);
                                    setPage(1); // Reset to first page on filter change
                                }}
                                options={[
                                    { value: '', label: 'All Statuses' },
                                    { value: 'pending', label: 'Pending' },
                                    { value: 'in_progress', label: 'In Progress' },
                                    { value: 'completed', label: 'Completed' },
                                    { value: 'cancelled', label: 'Cancelled' },
                                ]}
                                size="sm"
                            />
                        </div>
                        <Button variant="primary" onClick={() => router.push('/reception/new-job')}>
                            New Job
                        </Button>
                    </div>
                </div>

                <SectionCard title="Job List" iconColor="#0ea5e9">
                    <Table
                        columns={columns}
                        data={jobs}
                        loading={loading}
                        emptyMessage="No jobs found matching your criteria."
                        onRowClick={handleJobClick}
                    />

                    {totalPages > 1 && (
                        <div css={styles.pagination}>
                            <Button
                                variant="outline"
                                size="sm"
                                disabled={page <= 1 || loading}
                                onClick={() => setPage(p => p - 1)}
                            >
                                Previous
                            </Button>
                            <span style={{ fontSize: '14px', color: '#6b7280' }}>
                                Page {page} of {totalPages}
                            </span>
                            <Button
                                variant="outline"
                                size="sm"
                                disabled={page >= totalPages || loading}
                                onClick={() => setPage(p => p + 1)}
                            >
                                Next
                            </Button>
                        </div>
                    )}
                </SectionCard>
            </div>
        </>
    );
};

JobsPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default JobsPage;
