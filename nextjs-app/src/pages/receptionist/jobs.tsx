/**
 * Receptionist - View All Jobs
 * Shows list of all job requests with filtering and salesperson assignment
 */

import { useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { receptionistService } from '@/services/receptionist.service';
import type { JobRequest, Salesperson } from '@/types/receptionist';
import * as styles from '@/styles/pages/receptionist/jobs.styles';

function SearchIcon() {
    return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8" />
            <path d="m21 21-4.35-4.35" />
        </svg>
    );
}

function CloseIcon() {
    return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M18 6L6 18M6 6l12 12" />
        </svg>
    );
}

export default function JobsListPage() {
    const theme = useTheme();
    const router = useRouter();

    const [jobs, setJobs] = useState<JobRequest[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<string>('all');

    // Assignment modal state
    const [assignModalOpen, setAssignModalOpen] = useState(false);
    const [selectedJob, setSelectedJob] = useState<JobRequest | null>(null);
    const [salespersons, setSalespersons] = useState<Salesperson[]>([]);
    const [loadingSalespersons, setLoadingSalespersons] = useState(false);
    const [selectedSalesperson, setSelectedSalesperson] = useState<string | null>(null);
    const [isAssigning, setIsAssigning] = useState(false);
    const [toastMessage, setToastMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

    // Read status from URL query params on mount
    useEffect(() => {
        const { status } = router.query;
        if (status === 'pending' || status === 'assigned') {
            setStatusFilter(status);
        }
    }, [router.query]);

    // Load jobs
    useEffect(() => {
        async function loadJobs() {
            try {
                const data = await receptionistService.getJobRequests();
                setJobs(data);
            } catch (error) {
                console.error('Failed to load jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJobs();
    }, []);

    // Load salespersons when modal opens
    useEffect(() => {
        if (assignModalOpen && selectedJob) {
            async function loadSalespersons() {
                setLoadingSalespersons(true);
                try {
                    // Use non-null assertion since we checked selectedJob above
                    const job = selectedJob!;
                    const fallbackDate = new Date().toISOString().split('T')[0];
                    const date = (job.dateOfVisit || job.dateOfAppointment || fallbackDate) as string;
                    const data = await receptionistService.getSalespersonsForDate(date);
                    setSalespersons(data);
                } catch (error) {
                    console.error('Failed to load salespersons:', error);
                } finally {
                    setLoadingSalespersons(false);
                }
            }
            loadSalespersons();
        }
    }, [assignModalOpen, selectedJob]);

    const filteredJobs = useMemo(() => {
        return jobs.filter(job => {
            const matchesSearch = searchQuery === '' ||
                job.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                job.jobCode.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (job.shopName?.toLowerCase() || '').includes(searchQuery.toLowerCase());

            // Filter by status: 'pending' means no salesperson (status = pending/received)
            // 'assigned' means salesperson assigned (status = approved/salesperson_assigned)
            let matchesStatus = true;
            if (statusFilter === 'pending') {
                matchesStatus = job.status === 'pending';
            } else if (statusFilter === 'assigned') {
                matchesStatus = job.status === 'approved';
            }

            return matchesSearch && matchesStatus;
        });
    }, [jobs, searchQuery, statusFilter]);

    const getInitials = (name: string) => {
        return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    };

    const formatDate = (dateString: string) => {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
    };

    const formatStatus = (status: string) => {
        switch (status) {
            case 'approved': return 'Assigned';
            case 'pending': return 'Pending';
            default: return status;
        }
    };

    // Open assignment modal
    const openAssignModal = (job: JobRequest) => {
        setSelectedJob(job);
        setSelectedSalesperson(null);
        setAssignModalOpen(true);
    };

    // Close assignment modal
    const closeAssignModal = () => {
        setAssignModalOpen(false);
        setSelectedJob(null);
        setSelectedSalesperson(null);
        setSalespersons([]);
    };

    // Handle salesperson assignment
    const handleAssign = async () => {
        if (!selectedJob || !selectedSalesperson) return;

        setIsAssigning(true);
        try {
            const job = selectedJob;
            const fallbackDate = new Date().toISOString().split('T')[0];
            const date = (job.dateOfVisit || job.dateOfAppointment || fallbackDate) as string;
            const result = await receptionistService.assignSalespersonToJob(
                job.id,
                selectedSalesperson,
                date
            );

            if (result.success) {
                setToastMessage({ text: 'Salesperson assigned successfully!', type: 'success' });
                closeAssignModal();
                // Reload jobs to reflect changes
                const updatedJobs = await receptionistService.getJobRequests();
                setJobs(updatedJobs);
            } else {
                setToastMessage({ text: result.error || 'Failed to assign salesperson', type: 'error' });
            }
        } catch (error) {
            setToastMessage({ text: 'An error occurred', type: 'error' });
        } finally {
            setIsAssigning(false);
            setTimeout(() => setToastMessage(null), 3000);
        }
    };

    return (
        <>
            <Head>
                <title>All Jobs | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Header */}
                    <div css={styles.header}>
                        <h1>All Job Requests</h1>
                        <div css={styles.controls}>
                            <div css={styles.searchWrapper}>
                                <SearchIcon />
                                <input
                                    type="text"
                                    placeholder="Search by name, job code..."
                                    value={searchQuery}
                                    onChange={e => setSearchQuery(e.target.value)}
                                    css={styles.searchInput(theme)}
                                />
                            </div>
                            <select
                                value={statusFilter}
                                onChange={e => setStatusFilter(e.target.value)}
                                css={styles.filterSelect}
                            >
                                <option value="all">All Status</option>
                                <option value="pending">Pending</option>
                                <option value="assigned">Assigned</option>
                            </select>
                        </div>
                    </div>

                    {/* Content */}
                    {isLoading ? (
                        <div css={styles.loadingContainer}>
                            <div css={styles.spinnerAnimation} />
                        </div>
                    ) : filteredJobs.length === 0 ? (
                        <div css={styles.tableCard}>
                            <div css={styles.emptyState}>
                                <h3>No jobs found</h3>
                                <p>{searchQuery || statusFilter !== 'all'
                                    ? 'Try adjusting your filters'
                                    : 'No job requests have been created yet'}</p>
                            </div>
                        </div>
                    ) : (
                        <>
                            {/* Desktop Table */}
                            <div css={[styles.tableCard, styles.desktopTable]}>
                                <table css={styles.table}>
                                    <thead>
                                        <tr>
                                            <th>Customer</th>
                                            <th>Job Code</th>
                                            <th>Phone</th>
                                            <th>Date</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {filteredJobs.map(job => (
                                            <tr key={job.id}>
                                                <td>
                                                    <div css={styles.customerCell}>
                                                        <div className="avatar">
                                                            {getInitials(job.customerName)}
                                                        </div>
                                                        <div className="info">
                                                            <div className="name">{job.customerName}</div>
                                                            <div className="shop">{job.shopName || '-'}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>{job.jobCode}</td>
                                                <td>{job.phone || '-'}</td>
                                                <td>{formatDate(job.dateAdded)}</td>
                                                <td>
                                                    <span css={styles.statusBadge(job.status)}>
                                                        {formatStatus(job.status)}
                                                    </span>
                                                </td>
                                                <td>
                                                    {job.status === 'pending' ? (
                                                        <button
                                                            onClick={() => openAssignModal(job)}
                                                            css={styles.assignButton}
                                                        >
                                                            Assign
                                                        </button>
                                                    ) : (
                                                        <span css={styles.assignedText}>-</span>
                                                    )}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>

                            {/* Mobile Cards */}
                            <div css={styles.mobileCard}>
                                {filteredJobs.map(job => (
                                    <div key={job.id} css={styles.mobileJobItem}>
                                        <div className="header">
                                            <div>
                                                <div className="customer">{job.customerName}</div>
                                                <div className="shop">{job.shopName || '-'}</div>
                                            </div>
                                            <span css={styles.statusBadge(job.status)}>
                                                {formatStatus(job.status)}
                                            </span>
                                        </div>
                                        <div className="meta">
                                            <span>#{job.jobCode}</span>
                                            <span>{job.phone || '-'}</span>
                                            <span>{formatDate(job.dateAdded)}</span>
                                        </div>
                                        {job.status === 'pending' && (
                                            <button
                                                onClick={() => openAssignModal(job)}
                                                css={styles.assignButtonMobile}
                                            >
                                                Assign Salesperson
                                            </button>
                                        )}
                                    </div>
                                ))}
                            </div>
                        </>
                    )}
                </div>
            </AppLayout>

            {/* Assignment Modal */}
            {assignModalOpen && selectedJob && (
                <div css={styles.modalOverlay} onClick={closeAssignModal}>
                    <div css={styles.modalContent} onClick={e => e.stopPropagation()}>
                        <div css={styles.modalHeader}>
                            <h2>Assign Salesperson</h2>
                            <button css={styles.closeButton} onClick={closeAssignModal}>
                                <CloseIcon />
                            </button>
                        </div>

                        <div css={styles.modalBody}>
                            <p css={styles.jobInfo}>
                                <strong>{selectedJob.customerName}</strong> - {selectedJob.shopName || 'No shop name'}
                            </p>
                            <p css={styles.dateInfo}>
                                Visit Date: {formatDate(selectedJob.dateOfVisit || selectedJob.dateOfAppointment || '')}
                            </p>

                            <h3 css={styles.salespersonTitle}>Select Salesperson</h3>

                            {loadingSalespersons ? (
                                <div css={styles.modalLoading}>
                                    <div css={styles.spinnerAnimation} />
                                </div>
                            ) : (
                                <div css={styles.salespersonList}>
                                    {salespersons.map(sp => (
                                        <div
                                            key={sp.id}
                                            css={styles.salespersonOption(
                                                selectedSalesperson === sp.id,
                                                !sp.isAvailable
                                            )}
                                            onClick={() => sp.isAvailable && setSelectedSalesperson(sp.id)}
                                        >
                                            <div className="name">{sp.name}</div>
                                            <div className="meta">
                                                <span>{sp.numberOfJobs} jobs on this date</span>
                                                <span css={styles.availabilityBadge(sp.isAvailable)}>
                                                    {sp.isAvailable ? 'Available' : 'Busy (Max 3)'}
                                                </span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        <div css={styles.modalFooter}>
                            <button css={styles.cancelButton} onClick={closeAssignModal}>
                                Cancel
                            </button>
                            <button
                                css={styles.confirmButton}
                                onClick={handleAssign}
                                disabled={!selectedSalesperson || isAssigning}
                            >
                                {isAssigning ? 'Assigning...' : 'Assign'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Toast */}
            {toastMessage && (
                <div css={styles.toast(toastMessage.type)}>{toastMessage.text}</div>
            )}
        </>
    );
}

