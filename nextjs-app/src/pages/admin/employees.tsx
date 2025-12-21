import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { css, useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard } from '@/components/dashboard';
import { Table, Button, Modal, Input, Select, Badge } from '@/components/ui';
import {
    getEmployees,
    createEmployee,
    updateEmployee,
    deleteEmployee,
    getBranches,
    getEmployeeRoles
} from '@/services';
import type { Employee, EmployeeInsert, Branch } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/employees.styles';

/**
 * Employees Management Page
 * CRUD operations for employees
 */

// Form Types
interface EmployeeFormState {
    full_name: string;
    phone: string;
    email: string;
    role: string;
    branch_id: string; // string for select, parsed to number
    is_available: boolean;
    assigned_job: string;
}

const initialFormState: EmployeeFormState = {
    full_name: '',
    phone: '',
    email: '',
    role: 'Receptionist',
    branch_id: '',
    is_available: true,
    assigned_job: '',
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
        });
        setFormError(null);
        setIsModalOpen(true);
    };

    const handleOpenDelete = (employee: Employee) => {
        setEmployeeToDelete(employee);
        setIsDeleteModalOpen(true);
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
            } else {
                await createEmployee(payload);
            }

            await loadData();
            setIsModalOpen(false);
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

    // Table Columns
    const columns = [
        { key: 'id', header: 'ID', width: '80px' },
        { key: 'full_name', header: 'Name' },
        {
            key: 'role', header: 'Role', width: '140px', render: (row: Employee) => (
                <Badge variant="info" size="sm" className={css({ textTransform: 'capitalize' }).toString()}>
                    {row.role}
                </Badge>
            )
        },
        { key: 'phone', header: 'Phone', width: '140px' },
        {
            key: 'branch_id', header: 'Branch', width: '120px', render: (row: Employee) => {
                const branch = branches.find(b => b.id === row.branch_id);
                return branch ? branch.name : (row.branch_id ? `Branch ${row.branch_id}` : '-');
            }
        },
        {
            key: 'actions',
            header: 'Actions',
            width: '100px',
            render: (row: Employee) => (
                <div css={styles.actions}>
                    <Button size="sm" variant="ghost" onClick={() => handleOpenEdit(row)}>
                        Edit
                    </Button>
                    <Button size="sm" variant="danger" onClick={() => handleOpenDelete(row)}>
                        Delete
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
                        options={roles.map(r => ({ value: r, label: r.charAt(0).toUpperCase() + r.slice(1) }))}
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
        </>
    );
};

EmployeesPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default EmployeesPage;
