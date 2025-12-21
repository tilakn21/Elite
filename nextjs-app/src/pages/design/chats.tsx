import Head from 'next/head';
import { AppLayout } from '@/components/layout';

export default function DesignChatsPage() {
    return (
        <>
            <Head>
                <title>Chats | Design</title>
            </Head>
            <AppLayout variant="dashboard">
                <div style={{ padding: '24px' }}>
                    <h1>Team Chat</h1>
                    <p style={{ color: '#666', marginTop: '12px' }}>Feature coming soon...</p>
                </div>
            </AppLayout>
        </>
    );
}
