/**
 * Design Chat Page
 * Chat with customers about design jobs
 */

import { useState, useEffect, useRef, useCallback } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { useAuth } from '@/state';
import {
    getChatJobs,
    getMessages,
    sendMessage,
    sendImageMessage,
    subscribeToMessages,
    type ChatJob,
    type ChatMessage,
} from '@/services/chat.service';
import * as styles from '@/styles/pages/design/chats.styles';

// Icons
const AttachIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48" />
    </svg>
);

const SendIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <line x1="22" y1="2" x2="11" y2="13" />
        <polygon points="22 2 15 22 11 13 2 9 22 2" />
    </svg>
);

const ChatIcon = () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
    </svg>
);

export default function DesignChatsPage() {
    const theme = useTheme();
    const { state: authState } = useAuth();

    const [jobs, setJobs] = useState<ChatJob[]>([]);
    const [selectedJob, setSelectedJob] = useState<ChatJob | null>(null);
    const [messages, setMessages] = useState<ChatMessage[]>([]);
    const [newMessage, setNewMessage] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [isSending, setIsSending] = useState(false);
    const [selectedImage, setSelectedImage] = useState<File | null>(null);
    const [imagePreview, setImagePreview] = useState<string | null>(null);

    const messagesEndRef = useRef<HTMLDivElement>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const designerId = authState.user?.employeeId || '';
    const designerName = authState.user?.name || 'Designer';

    // Load jobs on mount
    useEffect(() => {
        async function loadJobs() {
            try {
                const data = await getChatJobs();
                setJobs(data);
            } catch (error) {
                console.error('Failed to load jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJobs();
    }, []);

    // Load messages when job is selected
    useEffect(() => {
        if (!selectedJob) {
            setMessages([]);
            return;
        }

        const jobId = selectedJob.id;

        async function loadMessages() {
            const data = await getMessages(jobId);
            setMessages(data);
        }
        loadMessages();

        // Subscribe to real-time updates
        const unsubscribe = subscribeToMessages(jobId, (newMsg) => {
            setMessages(prev => [...prev, newMsg]);
        });

        return unsubscribe;
    }, [selectedJob]);

    // Scroll to bottom when messages change
    useEffect(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, [messages]);

    const handleSend = useCallback(async () => {
        if (!selectedJob || (!newMessage.trim() && !selectedImage)) return;

        setIsSending(true);
        try {
            if (selectedImage) {
                // Send image
                const msg = await sendImageMessage(
                    selectedJob.id,
                    designerId,
                    'designer',
                    selectedImage,
                    designerName
                );
                if (msg) {
                    setMessages(prev => [...prev, msg]);
                }
                setSelectedImage(null);
                setImagePreview(null);
            } else {
                // Send text
                const msg = await sendMessage(
                    selectedJob.id,
                    designerId,
                    'designer',
                    newMessage.trim(),
                    designerName
                );
                if (msg) {
                    setMessages(prev => [...prev, msg]);
                }
            }
            setNewMessage('');
        } catch (error) {
            console.error('Failed to send message:', error);
        } finally {
            setIsSending(false);
        }
    }, [selectedJob, newMessage, selectedImage, designerId, designerName]);

    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            setSelectedImage(file);
            setImagePreview(URL.createObjectURL(file));
        }
    };

    const removeImage = () => {
        if (imagePreview) URL.revokeObjectURL(imagePreview);
        setSelectedImage(null);
        setImagePreview(null);
    };

    const handleKeyPress = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSend();
        }
    };

    const formatTime = (dateStr: string) => {
        const date = new Date(dateStr);
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    };

    if (isLoading) {
        return (
            <AppLayout variant="dashboard">
                <div css={styles.loadingContainer}>
                    <div css={styles.spinnerAnimation} />
                </div>
            </AppLayout>
        );
    }

    return (
        <>
            <Head>
                <title>Chat | Design Dashboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Jobs Sidebar */}
                    <div css={styles.sidebar}>
                        <div css={styles.sidebarHeader}>
                            <h2>Conversations</h2>
                        </div>
                        <div css={styles.jobList}>
                            {jobs.length === 0 ? (
                                <div style={{ padding: '20px', color: '#9CA3AF', textAlign: 'center' }}>
                                    No active jobs
                                </div>
                            ) : (
                                jobs.map(job => (
                                    <div
                                        key={job.id}
                                        css={styles.jobItem(selectedJob?.id === job.id)}
                                        onClick={() => setSelectedJob(job)}
                                    >
                                        <div className="job-code">#{job.job_code}</div>
                                        <div className="customer-name">{job.customer_name}</div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>

                    {/* Chat Area */}
                    {selectedJob ? (
                        <div css={styles.chatArea}>
                            {/* Header */}
                            <div css={styles.chatHeader}>
                                <div className="customer-name">{selectedJob.customer_name}</div>
                                <div className="job-code">Job #{selectedJob.job_code}</div>
                            </div>

                            {/* Messages */}
                            <div css={styles.messagesContainer}>
                                {messages.length === 0 ? (
                                    <div css={styles.emptyChat}>
                                        <ChatIcon />
                                        <h3>No messages yet</h3>
                                        <p>Start the conversation with the customer</p>
                                    </div>
                                ) : (
                                    messages.map((msg) => (
                                        <div key={msg.id} css={styles.messageBubble(msg.sender_type === 'designer')}>
                                            {msg.sender_type !== 'designer' && (
                                                <div className="sender">{msg.sender_name || 'Customer'}</div>
                                            )}
                                            {msg.image_url ? (
                                                <div className="bubble-image">
                                                    <img src={msg.image_url} alt="Shared image" />
                                                </div>
                                            ) : (
                                                <div className="bubble">{msg.message}</div>
                                            )}
                                            <div className="time">{formatTime(msg.created_at)}</div>
                                        </div>
                                    ))
                                )}
                                <div ref={messagesEndRef} />
                            </div>

                            {/* Image Preview */}
                            {imagePreview && (
                                <div css={styles.imagePreview}>
                                    <img src={imagePreview} alt="Preview" className="preview-image" />
                                    <span style={{ flex: 1, color: '#374151' }}>Ready to send</span>
                                    <button className="remove-btn" onClick={removeImage}>×</button>
                                </div>
                            )}

                            {/* Input Area */}
                            <div css={styles.inputArea}>
                                <input
                                    type="file"
                                    accept="image/*"
                                    ref={fileInputRef}
                                    onChange={handleImageSelect}
                                    style={{ display: 'none' }}
                                />
                                <button
                                    css={styles.attachButton}
                                    onClick={() => fileInputRef.current?.click()}
                                    title="Attach image"
                                >
                                    <AttachIcon />
                                </button>
                                <input
                                    type="text"
                                    css={styles.messageInput}
                                    placeholder="Type a message..."
                                    value={newMessage}
                                    onChange={(e) => setNewMessage(e.target.value)}
                                    onKeyDown={handleKeyPress}
                                    disabled={isSending}
                                />
                                <button
                                    css={styles.sendButton}
                                    onClick={handleSend}
                                    disabled={isSending || (!newMessage.trim() && !selectedImage)}
                                    title="Send message"
                                >
                                    <SendIcon />
                                </button>
                            </div>
                        </div>
                    ) : (
                        <div css={styles.noJobSelected}>
                            <ChatIcon />
                            <h3>Select a conversation</h3>
                            <p>Choose a job from the sidebar to start chatting</p>
                        </div>
                    )}
                </div>
            </AppLayout>
        </>
    );
}
