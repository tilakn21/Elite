/**
 * Design Chat Page Styles
 */

import { css, type Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    display: flex;
    height: calc(100vh - 80px);
    background: ${theme.colors.background};
    overflow: hidden;
`;

export const sidebar = css`
    width: 320px;
    border-right: 1px solid #E5E7EB;
    display: flex;
    flex-direction: column;
    background: white;
`;

export const sidebarHeader = css`
    padding: 20px;
    border-bottom: 1px solid #E5E7EB;
    
    h2 {
        font-size: 18px;
        font-weight: 600;
        color: #1B2330;
        margin: 0;
    }
`;

export const jobList = css`
    flex: 1;
    overflow-y: auto;
`;

export const jobItem = (isActive: boolean) => css`
    padding: 16px 20px;
    cursor: pointer;
    border-bottom: 1px solid #F3F4F6;
    transition: background 0.15s ease;
    background: ${isActive ? '#EEF2FF' : 'transparent'};
    border-left: 3px solid ${isActive ? '#4F46E5' : 'transparent'};
    
    &:hover {
        background: ${isActive ? '#EEF2FF' : '#F9FAFB'};
    }
    
    .job-code {
        font-size: 12px;
        color: #6B7280;
        margin-bottom: 4px;
    }
    
    .customer-name {
        font-size: 14px;
        font-weight: 500;
        color: #1B2330;
    }
    
    .last-message {
        font-size: 12px;
        color: #9CA3AF;
        margin-top: 4px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
`;

export const chatArea = css`
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #F9FAFB;
`;

export const chatHeader = css`
    padding: 16px 24px;
    background: white;
    border-bottom: 1px solid #E5E7EB;
    
    .customer-name {
        font-size: 16px;
        font-weight: 600;
        color: #1B2330;
    }
    
    .job-code {
        font-size: 12px;
        color: #6B7280;
        margin-top: 2px;
    }
`;

export const messagesContainer = css`
    flex: 1;
    overflow-y: auto;
    padding: 20px 24px;
    display: flex;
    flex-direction: column;
    gap: 12px;
`;

export const messageBubble = (isDesigner: boolean) => css`
    max-width: 70%;
    align-self: ${isDesigner ? 'flex-end' : 'flex-start'};
    
    .bubble {
        padding: 12px 16px;
        border-radius: 16px;
        background: ${isDesigner ? '#4F46E5' : 'white'};
        color: ${isDesigner ? 'white' : '#1B2330'};
        box-shadow: ${isDesigner ? 'none' : '0 1px 3px rgba(0,0,0,0.08)'};
        border-bottom-right-radius: ${isDesigner ? '4px' : '16px'};
        border-bottom-left-radius: ${isDesigner ? '16px' : '4px'};
    }
    
    .bubble-image {
        padding: 4px;
        border-radius: 12px;
        background: ${isDesigner ? '#4F46E5' : 'white'};
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        
        img {
            max-width: 280px;
            max-height: 200px;
            border-radius: 8px;
            display: block;
        }
    }
    
    .time {
        font-size: 11px;
        color: #9CA3AF;
        margin-top: 4px;
        text-align: ${isDesigner ? 'right' : 'left'};
    }
    
    .sender {
        font-size: 11px;
        color: #6B7280;
        margin-bottom: 4px;
        font-weight: 500;
    }
`;

export const inputArea = css`
    padding: 16px 24px;
    background: white;
    border-top: 1px solid #E5E7EB;
    display: flex;
    gap: 12px;
    align-items: center;
`;

export const attachButton = css`
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: none;
    background: #F3F4F6;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.15s ease;
    
    &:hover {
        background: #E5E7EB;
    }
    
    svg {
        width: 20px;
        height: 20px;
        color: #6B7280;
    }
`;

export const messageInput = css`
    flex: 1;
    padding: 12px 16px;
    border: 1px solid #E5E7EB;
    border-radius: 24px;
    font-size: 14px;
    outline: none;
    transition: border-color 0.15s ease;
    
    &:focus {
        border-color: #4F46E5;
    }
    
    &::placeholder {
        color: #9CA3AF;
    }
`;

export const sendButton = css`
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: none;
    background: #4F46E5;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.15s ease;
    
    &:hover {
        background: #4338CA;
    }
    
    &:disabled {
        background: #9CA3AF;
        cursor: not-allowed;
    }
    
    svg {
        width: 18px;
        height: 18px;
        color: white;
    }
`;

export const emptyChat = css`
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #9CA3AF;
    
    svg {
        width: 64px;
        height: 64px;
        margin-bottom: 16px;
        opacity: 0.5;
    }
    
    h3 {
        font-size: 16px;
        font-weight: 500;
        margin: 0 0 8px;
    }
    
    p {
        font-size: 14px;
        margin: 0;
    }
`;

export const noJobSelected = css`
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #F9FAFB;
    color: #6B7280;
    
    svg {
        width: 80px;
        height: 80px;
        margin-bottom: 20px;
        opacity: 0.4;
    }
    
    h3 {
        font-size: 18px;
        font-weight: 500;
        color: #374151;
        margin: 0 0 8px;
    }
    
    p {
        font-size: 14px;
        margin: 0;
    }
`;

export const loadingContainer = css`
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
`;

export const spinnerAnimation = css`
    width: 40px;
    height: 40px;
    border: 3px solid #E5E7EB;
    border-top-color: #4F46E5;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
`;

export const imagePreview = css`
    padding: 8px 24px;
    background: #F3F4F6;
    border-top: 1px solid #E5E7EB;
    display: flex;
    align-items: center;
    gap: 12px;
    
    .preview-image {
        width: 60px;
        height: 60px;
        border-radius: 8px;
        object-fit: cover;
    }
    
    .remove-btn {
        width: 24px;
        height: 24px;
        border-radius: 50%;
        border: none;
        background: #EF4444;
        color: white;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
    }
`;
