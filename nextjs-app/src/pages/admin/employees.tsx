import { type ReactElement, useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { Button, Modal, Input, Select, Badge } from '@/components/ui';
import {
    getEmployees,
    createEmployeeWithPassword,
    updateEmployee,
    deleteEmployee,
    getBranches,
    getEmployeeRoles,
    resetEmployeePassword,
} from '@/services';
import type { Employee, EmployeeInsert, Branch } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/employees.styles';
import { FiSearch, FiPhone, FiMail, FiMapPin, FiEdit2, FiTrash2, FiKey } from 'react-icons/fi';

/**
 * Employees Management Page
 * Redesigned with Grid Layout & Modern Cards
 */

// Form Types
interface EmployeeFormState {
    full_name: string;
    phone: string;
    email: string;
    role: string;
    branch_id: string;
    is_available: boolean;
    assigned_job: string;
    password: string;
}

const initialFormState: EmployeeFormState = {
    full_name: '',
    phone: '',
    email: '',
    role: 'receptionist',
    branch_id: '',
    is_available: true,
    assigned_job: '',
    password: '',
};

// Role Color Mapping
const getRoleColor = (role: string) => {
    const map: Record<string, string> = {
        admin: '#7C3AED', // Purple
        manager: '#2563EB', // Blue
        sales: '#059669', // Green
        designer: '#DB2777', // Pink
        production: '#D97706', // Amber
        fabricator: '#EA580C', // Orange
        installer: '#0891B2', // Cyan
        receptionist: '#4B5563', // Gray
    };
    return map[role] || '#4B5563';
};

const EmployeesPage: NextPageWithLayout = () => {
    const theme = useTheme();

    // Data State
    const [employees, setEmployees] = useState<Employee[]>([]);
    const [branches, setBranches] = useState<Branch[]>([]);
    const [roles, setRoles] = useState<string[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');

    // Modal State
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null);
    const [formState, setFormState] = useState<EmployeeFormState>(initialFormState);
    const [formError, setFormError] = useState<string | null>(null);
    const [submitting, setSubmitting] = useState(false);

    // Delete Confirmation State
    const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
    const [employeeToDelete, setEmployeeToDelete] = useState<Employee | null>(null);

    // Password Reset State
    const [isPasswordModalOpen, setIsPasswordModalOpen] = useState(false);
    const [passwordResetEmployee, setPasswordResetEmployee] = useState<Employee | null>(null);
    const [newPassword, setNewPassword] = useState<string | null>(null);
    const [resettingPassword, setResettingPassword] = useState(false);

    // Created Employee Success State
    const [createdEmployee, setCreatedEmployee] = useState<{ employee: Employee; password: string } | null>(null);

    // Load Initial Data
    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            setLoading(true);
            const [fetchedEmployees, fetchedBranches, fetchedRoles] = await Promise.all([
                getEmployees(),
                getBranches(),
                getEmployeeRoles(),
            ]);
            setEmployees(fetchedEmployees);
            setBranches(fetchedBranches);
            setRoles(fetchedRoles);
        } catch (error) {
            console.error('Failed to load data:', error);
        } finally {
            setLoading(false);
        }
    };

    // Filtered Employees
    const filteredEmployees = useMemo(() => {
        return employees.filter(emp =>
            emp.full_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            emp.role.toLowerCase().includes(searchQuery.toLowerCase()) ||
            emp.email?.toLowerCase().includes(searchQuery.toLowerCase())
        );
    }, [employees, searchQuery]);


    // Handlers
    const handleOpenAdd = () => {
        setEditingEmployee(null);
        setFormState(initialFormState);
        setFormError(null);
        setIsModalOpen(true);
    };

    const handleOpenEdit = (employee: Employee) => {
        setEditingEmployee(employee);
        setFormState({
            full_name: employee.full_name,
            phone: employee.phone ?? '',
            email: employee.email ?? '',
            role: employee.role,
            branch_id: employee.branch_id?.toString() ?? '',
            is_available: employee.is_available ?? true,
            assigned_job: employee.assigned_job ?? '',
            password: '',
        });
        setFormError(null);
        setIsModalOpen(true);
    };

    const handleOpenDelete = (employee: Employee) => {
        setEmployeeToDelete(employee);
        setIsDeleteModalOpen(true);
    };

    const handleOpenPasswordReset = (employee: Employee) => {
        setPasswordResetEmployee(employee);
        setNewPassword(null);
        setIsPasswordModalOpen(true);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setFormError(null);
        setSubmitting(true);

        try {
            const payload: EmployeeInsert = {
                full_name: formState.full_name,
                phone: formState.phone || undefined,
                email: formState.email || undefined,
                role: formState.role,
                branch_id: formState.branch_id ? parseInt(formState.branch_id) : undefined,
                is_available: formState.is_available,
                assigned_job: formState.assigned_job || undefined,
            };

            if (editingEmployee) {
                await updateEmployee(editingEmployee.id, payload);
                await loadData();
                setIsModalOpen(false);
            } else {
                const result = await createEmployeeWithPassword(
                    payload,
                    formState.password || undefined
                );
                await loadData();
                setIsModalOpen(false);
                setCreatedEmployee(result);
            }
        } catch (error) {
            if (error instanceof Error) {
                setFormError(error.message);
            } else {
                setFormError('An unknown error occurred');
            }
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async () => {
        if (!employeeToDelete) return;

        setSubmitting(true);
        try {
            await deleteEmployee(employeeToDelete.id);
            await loadData();
            setIsDeleteModalOpen(false);
            setEmployeeToDelete(null);
        } catch (error) {
            console.error('Failed to delete:', error);
        } finally {
            setSubmitting(false);
        }
    };

    const handlePasswordReset = async () => {
        if (!passwordResetEmployee) return;

        setResettingPassword(true);
        try {
            const newPass = await resetEmployeePassword(passwordResetEmployee.id);
            setNewPassword(newPass);
        } catch (error) {
            console.error('Failed to reset password:', error);
            setNewPassword(null);
        } finally {
            setResettingPassword(false);
        }
    };

    const getBranchName = (id?: number | null) => {
        const branch = branches.find(b => b.id === id);
        return branch ? branch.name : 'Unknown Branch';
    };

    const getInitials = (name: string) => {
        return name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
    };


    return (
        <>
            <Head>
                <title>Manage Employees | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                {/* Header Section */}
                <div css={styles.header}>
                    <div>
                        <h1 css={styles.title(theme)}>Employees</h1>
                        <p css={styles.subtitle}>Manage your team, roles, and access.</p>
                    </div>

                    <div css={styles.controls}>
                        <div style={{ position: 'relative' }}>
                            <FiSearch style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: '#9CA3AF' }} />
                            <input
                                css={styles.searchInput}
                                style={{ paddingLeft: '36px' }}
                                placeholder="Search by name, role, or email..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                        <Button variant="primary" onClick={handleOpenAdd} style={{ padding: '10px 20px', fontSize: '14px', height: '42px' }}>
                            + Add Employee
                        </Button>
                    </div>
                </div>

                {/* Employee Grid */}
                <div css={styles.grid}>
                    {loading ? (
                        <p style={{ gridColumn: '1 / -1', textAlign: 'center', color: '#6B7280', padding: '40px' }}>Loading employees...</p>
                    ) : filteredEmployees.length === 0 ? (
                        <div css={styles.emptyState}>
                            <p style={{ fontSize: '18px', fontWeight: 600 }}>No employees found</p>
                            <p style={{ fontSize: '14px' }}>Try adjusting your search or add a new employee.</p>
                        </div>
                    ) : (
                        filteredEmployees.map(employee => {
                            const roleColor = getRoleColor(employee.role);
                            return (
                                <div key={employee.id} css={styles.card}>
                                    <div css={styles.cardHeader}>
                                        <div css={styles.avatar(roleColor)}>
                                            {getInitials(employee.full_name)}
                                        </div>
                                        <span css={styles.statusBadge(employee.is_available ?? false)}>
                                            {employee.is_available ? 'Available' : 'Busy'}
                                        </span>
                                    </div>

                                    <div css={styles.cardBody}>
                                        <h3 css={styles.name}>{employee.full_name}</h3>
                                        <div css={styles.role}>
                                            <Badge
                                                variant="custom"
                                                customBg={`${roleColor}20`}
                                                customColor={roleColor}
                                                size="sm"
                                            >
                                                {employee.role.replace(/_/g, ' ')}
                                            </Badge>
                                            <span style={{ fontSize: '12px', color: '#9CA3AF', marginLeft: 'auto', fontFamily: 'monospace' }}>#{employee.id.substring(0, 6)}</span>
                                        </div>

                                        <div style={{ marginTop: '8px' }}>
                                            <div css={styles.infoRow}>
                                                <FiMapPin />
                                                <span>{getBranchName(employee.branch_id || undefined)}</span>
                                            </div>
                                            <div css={styles.infoRow}>
                                                <FiPhone />
                                                <span>{employee.phone || 'No phone'}</span>
                                            </div>
                                            <div css={styles.infoRow}>
                                                <FiMail />
                                                <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{employee.email || 'No email'}</span>
                                            </div>
                                        </div>
                                    </div>

                                    <div css={styles.cardFooter}>
                                        <button css={styles.actionButton('primary')} onClick={() => handleOpenEdit(employee)}>
                                            <FiEdit2 /> Edit
                                        </button>
                                        <button css={styles.actionButton('secondary')} onClick={() => handleOpenPasswordReset(employee)}>
                                            <FiKey /> Reset PW
                                        </button>
                                        <button css={styles.actionButton('danger')} onClick={() => handleOpenDelete(employee)}>
                                            <FiTrash2 />
                                        </button>
                                    </div>
                                </div>
                            );
                        })
                    )}
                </div>
            </div>

            {/* Add/Edit Modal */}
            <Modal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title={editingEmployee ? 'Edit Employee' : 'Add New Employee'}
                width="600px"
                footer={
                    <>
                        <Button variant="ghost" onClick={() => setIsModalOpen(false)} disabled={submitting}>
                            Cancel
                        </Button>
                        <Button variant="primary" onClick={handleSubmit} disabled={submitting} isLoading={submitting}>
                            {editingEmployee ? 'Save Changes' : 'Create Employee'}
                        </Button>
                    </>
                }
            >
                <form id="employee-form" onSubmit={handleSubmit} css={styles.form}>
                    <Input
                        label="Full Name"
                        placeholder="e.g. John Doe"
                        value={formState.full_name}
                        onChange={(e) => setFormState({ ...formState, full_name: e.target.value })}
                        required
                        fullWidth
                    />

                    <div css={styles.formSection}>
                        <Input
                            label="Phone"
                            placeholder="e.g. +91 98765 43210"
                            value={formState.phone}
                            onChange={(e) => setFormState({ ...formState, phone: e.target.value })}
                            fullWidth
                        />
                        <Input
                            label="Email"
                            type="email"
                            placeholder="john@example.com"
                            value={formState.email}
                            onChange={(e) => setFormState({ ...formState, email: e.target.value })}
                            fullWidth
                        />
                    </div>

                    <div css={styles.formSection}>
                        <Select
                            label="Role"
                            value={formState.role}
                            onChange={(e) => setFormState({ ...formState, role: e.target.value })}
                            options={roles.map(r => ({ value: r, label: r.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase()) }))}
                            fullWidth
                        />

                        <Select
                            label="Branch"
                            value={formState.branch_id}
                            onChange={(e) => setFormState({ ...formState, branch_id: e.target.value })}
                            options={branches.map(b => ({ value: b.id, label: b.name }))}
                            placeholder="Select a branch"
                            fullWidth
                        />
                    </div>

                    <Select
                        label="Status"
                        value={formState.is_available ? 'true' : 'false'}
                        onChange={(e) => setFormState({ ...formState, is_available: e.target.value === 'true' })}
                        options={[
                            { value: 'true', label: 'Available' },
                            { value: 'false', label: 'Busy / Unavailable' }
                        ]}
                        fullWidth
                    />

                    {/* Password field - only for new employees */}
                    {!editingEmployee && (
                        <Input
                            label="Password (leave blank to auto-generate)"
                            type="text"
                            placeholder="e.g. abc1234"
                            value={formState.password}
                            onChange={(e) => setFormState({ ...formState, password: e.target.value })}
                            fullWidth
                            helperText="Default random password will be generated if left blank"
                        />
                    )}

                    {formError && (
                        <div style={{ color: '#DC2626', fontSize: '14px', backgroundColor: '#FEF2F2', padding: '12px', borderRadius: '8px', border: '1px solid #FECACA' }}>
                            {formError}
                        </div>
                    )}
                </form>
            </Modal>

            {/* Delete Confirmation Modal */}
            <Modal
                isOpen={isDeleteModalOpen}
                onClose={() => setIsDeleteModalOpen(false)}
                title="Confirm Deletion"
                width="400px"
                footer={
                    <>
                        <Button variant="ghost" onClick={() => setIsDeleteModalOpen(false)} disabled={submitting}>
                            Cancel
                        </Button>
                        <Button variant="danger" onClick={handleDelete} disabled={submitting} isLoading={submitting}>
                            Delete Employee
                        </Button>
                    </>
                }
            >
                <div style={{ textAlign: 'center', padding: '16px' }}>
                    <div style={{ fontSize: '48px', marginBottom: '16px' }}>⚠️</div>
                    <h3 style={{ fontSize: '18px', fontWeight: 600, marginBottom: '8px' }}>Are you sure?</h3>
                    <p style={{ color: '#4b5563', lineHeight: 1.5 }}>
                        You are about to delete <strong>{employeeToDelete?.full_name}</strong>.<br />
                        This action cannot be undone.
                    </p>
                </div>
            </Modal>

            {/* Password Reset Modal */}
            <Modal
                isOpen={isPasswordModalOpen}
                onClose={() => {
                    setIsPasswordModalOpen(false);
                    setNewPassword(null);
                }}
                title="Reset Password"
                width="400px"
                footer={
                    <>
                        <Button variant="ghost" onClick={() => { setIsPasswordModalOpen(false); setNewPassword(null); }}>
                            Close
                        </Button>
                        {!newPassword && (
                            <Button variant="primary" onClick={handlePasswordReset} disabled={resettingPassword} isLoading={resettingPassword}>
                                Generate New Password
                            </Button>
                        )}
                    </>
                }
            >
                {newPassword ? (
                    <div style={{ textAlign: 'center' }}>
                        <div style={{
                            width: '50px',
                            height: '50px',
                            background: '#DEF7EC',
                            borderRadius: '50%',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            margin: '0 auto 16px',
                            color: '#03543F',
                            fontSize: '24px'
                        }}>
                            <FiKey />
                        </div>
                        <p style={{ marginBottom: '16px', color: '#4b5563' }}>
                            New password for <strong>{passwordResetEmployee?.full_name}</strong>:
                        </p>
                        <div style={{
                            fontSize: '24px',
                            fontWeight: '700',
                            fontFamily: 'monospace',
                            padding: '16px',
                            background: '#F3F4F6',
                            borderRadius: '8px',
                            letterSpacing: '2px',
                            color: '#1F2937',
                            border: '1px dashed #D1D5DB'
                        }}>
                            {newPassword}
                        </div>
                        <p style={{ marginTop: '16px', fontSize: '13px', color: '#6B7280' }}>
                            Please share this password securely with the employee.
                        </p>
                    </div>
                ) : (
                    <p style={{ color: '#4b5563', lineHeight: 1.5, textAlign: 'center' }}>
                        Reset password for <strong>{passwordResetEmployee?.full_name}</strong>?<br />
                        A new temporary password will be generated.
                    </p>
                )}
            </Modal>

            {/* Created Employee Success Modal */}
            <Modal
                isOpen={!!createdEmployee}
                onClose={() => setCreatedEmployee(null)}
                title="Employee Created Successfully"
                width="450px"
                footer={
                    <Button variant="primary" onClick={() => setCreatedEmployee(null)}>
                        Done
                    </Button>
                }
            >
                {createdEmployee && (
                    <div style={{ textAlign: 'center' }}>
                        <div style={{
                            width: '60px',
                            height: '60px',
                            borderRadius: '50%',
                            background: '#dcfce7',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            margin: '0 auto 16px',
                            color: '#166534'
                        }}>
                            <span style={{ fontSize: '28px' }}>✓</span>
                        </div>
                        <h3 style={{ marginBottom: '8px', fontSize: '20px', fontWeight: 600 }}>{createdEmployee.employee.full_name}</h3>
                        <p style={{ color: '#6b7280', marginBottom: '24px' }}>
                            has been added as <strong>{createdEmployee.employee.role}</strong>
                        </p>

                        <div style={{ background: '#F9FAFB', padding: '20px', borderRadius: '12px', textAlign: 'left', border: '1px solid #E5E7EB' }}>
                            <p style={{ fontSize: '13px', color: '#6b7280', marginBottom: '12px', fontWeight: 600, textTransform: 'uppercase' }}>Login Credentials</p>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', fontSize: '14px' }}>
                                <span style={{ color: '#4B5563' }}>Employee ID:</span>
                                <strong style={{ fontFamily: 'monospace', color: '#111827' }}>{createdEmployee.employee.id}</strong>
                            </div>
                            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
                                <span style={{ color: '#4B5563' }}>Password:</span>
                                <strong style={{ fontFamily: 'monospace', color: '#111827' }}>{createdEmployee.password}</strong>
                            </div>
                        </div>
                        <p style={{ marginTop: '16px', fontSize: '12px', color: '#9ca3af' }}>
                            Please share these credentials securely with the employee.
                        </p>
                    </div>
                )}
            </Modal>
        </>
    );
};

EmployeesPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default EmployeesPage;
