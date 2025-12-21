/**
 * 500 Page Styles
 */
import { css, keyframes } from '@emotion/react';

const fadeIn = keyframes`
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
`;

const float = keyframes`
    0%, 100% {
        transform: translateY(0);
    }
    50% {
        transform: translateY(-10px);
    }
`;

export const container = css`
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #1e2e3d 0%, #0f1922 100%);
    padding: 24px;
    text-align: center;
`;

export const errorCard = css`
    background: rgba(255, 255, 255, 0.05);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 24px;
    padding: 48px;
    max-width: 500px;
    width: 100%;
    animation: ${fadeIn} 0.6s ease-out;

    @media (max-width: 600px) {
        padding: 32px 24px;
    }
`;

export const iconContainer = css`
    width: 100px;
    height: 100px;
    margin: 0 auto 24px;
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.2) 0%, rgba(239, 68, 68, 0.1) 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    animation: ${float} 3s ease-in-out infinite;

    svg {
        width: 48px;
        height: 48px;
        color: #ef4444;
    }
`;

export const errorCode = css`
    font-size: 64px;
    font-weight: 800;
    background: linear-gradient(135deg, #ef4444 0%, #f97316 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    line-height: 1;
    margin-bottom: 16px;
`;

export const title = css`
    font-size: 24px;
    font-weight: 600;
    color: #fff;
    margin: 0 0 12px 0;

    @media (max-width: 600px) {
        font-size: 20px;
    }
`;

export const description = css`
    font-size: 16px;
    color: rgba(255, 255, 255, 0.7);
    margin: 0 0 32px 0;
    line-height: 1.6;

    @media (max-width: 600px) {
        font-size: 14px;
    }
`;

export const buttonGroup = css`
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
`;

export const button = (variant: 'primary' | 'secondary' = 'primary') => css`
    padding: 14px 28px;
    border-radius: 12px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    border: none;
    display: flex;
    align-items: center;
    gap: 8px;

    ${variant === 'primary' ? css`
        background: linear-gradient(135deg, #5a6cea 0%, #4a5cd4 100%);
        color: white;
        box-shadow: 0 4px 20px rgba(90, 108, 234, 0.3);

        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(90, 108, 234, 0.4);
        }
    ` : css`
        background: rgba(255, 255, 255, 0.1);
        color: white;
        border: 1px solid rgba(255, 255, 255, 0.2);

        &:hover {
            background: rgba(255, 255, 255, 0.15);
        }
    `}

    &:active {
        transform: translateY(0);
    }
`;
