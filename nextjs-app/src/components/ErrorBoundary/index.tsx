/**
 * Error Boundary Component
 * Catches JavaScript errors anywhere in the component tree and displays a fallback UI
 */

import React, { Component, ReactNode } from 'react';
import styled from '@emotion/styled';
import { keyframes } from '@emotion/react';

const fadeIn = keyframes`
    from {
        opacity: 0;
        transform: scale(0.95);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
`;

const shake = keyframes`
    0%, 100% { transform: translateX(0); }
    10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
    20%, 40%, 60%, 80% { transform: translateX(5px); }
`;

const FallbackContainer = styled.div`
    min-height: 400px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 40px 24px;
    text-align: center;
    animation: ${fadeIn} 0.3s ease-out;
`;

const ErrorCard = styled.div`
    background: #fff;
    border-radius: 16px;
    padding: 40px;
    max-width: 450px;
    width: 100%;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1);
`;

const IconContainer = styled.div`
    width: 80px;
    height: 80px;
    margin: 0 auto 24px;
    background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    animation: ${shake} 0.5s ease-in-out;

    svg {
        width: 40px;
        height: 40px;
        color: #ef4444;
    }
`;

const Title = styled.h2`
    font-size: 20px;
    font-weight: 600;
    color: #1b2330;
    margin: 0 0 8px 0;
`;

const Description = styled.p`
    font-size: 15px;
    color: #6b7280;
    margin: 0 0 24px 0;
    line-height: 1.5;
`;

const ButtonGroup = styled.div`
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
`;

const Button = styled.button<{ variant?: 'primary' | 'secondary' }>`
    padding: 12px 24px;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    border: none;
    display: flex;
    align-items: center;
    gap: 8px;

    ${({ variant = 'primary' }) =>
        variant === 'primary'
            ? `
        background: #5a6cea;
        color: white;

        &:hover {
            background: #4a5cd4;
        }
    `
            : `
        background: #f3f4f6;
        color: #374151;

        &:hover {
            background: #e5e7eb;
        }
    `}
`;

const ErrorDetails = styled.details`
    margin-top: 24px;
    padding-top: 16px;
    border-top: 1px solid #e5e7eb;
    text-align: left;
    width: 100%;

    summary {
        cursor: pointer;
        font-size: 13px;
        color: #6b7280;
        margin-bottom: 8px;
    }

    pre {
        font-size: 12px;
        background: #f9fafb;
        padding: 12px;
        border-radius: 8px;
        overflow-x: auto;
        color: #ef4444;
        margin: 0;
    }
`;

interface Props {
    children: ReactNode;
    fallback?: ReactNode;
    onError?: (error: Error, errorInfo: React.ErrorInfo) => void;
}

interface State {
    hasError: boolean;
    error: Error | null;
    errorInfo: React.ErrorInfo | null;
}

export class ErrorBoundary extends Component<Props, State> {
    constructor(props: Props) {
        super(props);
        this.state = {
            hasError: false,
            error: null,
            errorInfo: null,
        };
    }

    static getDerivedStateFromError(error: Error): Partial<State> {
        return { hasError: true, error };
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo): void {
        this.setState({ errorInfo });

        // Log the error
        console.error('ErrorBoundary caught an error:', error, errorInfo);

        // Call the optional onError callback
        this.props.onError?.(error, errorInfo);
    }

    handleRetry = (): void => {
        this.setState({ hasError: false, error: null, errorInfo: null });
    };

    handleReload = (): void => {
        if (typeof window !== 'undefined') {
            window.location.reload();
        }
    };

    handleGoHome = (): void => {
        if (typeof window !== 'undefined') {
            window.location.href = '/';
        }
    };

    render(): ReactNode {
        if (this.state.hasError) {
            if (this.props.fallback) {
                return this.props.fallback;
            }

            const isDev = process.env.NODE_ENV === 'development';

            return (
                <FallbackContainer>
                    <ErrorCard>
                        <IconContainer>
                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                strokeWidth="2"
                                strokeLinecap="round"
                                strokeLinejoin="round"
                            >
                                <circle cx="12" cy="12" r="10" />
                                <line x1="12" y1="8" x2="12" y2="12" />
                                <line x1="12" y1="16" x2="12.01" y2="16" />
                            </svg>
                        </IconContainer>

                        <Title>Something went wrong</Title>
                        <Description>
                            An unexpected error occurred. You can try again or return to the home page.
                        </Description>

                        <ButtonGroup>
                            <Button variant="primary" onClick={this.handleRetry}>
                                <svg
                                    width="16"
                                    height="16"
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
                            </Button>
                            <Button variant="secondary" onClick={this.handleGoHome}>
                                Go Home
                            </Button>
                        </ButtonGroup>

                        {isDev && this.state.error && (
                            <ErrorDetails>
                                <summary>Error Details (Development Only)</summary>
                                <pre>
                                    {this.state.error.toString()}
                                    {this.state.errorInfo?.componentStack}
                                </pre>
                            </ErrorDetails>
                        )}
                    </ErrorCard>
                </FallbackContainer>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;
