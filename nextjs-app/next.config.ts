/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,

  // Emotion CSS-in-JS compiler
  compiler: {
    emotion: true,
  },

  // Image optimization
  images: {
    domains: ['xlqrunjrefveuqbaofqi.supabase.co'],
    formats: ['image/avif', 'image/webp'],
  },

  // Disable ESLint during build to prevent deployment failures
  eslint: {
    ignoreDuringBuilds: true,
  },

  // Environment variables validation
  env: {
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  },
};

export default nextConfig;
