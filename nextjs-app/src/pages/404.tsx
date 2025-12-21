/**
 * 404 Not Found Page
 * Static page for missing routes (optimized by Next.js)
 */

import Head from 'next/head';
import { useRouter } from 'next/router';
import * as styles from '@/styles/pages/404.styles';

export default function NotFoundPage() {
    const router = useRouter();

    const handleGoHome = () => {
        router.push('/');
    };

    const handleGoBack = () => {
        router.back();
    };

    return (
        <>
            <Head>
                <title>404 - Page Not Found | Elite Signboard</title>
            </Head>

            <div css={styles.container}>
                <div css={styles.errorCard}>
                    <div css={styles.iconContainer}>
                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                        >
                            <circle cx="11" cy="11" r="8" />
                            <line x1="21" y1="21" x2="16.65" y2="16.65" />
                            <line x1="8" y1="11" x2="14" y2="11" />
                        </svg>
                    </div>

                    <div css={styles.errorCode}>404</div>
                    <h1 css={styles.title}>Page Not Found</h1>
                    <p css={styles.description}>
                        The page you&apos;re looking for doesn&apos;t exist or has been moved. Check the URL or navigate
                        back to safety.
                    </p>

                    <div css={styles.buttonGroup}>
                        <button css={styles.button('primary')} onClick={handleGoHome}>
                            <svg
                                width="18"
                                height="18"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                strokeWidth="2"
                                strokeLinecap="round"
                                strokeLinejoin="round"
                            >
                                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                                <polyline points="9,22 9,12 15,12 15,22" />
                            </svg>
                            Go Home
                        </button>

                        <button css={styles.button('secondary')} onClick={handleGoBack}>
                            <svg
                                width="18"
                                height="18"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                strokeWidth="2"
                                strokeLinecap="round"
                                strokeLinejoin="round"
                            >
                                <line x1="19" y1="12" x2="5" y2="12" />
                                <polyline points="12,19 5,12 12,5" />
                            </svg>
                            Go Back
                        </button>
                    </div>
                </div>
            </div>
        </>
    );
}
