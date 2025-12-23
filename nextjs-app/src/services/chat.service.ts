/**
 * Chat Service
 * Handles chat messaging between designers and customers
 */

import { supabase } from './supabase';

export interface ChatMessage {
    id: string;
    job_id: string;
    sender_type: 'designer' | 'customer';
    sender_id: string;
    sender_name?: string;
    message: string | null;
    image_url: string | null;
    created_at: string;
}

export interface ChatJob {
    id: string;
    job_code: string;
    customer_name: string;
    last_message?: string;
    last_message_at?: string;
    unread_count?: number;
}

/**
 * Get jobs that have chat messages or are in design phase
 */
export async function getChatJobs(): Promise<ChatJob[]> {
    try {
        // Get jobs in design phase
        const { data, error } = await supabase
            .from('jobs')
            .select('id, job_code, receptionist, created_at')
            .or('status.eq.site_visited,status.eq.design_started,status.eq.design_in_review')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching chat jobs:', error);
            return [];
        }

        return (data || []).map(job => ({
            id: job.id,
            job_code: job.job_code,
            customer_name: job.receptionist?.customerName || job.receptionist?.client_name || 'Unknown Customer',
        }));
    } catch (error) {
        console.error('Error in getChatJobs:', error);
        return [];
    }
}

/**
 * Get messages for a specific job
 */
export async function getMessages(jobId: string): Promise<ChatMessage[]> {
    try {
        const { data, error } = await supabase
            .from('chat_messages')
            .select('*')
            .eq('job_id', jobId)
            .order('created_at', { ascending: true });

        if (error) {
            // If table doesn't exist, return empty array
            if (error.code === '42P01') {
                console.warn('chat_messages table does not exist');
                return [];
            }
            console.error('Error fetching messages:', error);
            return [];
        }

        return data || [];
    } catch (error) {
        console.error('Error in getMessages:', error);
        return [];
    }
}

/**
 * Send a text message
 */
export async function sendMessage(
    jobId: string,
    senderId: string,
    senderType: 'designer' | 'customer',
    message: string,
    senderName?: string
): Promise<ChatMessage | null> {
    try {
        const { data, error } = await supabase
            .from('chat_messages')
            .insert({
                job_id: jobId,
                sender_id: senderId,
                sender_type: senderType,
                sender_name: senderName,
                message: message,
                image_url: null,
            })
            .select()
            .single();

        if (error) {
            console.error('Error sending message:', error);
            return null;
        }

        return data;
    } catch (error) {
        console.error('Error in sendMessage:', error);
        return null;
    }
}

/**
 * Upload an image to chat
 */
export async function uploadChatImage(file: File, jobId: string): Promise<string | null> {
    try {
        const fileExt = file.name.split('.').pop();
        const fileName = `${jobId}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}.${fileExt}`;
        const filePath = `${jobId}/${fileName}`;

        const { error: uploadError } = await supabase.storage
            .from('chat-images')
            .upload(filePath, file);

        if (uploadError) {
            console.error('Error uploading chat image:', uploadError);
            return null;
        }

        const { data: urlData } = supabase.storage
            .from('chat-images')
            .getPublicUrl(filePath);

        return urlData?.publicUrl || null;
    } catch (error) {
        console.error('Error in uploadChatImage:', error);
        return null;
    }
}

/**
 * Send an image message
 */
export async function sendImageMessage(
    jobId: string,
    senderId: string,
    senderType: 'designer' | 'customer',
    imageFile: File,
    senderName?: string
): Promise<ChatMessage | null> {
    try {
        // Upload image first
        const imageUrl = await uploadChatImage(imageFile, jobId);
        if (!imageUrl) return null;

        // Create message with image
        const { data, error } = await supabase
            .from('chat_messages')
            .insert({
                job_id: jobId,
                sender_id: senderId,
                sender_type: senderType,
                sender_name: senderName,
                message: null,
                image_url: imageUrl,
            })
            .select()
            .single();

        if (error) {
            console.error('Error sending image message:', error);
            return null;
        }

        return data;
    } catch (error) {
        console.error('Error in sendImageMessage:', error);
        return null;
    }
}

/**
 * Subscribe to new messages for real-time updates
 */
export function subscribeToMessages(
    jobId: string,
    callback: (message: ChatMessage) => void
) {
    const subscription = supabase
        .channel(`chat_${jobId}`)
        .on(
            'postgres_changes',
            {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages',
                filter: `job_id=eq.${jobId}`,
            },
            (payload) => {
                callback(payload.new as ChatMessage);
            }
        )
        .subscribe();

    return () => {
        supabase.removeChannel(subscription);
    };
}
