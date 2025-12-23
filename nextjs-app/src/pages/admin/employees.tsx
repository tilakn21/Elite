import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { css, useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard } from '@/components/dashboard';
import { Table, Button, Modal, Input, Select, Badge } from '@/components/ui';
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

/**
 * Employees Management Page
 * CRUD operations for employees with password management
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
    password: string; // Added for new employees
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

const EmployeesPage: NextPageWithLayout = () => {
    const theme = useTheme();

    // Data State
    const [employees, setEmployees] = useState<Employee[]>([]);
    const [branches, setBranches] = useState<Branch[]>([]);
    const [roles, setRoles] = useState<string[]>([]);
    const [loading, setLoading] = useState(true);

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
            password: '', // Don't show existing password
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
                // Create new employee with password
                const result = await createEmployeeWithPassword(
                    payload,
                    formState.password || undefined
                );
                await loadData();
                setIsModalOpen(false);
                // Show success with generated credentials
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

    // Table Columns
    const columns = [
        { key: 'id', header: 'ID', width: '100px' },
        { key: 'full_name', header: 'Name' },
        {
            key: 'role', header: 'Role', width: '150px', render: (row: Employee) => (
                <Badge variant="info" size="sm" className={css({ textTransform: 'capitalize' }).toString()}>
                    {row.role.replace(/_/g, ' ')}
                </Badge>
            )
        },
        { key: 'phone', header: 'Phone', width: '130px' },
        {
            key: 'branch_id', header: 'Branch', width: '100px', render: (row: Employee) => {
                const branch = branches.find(b => b.id === row.branch_id);
                return branch ? branch.name : '-';
            }
        },
        {
            key: 'actions',
            header: 'Actions',
            width: '180px',
            render: (row: Employee) => (
                <div css={styles.actions}>
                    <Button size="sm" variant="ghost" onClick={() => handleOpenEdit(row)}>
                        Edit
                    </Button>
                    <Button size="sm" variant="outline" onClick={() => handleOpenPasswordReset(row)}>
                        Reset PW
                    </Button>
                    <Button size="sm" variant="danger" onClick={() => handleOpenDelete(row)}>
                        ×
                    </Button>
                </div>
            )
        },
    ];

    return (
        <>
            <Head>
                <title>Manage Employees | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                <div css={styles.header}>
                    <h1 css={styles.title(theme)}>Employees</h1>
                    <Button variant="primary" onClick={handleOpenAdd}>
                        Add Employee
                    </Button>
                </div>

                <SectionCard title="Employee List" iconColor="#6366f1">
                    <Table
                        columns={columns}
                        data={employees}
                        loading={loading}
                        emptyMessage="No employees found. Add one to get started."
                    />
                </SectionCard>
            </div>

            {/* Add/Edit Modal */}
            <Modal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title={editingEmployee ? 'Edit Employee' : 'Add New Employee'}
                width="500px"
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

                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
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

                    {/* Password field - only for new employees */}
                    {!editingEmployee && (
                        <Input
                            label="Password (leave blank to auto-generate)"
                            type="text"
                            placeholder="e.g. abc1234"
                            value={formState.password}
                            onChange={(e) => setFormState({ ...formState, password: e.target.value })}
                            fullWidth
                        />
                    )}

                    {formError && (
                        <div style={{ color: '#dc2626', fontSize: '14px', backgroundColor: '#fee2e2', padding: '12px', borderRadius: '8px' }}>
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
                <p style={{ color: '#4b5563', lineHeight: 1.5 }}>
                    Are you sure you want to delete <strong>{employeeToDelete?.full_name}</strong>?<br />
                    This action cannot be undone.
                </p>
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
                        <p style={{ marginBottom: '16px', color: '#4b5563' }}>
                            New password for <strong>{passwordResetEmployee?.full_name}</strong>:
                        </p>
                        <div style={{
                            fontSize: '24px',
                            fontWeight: '600',
                            fontFamily: 'monospace',
                            padding: '16px',
                            background: '#f3f4f6',
                            borderRadius: '8px',
                            letterSpacing: '2px'
                        }}>
                            {newPassword}
                        </div>
                        <p style={{ marginTop: '16px', fontSize: '13px', color: '#9ca3af' }}>
                            Please share this password securely with the employee.
                        </p>
                    </div>
                ) : (
                    <p style={{ color: '#4b5563', lineHeight: 1.5 }}>
                        Reset password for <strong>{passwordResetEmployee?.full_name}</strong> ({passwordResetEmployee?.id})?<br /><br />
                        A new temporary password will be generated. Make sure to share it with the employee.
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
                            margin: '0 auto 16px'
                        }}>
                            <span style={{ fontSize: '28px' }}>✓</span>
                        </div>
                        <h3 style={{ marginBottom: '8px' }}>{createdEmployee.employee.full_name}</h3>
                        <p style={{ color: '#6b7280', marginBottom: '24px' }}>
                            has been added as <strong>{createdEmployee.employee.role}</strong>
                        </p>

                        <div style={{ background: '#f3f4f6', padding: '16px', borderRadius: '8px', textAlign: 'left' }}>
                            <p style={{ fontSize: '13px', color: '#6b7280', marginBottom: '8px' }}>Login Credentials:</p>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                                <span style={{ color: '#6b7280' }}>Employee ID:</span>
                                <strong style={{ fontFamily: 'monospace' }}>{createdEmployee.employee.id}</strong>
                            </div>
                            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                <span style={{ color: '#6b7280' }}>Password:</span>
                                <strong style={{ fontFamily: 'monospace' }}>{createdEmployee.password}</strong>
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
