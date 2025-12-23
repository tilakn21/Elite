/**
 * Salesperson Dashboard - Home Screen
 * Shows list of assigned jobs with status (Pending/Submitted)
 */

import { useState, useEffect, useCallback, useMemo } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { useAuth } from '@/state';
import { salespersonService } from '@/services/salesperson.service';
import type { SiteVisitItem } from '@/types/salesperson';
import * as styles from '@/styles/pages/salesperson/index.styles';

// Search Icon Component
function SearchIcon() {
    return (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8" />
            <path d="m21 21-4.35-4.35" />
        </svg>
    );
}

// Arrow Icon Component
function ArrowRightIcon() {
    return (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <polyline points="9 18 15 12 9 6" />
        </svg>
    );
}

export default function SalespersonDashboard() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState } = useAuth();

    const [jobs, setJobs] = useState<SiteVisitItem[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [searchQuery, setSearchQuery] = useState('');

    const salespersonId = authState.user?.employeeId;

    // Fetch assigned jobs
    useEffect(() => {
        async function fetchJobs() {
            if (!salespersonId) {
                setError('No salesperson ID found');
                setIsLoading(false);
                return;
            }

            setIsLoading(true);
            setError(null);

            try {
                const assignedJobs = await salespersonService.getAssignedJobs(salespersonId);
                setJobs(assignedJobs);
            } catch (err) {
                console.error('Failed to fetch jobs:', err);
                setError('Failed to load jobs. Please try again.');
            } finally {
                setIsLoading(false);
            }
        }

        fetchJobs();
    }, [salespersonId]);

    // Filter jobs based on search
    const filteredJobs = useMemo(() => {
        if (!searchQuery.trim()) return jobs;

        const query = searchQuery.toLowerCase();
        return jobs.filter(job =>
            job.customerName.toLowerCase().includes(query) ||
            job.jobCode.toLowerCase().includes(query)
        );
    }, [jobs, searchQuery]);

    // Handle job click
    const handleJobClick = useCallback((job: SiteVisitItem) => {
        if (job.status === 'pending') {
            // Navigate to editable form
            router.push(`/salesperson/jobs/${job.jobCode}`);
        } else if (job.status === 'submitted' || job.status === 'completed') {
            // Navigate to view-only form for submitted/completed jobs
            router.push(`/salesperson/jobs/${job.jobCode}?view=true`);
        }
    }, [router]);

    // Get initials for avatar
    const getInitials = (name: string) => {
        return name
            .split(' ')
            .map(n => n[0])
            .join('')
            .toUpperCase()
            .slice(0, 2);
    };

    return (
        <>
            <Head>
                <title>My Jobs | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard" showSearch={false}>
                <div css={styles.pageContainer(theme)}>
                    {/* Search */}
                    <div css={styles.searchContainer}>
                        <div css={styles.searchWrapper}>
                            <SearchIcon />
                            <input
                                type="text"
                                placeholder="Search by customer name or job code"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                css={styles.searchInput(theme)}
                            />
                        </div>
                    </div>

                    {/* Loading State */}
                    {isLoading && (
                        <div css={styles.loadingContainer}>
                            <div css={styles.spinnerAnimation} />
                        </div>
                    )}

                    {/* Error State */}
                    {error && !isLoading && (
                        <div css={styles.errorMessage}>{error}</div>
                    )}

                    {/* Empty State */}
                    {!isLoading && !error && filteredJobs.length === 0 && (
                        <div css={styles.emptyState(theme)}>
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                            <h3>No Jobs Found</h3>
                            <p>
                                {searchQuery
                                    ? 'No jobs match your search criteria.'
                                    : 'You don\'t have any assigned jobs yet.'}
                            </p>
                        </div>
                    )}

                    {/* Jobs List */}
                    {!isLoading && !error && filteredJobs.length > 0 && (
                        <div css={styles.jobsList}>
                            {filteredJobs.map((job) => {
                                const isClickable = job.status === 'pending' || job.status === 'submitted' || job.status === 'completed';
                                const initials = getInitials(job.customerName || 'NA');

                                return (
                                    <div
                                        key={job.jobCode}
                                        css={styles.jobCard(isClickable)}
                                        onClick={() => handleJobClick(job)}
                                    >
                                        <div css={styles.avatarCircle(theme)}>
                                            {initials}
                                        </div>

                                        <div css={styles.jobInfo}>
                                            <div css={styles.customerName}>
                                                {job.customerName || 'Unknown Customer'}
                                            </div>
                                            <div css={styles.jobMeta}>
                                                <span>
                                                    Job Number: <span css={styles.jobCodeText}>{job.jobCode}</span>
                                                </span>
                                                <span>{job.dateOfVisit || 'No date'}</span>
                                            </div>
                                        </div>

                                        <div css={styles.statusBadge(job.status)}>
                                            {job.status === 'pending' ? 'Pending' : 'Submitted'}
                                        </div>

                                        <div css={styles.arrowIcon}>
                                            <ArrowRightIcon />
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    )}
                </div>
            </AppLayout>
        </>
    );
}
