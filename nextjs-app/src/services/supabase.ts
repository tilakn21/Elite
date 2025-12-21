import { createClient, SupabaseClient } from '@supabase/supabase-js';

/**
 * Supabase Client
 * Configured for the Elite Signboard app
 * Uses lazy initialization to prevent SSR localStorage errors
 */

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

// Lazy-initialized client instance
let supabaseInstance: SupabaseClient | null = null;

/**
 * Get the Supabase client instance (lazy initialization)
 * This ensures the client is only created when accessed, not at module load time
 * Returns null if environment variables are missing (graceful degradation)
 */
function getSupabaseClient(): SupabaseClient | null {
    if (supabaseInstance) return supabaseInstance;

    // Graceful handling for missing environment variables
    if (!supabaseUrl || !supabaseAnonKey) {
        const isServer = typeof window === 'undefined';
        if (isServer) {
            // During SSR/build, log once and return null
            console.warn('[Supabase] Missing environment variables - skipping client initialization');
            return null;
        } else {
            // On client-side, this is a critical error
            console.error('[Supabase] Missing environment variables:', {
                hasUrl: !!supabaseUrl,
                hasKey: !!supabaseAnonKey,
            });
            return null;
        }
    }

    const isClient = typeof window !== 'undefined';

    try {
        supabaseInstance = createClient(supabaseUrl, supabaseAnonKey, {
            auth: {
                persistSession: isClient,
                autoRefreshToken: isClient,
                detectSessionInUrl: isClient,
                // Use memory storage on server to prevent localStorage errors
                ...(isClient ? {} : { storage: undefined }),
            },
        });
    } catch (error) {
        console.error('[Supabase] Failed to create client:', error);
        return null;
    }

    return supabaseInstance;
}

// Export a proxy that lazily initializes the client
export const supabase: SupabaseClient = new Proxy({} as SupabaseClient, {
    get(_target, prop) {
        const client = getSupabaseClient();
        if (!client) {
            // Return a no-op function or undefined for safe access when client is unavailable
            console.warn(`[Supabase] Client unavailable, cannot access property: ${String(prop)}`);
            if (prop === 'from') {
                // Return a mock that returns empty results
                return () => ({
                    select: () => Promise.resolve({ data: [], error: null, count: 0 }),
                    insert: () => Promise.resolve({ data: null, error: { message: 'Client unavailable' } }),
                    update: () => Promise.resolve({ data: null, error: { message: 'Client unavailable' } }),
                    delete: () => Promise.resolve({ data: null, error: { message: 'Client unavailable' } }),
                });
            }
            if (prop === 'auth') {
                return {
                    signOut: () => Promise.resolve({ error: null }),
                    getSession: () => Promise.resolve({ data: { session: null } }),
                };
            }
            return undefined;
        }
        const value = client[prop as keyof SupabaseClient];
        if (typeof value === 'function') {
            return value.bind(client);
        }
        return value;
    },
});

// Database types (extend as needed based on your Supabase schema)
export interface Database {
    public: {
        Tables: {
            employees: {
                Row: {
                    id: string;
                    emp_id: string;
                    name: string;
                    email: string | null;
                    password: string;
                    role: string;
                    phone: string | null;
                    department: string | null;
                    avatar_url: string | null;
                    created_at: string;
                    updated_at: string | null;
                };
                Insert: Omit<Database['public']['Tables']['employees']['Row'], 'id' | 'created_at'>;
                Update: Partial<Database['public']['Tables']['employees']['Insert']>;
            };
            jobs: {
                Row: {
                    id: string;
                    job_code: string;
                    status: string;
                    receptionist: Record<string, unknown> | null;
                    salesperson: Record<string, unknown> | null;
                    design: Record<string, unknown>[] | null;
                    production: Record<string, unknown> | null;
                    printing: Record<string, unknown> | null;
                    accounts: Record<string, unknown> | null;
                    created_at: string;
                    updated_at: string | null;
                };
                Insert: Omit<Database['public']['Tables']['jobs']['Row'], 'id' | 'created_at'>;
                Update: Partial<Database['public']['Tables']['jobs']['Insert']>;
            };
            reimbursements: {
                Row: {
                    id: string;
                    employee_id: string;
                    amount: number;
                    description: string;
                    status: string;
                    receipt_urls: string[] | null;
                    created_at: string;
                    updated_at: string | null;
                };
                Insert: Omit<Database['public']['Tables']['reimbursements']['Row'], 'id' | 'created_at'>;
                Update: Partial<Database['public']['Tables']['reimbursements']['Insert']>;
            };
        };
    };
}

export default supabase;
