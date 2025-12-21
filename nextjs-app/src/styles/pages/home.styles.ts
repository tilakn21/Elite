/**
 * Home Page Styles
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

const pulse = keyframes`
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.02);
  }
`;

export const pageContainer = css`
  width: 100vw;
  height: 100vh;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
`;

export const backgroundImage = css`
  position: absolute;
  inset: 0;
  z-index: 0;
`;

export const overlay = css`
  position: absolute;
  inset: 0;
  background: linear-gradient(
    135deg,
    rgba(30, 46, 61, 0.85) 0%,
    rgba(20, 35, 50, 0.9) 50%,
    rgba(10, 25, 40, 0.95) 100%
  );
  z-index: 1;
`;

export const content = css`
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 40px 24px;
  max-width: 600px;
`;

export const logoContainer = css`
  padding: 24px 40px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(12px);
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  margin-bottom: 48px;
  animation: ${fadeIn} 0.8s ease-out;
`;

export const tagline = css`
  font-size: 32px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 16px;
  letter-spacing: -0.5px;
  animation: ${fadeIn} 0.8s ease-out 0.2s both;

  @media (max-width: 600px) {
    font-size: 24px;
  }
`;

export const subtitle = css`
  font-size: 18px;
  color: rgba(255, 255, 255, 0.8);
  margin-bottom: 48px;
  line-height: 1.6;
  animation: ${fadeIn} 0.8s ease-out 0.4s both;

  @media (max-width: 600px) {
    font-size: 16px;
    margin-bottom: 40px;
  }
`;

export const ctaButton = css`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 18px 48px;
  font-size: 18px;
  font-weight: 600;
  color: #1e2e3d;
  background: linear-gradient(135deg, #fff 0%, #f0f4f8 100%);
  border: none;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  animation: ${fadeIn} 0.8s ease-out 0.6s both;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.4);
    animation: ${pulse} 1.5s ease-in-out infinite;
  }

  &:active {
    transform: translateY(0);
  }

  svg {
    width: 20px;
    height: 20px;
    transition: transform 0.3s ease;
  }

  &:hover svg {
    transform: translateX(4px);
  }

  @media (max-width: 600px) {
    padding: 16px 40px;
    font-size: 16px;
  }
`;

export const footer = css`
  position: absolute;
  bottom: 32px;
  left: 0;
  right: 0;
  z-index: 2;
  text-align: center;
  animation: ${fadeIn} 0.8s ease-out 0.8s both;
`;

export const footerText = css`
  font-size: 14px;
  color: rgba(255, 255, 255, 0.5);
`;
