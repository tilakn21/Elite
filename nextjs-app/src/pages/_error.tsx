/**
 * Custom Error Page
 * Handles all errors (4xx, 5xx) with styled UI
 */

import { NextPageContext } from 'next';
import Head from 'next/head';
import { useRouter } from 'next/router';
import * as styles from '@/styles/pages/error.styles';

interface ErrorProps {
    statusCode?: number;
}

const errorMessages: Record<number, { title: string; description: string }> = {
    400: {
        title: 'Bad Request',
        description: 'The request could not be understood. Please check and try again.',
    },
    401: {
        title: 'Unauthorized',
        description: 'You need to be logged in to access this page.',
    },
    403: {
        title: 'Forbidden',
        description: "You don't have permission to access this resource.",
    },
    404: {
        title: 'Page Not Found',
        description: "The page you're looking for doesn't exist or has been moved.",
    },
    500: {
        title: 'Server Error',
        description: 'Something went wrong on our end. Please try again later.',
    },
    502: {
        title: 'Bad Gateway',
        description: 'The server received an invalid response. Please try again.',
    },
    503: {
        title: 'Service Unavailable',
        description: 'The service is temporarily unavailable. Please try again shortly.',
    },
};

function ErrorPage({ statusCode }: ErrorProps) {
    const router = useRouter();
    const code = statusCode || 500;
    const errorInfo = errorMessages[code] ?? errorMessages[500] ?? { title: 'Error', description: 'An error occurred.' };

    const handleGoHome = () => {
        router.push('/');
    };

    const handleTryAgain = () => {
        router.reload();
    };

    const handleGoBack = () => {
        router.back();
    };

    return (
        <>
            <Head>
                <title>
                    {code} - {errorInfo.title} | Elite Signboard
                </title>
            </Head>

            <div css={styles.container}>
                <div css={styles.errorCard}>
                    <div css={styles.errorCode}>{code}</div>
                    <h1 css={styles.title}>{errorInfo.title}</h1>
                    <p css={styles.description}>{errorInfo.description}</p>

                    <div css={styles.buttonGroup}>
                        <button css={styles.button('primary')} onClick={handleGoHome}>
                            <span css={styles.iconWrapper}>
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
                            </span>
                            Go Home
                        </button>

                        {code >= 500 && (
                            <button css={styles.button('secondary')} onClick={handleTryAgain}>
                                <span css={styles.iconWrapper}>
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
                                </span>
                                Try Again
                            </button>
                        )}

                        {code === 404 && (
                            <button css={styles.button('secondary')} onClick={handleGoBack}>
                                <span css={styles.iconWrapper}>
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
                                </span>
                                Go Back
                            </button>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
}

ErrorPage.getInitialProps = ({ res, err }: NextPageContext) => {
    const statusCode = res ? res.statusCode : err ? err.statusCode : 404;

    // Log server errors
    if (statusCode && statusCode >= 500) {
        console.error('Server error:', { statusCode, error: err?.message || 'Unknown error' });
    }

    return { statusCode };
};

export default ErrorPage;
