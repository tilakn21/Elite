/**
 * Login Page Styles
 */
import { css, keyframes } from '@emotion/react';

const fadeIn = keyframes`
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
`;

export const pageContainer = css`
  display: flex;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
`;

export const leftPanel = css`
  display: none;
  position: relative;
  overflow: hidden;
  height: 100%;

  @media (min-width: 900px) {
    display: flex;
    flex: 1;
    max-width: 55%;
    background-color: #1e2e3d;
  }
`;

export const imageOverlay = css`
  position: absolute;
  inset: 0;
  background: linear-gradient(
    to top,
    rgba(0, 0, 0, 0.7) 0%,
    rgba(0, 0, 0, 0.2) 40%,
    rgba(0, 0, 0, 0.1) 100%
  );
  z-index: 1;
`;

export const brandingOverlay = css`
  position: absolute;
  bottom: 48px;
  left: 48px;
  z-index: 2;
  animation: ${fadeIn} 0.8s ease-out 0.3s both;
`;

export const logoContainer = css`
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
`;

export const brandTagline = css`
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.6;
  max-width: 360px;
`;

export const rightPanel = css`
  display: flex;
  flex: 1;
  flex-direction: column;
  padding: 40px 24px;
  height: 100%;
  overflow-y: auto;

  @media (min-width: 900px) {
    min-width: 45%;
    padding: 60px;
  }
`;

export const loginCard = css`
  width: 100%;
  max-width: 420px;
  margin: auto;
  background: #fff;
  border-radius: 24px;
  padding: 48px 40px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.04);
  animation: ${fadeIn} 0.6s ease-out;

  @media (max-width: 600px) {
    padding: 32px 24px;
    border-radius: 20px;
  }
`;

export const logoMobile = css`
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32px;
  padding: 16px 24px;
  background: linear-gradient(135deg, #1e2e3d 0%, #2d4356 100%);
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(30, 46, 61, 0.2);

  @media (min-width: 900px) {
    display: none;
  }
`;

export const title = css`
  font-size: 28px;
  font-weight: 700;
  color: #1b2330;
  text-align: center;
  margin-bottom: 8px;
`;

export const subtitle = css`
  font-size: 15px;
  color: #6b7280;
  text-align: center;
  margin-bottom: 36px;
`;

export const form = css`
  display: flex;
  flex-direction: column;
  gap: 20px;
`;

export const inputGroup = css`
  position: relative;
`;

export const inputLabel = css`
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
`;

export const styledInput = css`
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  font-size: 15px;
  background-color: #f9fafb;
  color: #1b2330;
  transition: all 0.2s ease;

  &::placeholder {
    color: #9ca3af;
  }

  &:hover {
    border-color: #d1d5db;
  }

  &:focus {
    outline: none;
    border-color: #e6007a;
    background-color: #fff;
    box-shadow: 0 0 0 4px rgba(230, 0, 122, 0.1);
  }

  &:disabled {
    background-color: #f3f4f6;
    cursor: not-allowed;
  }
`;

export const passwordWrapper = css`
  position: relative;
`;

export const togglePasswordButton = css`
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #9ca3af;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  background: none;
  border: none;
  cursor: pointer;
  transition: color 0.2s;

  &:hover {
    color: #374151;
  }
`;

export const errorMessage = css`
  background-color: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 10px;
  padding: 12px 16px;
  color: #dc2626;
  font-size: 14px;
  text-align: center;
`;

export const submitButton = css`
  width: 100%;
  height: 52px;
  background: linear-gradient(135deg, #e6007a 0%, #c4006a 100%);
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.5px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 8px;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(230, 0, 122, 0.3);

  &:hover:not(:disabled) {
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(230, 0, 122, 0.4);
  }

  &:active:not(:disabled) {
    transform: translateY(0);
  }

  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    transform: none;
  }
`;

export const spinner = css`
  width: 22px;
  height: 22px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
`;

export const divider = css`
  display: flex;
  align-items: center;
  margin: 24px 0;

  &::before,
  &::after {
    content: '';
    flex: 1;
    height: 1px;
    background-color: #e5e7eb;
  }

  span {
    padding: 0 16px;
    font-size: 12px;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: 1px;
  }
`;

// Quick Login Styles
export const testCredentials = css`
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px;
  margin-top: 24px;

  h4 {
    font-weight: 600;
    margin-bottom: 16px;
    font-size: 14px;
    color: #475569;
    display: flex;
    align-items: center;
    gap: 8px;
  }
`;

export const quickLoginGrid = css`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 12px;
`;

export const quickLoginButton = css`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 12px 8px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  height: 80px;

  &:hover {
    border-color: #e6007a;
    background: #fdf2f8;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(230, 0, 122, 0.1);
  }

  .initial {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: #e6007a;
    color: white;
    font-size: 14px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 8px;
    opacity: 0.9;
  }

  .role {
    font-size: 11px;
    font-weight: 600;
    color: #475569;
    text-align: center;
    line-height: 1.2;
  }
`;
