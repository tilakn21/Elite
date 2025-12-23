/**
 * Design - Job List
 * List of jobs assigned to design team
 */

import { useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { designService } from '@/services';
import type { DesignJob, DesignJobStatus } from '@/types/design';
import { useAuth } from '@/state';
import * as styles from '@/styles/pages/design/jobs.styles';

export default function DesignJobList() {
    const theme = useTheme();
    const router = useRouter();
    const { state: _authState } = useAuth();

    const [jobs, setJobs] = useState<DesignJob[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [activeTab, setActiveTab] = useState<'all' | 'pending' | 'active' | 'completed'>('all');

    useEffect(() => {
        async function loadJobs() {
            try {
                const data = await designService.getDesignJobs();
                setJobs(data);
            } catch (error) {
                console.error('Failed to load jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJobs();
    }, []);

    const filteredJobs = useMemo(() => {
        return jobs.filter(job => {
            const matchesSearch =
                job.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                job.jobCode.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (job.shopName || '').toLowerCase().includes(searchQuery.toLowerCase());

            if (!matchesSearch) return false;

            if (activeTab === 'all') return true;
            if (activeTab === 'pending') return job.status === 'pending';
            if (activeTab === 'active') return ['in_progress', 'draft_uploaded', 'changes_requested'].includes(job.status);
            if (activeTab === 'completed') return ['approved', 'completed'].includes(job.status);

            return true;
        });
    }, [jobs, searchQuery, activeTab]);

    const getInitials = (name: string) => name.substring(0, 2).toUpperCase();

    const formatDate = (date: string) => new Date(date).toLocaleDateString();

    const getStatusLabel = (status: DesignJobStatus) => {
        return status.replace(/_/g, ' ');
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
                <title>Job List | Design Dashboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Header */}
                    <div css={styles.header}>
                        <h1>Design Jobs</h1>
                        <div css={styles.controls}>
                            <div css={styles.searchWrapper}>
                                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                                <input
                                    type="text"
                                    placeholder="Search jobs..."
                                    value={searchQuery}
                                    onChange={e => setSearchQuery(e.target.value)}
                                    css={styles.searchInput(theme)}
                                />
                            </div>
                        </div>
                    </div>

                    {/* Tabs */}
                    <div css={styles.tabContainer}>
                        <div
                            css={styles.tab(activeTab === 'all')}
                            onClick={() => setActiveTab('all')}
                        >
                            All Jobs
                        </div>
                        <div
                            css={styles.tab(activeTab === 'pending')}
                            onClick={() => setActiveTab('pending')}
                        >
                            Pending
                        </div>
                        <div
                            css={styles.tab(activeTab === 'active')}
                            onClick={() => setActiveTab('active')}
                        >
                            Active
                        </div>
                        <div
                            css={styles.tab(activeTab === 'completed')}
                            onClick={() => setActiveTab('completed')}
                        >
                            Completed
                        </div>
                    </div>

                    {/* Job List */}
                    {filteredJobs.length === 0 ? (
                        <div css={styles.emptyState}>
                            <h3>No jobs found</h3>
                            <p>Try adjusting your search or filters</p>
                        </div>
                    ) : (
                        <div css={styles.jobGrid}>
                            {filteredJobs.map(job => (
                                <div
                                    key={job.id}
                                    css={styles.jobCard}
                                    onClick={() => router.push(`/design/upload?jobId=${job.id}`)}
                                >
                                    <div css={styles.jobIcon}>
                                        {getInitials(job.customerName)}
                                    </div>

                                    <div css={styles.jobInfo}>
                                        <div className="title-row">
                                            <h3>{job.customerName}</h3>
                                            <span css={styles.statusBadge(job.status)}>
                                                {getStatusLabel(job.status)}
                                            </span>
                                        </div>
                                        <div className="meta">
                                            <span>#{job.jobCode}</span>
                                            <span>
                                                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                                                </svg>
                                                {job.shopName || 'No Shop Name'}
                                            </span>
                                            <span>
                                                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                                </svg>
                                                {formatDate(job.assignedDate)}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </AppLayout>
        </>
    );
}
