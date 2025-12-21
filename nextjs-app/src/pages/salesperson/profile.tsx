/**
 * Salesperson Profile Screen
 * Shows employee profile info and allows password change
 */

import { useState, useEffect, useCallback } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { useAuth } from '@/state';
import { salespersonService } from '@/services/salesperson.service';
import type { SalespersonProfile } from '@/types/salesperson';
import * as styles from '@/styles/pages/salesperson/profile.styles';

// Icons
function LockIcon() {
    return (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
        </svg>
    );
}

function LogoutIcon() {
    return (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
        </svg>
    );
}

interface PasswordModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (currentPassword: string, newPassword: string) => Promise<void>;
    isSubmitting: boolean;
}

function PasswordModal({ isOpen, onClose, onSubmit, isSubmitting }: PasswordModalProps) {
    const theme = useTheme();
    const [currentPassword, setCurrentPassword] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');

    const handleSubmit = async () => {
        setError('');

        if (!currentPassword || !newPassword || !confirmPassword) {
            setError('Please fill in all fields');
            return;
        }

        if (newPassword !== confirmPassword) {
            setError('New passwords do not match');
            return;
        }

        if (newPassword.length < 6) {
            setError('Password must be at least 6 characters');
            return;
        }

        await onSubmit(currentPassword, newPassword);
    };

    if (!isOpen) return null;

    return (
        <div css={styles.modalOverlay} onClick={onClose}>
            <div css={styles.modalContent} onClick={e => e.stopPropagation()}>
                <h2 css={styles.modalTitle}>Change Password</h2>

                <div css={styles.formField}>
                    <label css={styles.formLabel}>Current Password</label>
                    <input
                        type="password"
                        value={currentPassword}
                        onChange={e => setCurrentPassword(e.target.value)}
                        css={styles.formInput(theme)}
                        placeholder="Enter current password"
                    />
                </div>

                <div css={styles.formField}>
                    <label css={styles.formLabel}>New Password</label>
                    <input
                        type="password"
                        value={newPassword}
                        onChange={e => setNewPassword(e.target.value)}
                        css={styles.formInput(theme)}
                        placeholder="Enter new password"
                    />
                </div>

                <div css={styles.formField}>
                    <label css={styles.formLabel}>Confirm New Password</label>
                    <input
                        type="password"
                        value={confirmPassword}
                        onChange={e => setConfirmPassword(e.target.value)}
                        css={styles.formInput(theme)}
                        placeholder="Confirm new password"
                    />
                </div>

                {error && (
                    <p style={{ color: '#EF4444', fontSize: '14px', marginBottom: '16px' }}>
                        {error}
                    </p>
                )}

                <div css={styles.modalActions}>
                    <button css={styles.modalButton('cancel')} onClick={onClose} disabled={isSubmitting}>
                        Cancel
                    </button>
                    <button css={styles.modalButton('submit')} onClick={handleSubmit} disabled={isSubmitting}>
                        {isSubmitting ? 'Changing...' : 'Change Password'}
                    </button>
                </div>
            </div>
        </div>
    );
}

export default function ProfilePage() {
    const theme = useTheme();
    const router = useRouter();
    const { state: authState, logout } = useAuth();

    const [profile, setProfile] = useState<SalespersonProfile | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [showPasswordModal, setShowPasswordModal] = useState(false);
    const [isChangingPassword, setIsChangingPassword] = useState(false);
    const [toastMessage, setToastMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

    const salespersonId = authState.user?.employeeId;

    // Fetch profile
    useEffect(() => {
        async function fetchProfile() {
            if (!salespersonId) {
                setError('No user ID found');
                setIsLoading(false);
                return;
            }

            setIsLoading(true);
            setError(null);

            try {
                const profileData = await salespersonService.getProfile(salespersonId);
                if (profileData) {
                    setProfile(profileData);
                } else {
                    setError('Profile not found');
                }
            } catch (err) {
                console.error('Failed to fetch profile:', err);
                setError('Failed to load profile');
            } finally {
                setIsLoading(false);
            }
        }

        fetchProfile();
    }, [salespersonId]);

    // Show toast
    const showToast = (text: string, type: 'success' | 'error') => {
        setToastMessage({ text, type });
        setTimeout(() => setToastMessage(null), 3000);
    };

    // Handle password change
    const handlePasswordChange = useCallback(async (currentPassword: string, newPassword: string) => {
        if (!salespersonId) return;

        setIsChangingPassword(true);

        try {
            const result = await salespersonService.changePassword(salespersonId, currentPassword, newPassword);

            if (result.success) {
                setShowPasswordModal(false);
                showToast('Password changed successfully', 'success');
            } else {
                showToast(result.error || 'Failed to change password', 'error');
            }
        } catch (err) {
            showToast('An error occurred', 'error');
        } finally {
            setIsChangingPassword(false);
        }
    }, [salespersonId]);

    // Handle logout
    const handleLogout = useCallback(async () => {
        await logout();
        router.push('/login');
    }, [logout, router]);

    // Format date
    const formatDate = (dateString: string) => {
        if (!dateString) return '-';
        return dateString.split('T')[0];
    };

    // Format role
    const formatRole = (role: string) => {
        return role.replace(/_/g, ' ').replace(/^\w/, c => c.toUpperCase());
    };

    return (
        <>
            <Head>
                <title>Profile | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {isLoading && (
                        <div css={styles.loadingContainer}>
                            <div css={styles.spinnerAnimation} />
                        </div>
                    )}

                    {error && !isLoading && (
                        <div css={styles.errorMessage}>{error}</div>
                    )}

                    {!isLoading && !error && profile && (
                        <>
                            {/* Profile Header */}
                            <div css={styles.profileHeader}>
                                <div css={styles.avatarPlaceholder}>
                                    {profile.full_name.charAt(0)}
                                </div>
                                <div css={styles.userName}>{profile.full_name}</div>
                                <div css={styles.userRole}>{formatRole(profile.role)}</div>
                            </div>

                            {/* Profile Cards */}
                            <div css={styles.profileCard}>
                                <div css={styles.cardLabel}>Full Name</div>
                                <div css={styles.cardValue(true)}>{profile.full_name}</div>
                            </div>

                            <div css={styles.profileCard}>
                                <div css={styles.cardLabel}>Phone no.</div>
                                <div css={styles.cardValue(false)}>{profile.phone || '-'}</div>
                            </div>

                            <div css={styles.profileCard}>
                                <div css={styles.cardLabel}>Role</div>
                                <div css={styles.cardValue(true)}>{formatRole(profile.role)}</div>
                            </div>

                            <div css={styles.profileCard}>
                                <div css={styles.cardLabel}>Branch ID</div>
                                <div css={styles.cardValue(false)}>{profile.branch_id || '-'}</div>
                            </div>

                            <div css={styles.profileCard}>
                                <div css={styles.cardLabel}>Created At</div>
                                <div css={styles.cardValue(false)}>{formatDate(profile.created_at)}</div>
                            </div>

                            {/* Actions */}
                            <div css={styles.actionsContainer}>
                                <button
                                    css={styles.actionButton('primary')}
                                    onClick={() => setShowPasswordModal(true)}
                                >
                                    <LockIcon />
                                    Change Password
                                </button>

                                <button css={styles.actionButton('danger')} onClick={handleLogout}>
                                    <LogoutIcon />
                                    Log Out
                                </button>
                            </div>
                        </>
                    )}
                </div>
            </AppLayout>

            {/* Password Modal */}
            <PasswordModal
                isOpen={showPasswordModal}
                onClose={() => setShowPasswordModal(false)}
                onSubmit={handlePasswordChange}
                isSubmitting={isChangingPassword}
            />

            {/* Toast */}
            {toastMessage && (
                <div css={styles.toast(toastMessage.type)}>
                    {toastMessage.text}
                </div>
            )}
        </>
    );
}
