/**
 * 500 Error Page
 * Static page for server errors (optimized by Next.js)
 */

import Head from 'next/head';
import { useRouter } from 'next/router';
import * as styles from '@/styles/pages/500.styles';

export default function ServerErrorPage() {
    const router = useRouter();

    const handleGoHome = () => {
        router.push('/');
    };

    const handleTryAgain = () => {
        router.reload();
    };

    return (
        <>
            <Head>
                <title>500 - Server Error | Elite Signboard</title>
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
                            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                            <line x1="12" y1="9" x2="12" y2="13" />
                            <line x1="12" y1="17" x2="12.01" y2="17" />
                        </svg>
                    </div>

                    <div css={styles.errorCode}>500</div>
                    <h1 css={styles.title}>Server Error</h1>
                    <p css={styles.description}>
                        Something went wrong on our end. Our team has been notified and is working to fix this. Please
                        try again in a few moments.
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

                        <button css={styles.button('secondary')} onClick={handleTryAgain}>
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
                                <polyline points="23,4 23,10 17,10" />
                                <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
                            </svg>
                            Try Again
                        </button>
                    </div>
                </div>
            </div>
        </>
    );
}
