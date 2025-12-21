import { memo, ReactElement } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { WelcomeHeader, SectionCard } from '@/components/dashboard';
import type { NextPageWithLayout } from '../../pages/_app';

interface DashboardStubProps {
    title: string;
    role: string;
    description: string;
}

const DashboardStub = memo(function DashboardStub({ title, role, description }: DashboardStubProps) {
    const theme = useTheme();

    return (
        <div style={{ display: 'flex', flexDirection: 'column', gap: theme.spacing[6] }}>
            <WelcomeHeader title={title} subtitle={description} />

            <SectionCard title="Dashboard" iconColor={theme.colors.primary}>
                <div style={{
                    padding: '40px',
                    textAlign: 'center',
                    color: theme.colors.textSecondary,
                    backgroundColor: '#f9fafb',
                    borderRadius: '8px',
                    border: '1px dashed #e5e7eb'
                }}>
                    <h3>{role} Dashboard Coming Soon</h3>
                    <p>This module is currently under development.</p>
                </div>
            </SectionCard>
        </div>
    );
});

export const createDashboardPage = (
    title: string,
    role: string,
    description: string
): NextPageWithLayout => {
    const Page: NextPageWithLayout = () => (
        <>
            <Head>
                <title>{role} Dashboard | Elite Signboard</title>
            </Head>
            <DashboardStub title={title} role={role} description={description} />
        </>
    );

    Page.getLayout = (page: ReactElement) => <AppLayout variant="dashboard">{page}</AppLayout>;

    return Page;
};
