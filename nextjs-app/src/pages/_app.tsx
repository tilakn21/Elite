import type { AppProps } from 'next/app';
import type { NextPage } from 'next';
import type { ReactElement, ReactNode } from 'react';
import { useEffect } from 'react';
import Head from 'next/head';
import { AppProvider } from '@/state';
import { ErrorBoundary } from '@/components/ErrorBoundary';
import { setupGlobalErrorHandlers } from '@/utils/errorHandler';

/**
 * Custom App
 * Wraps all pages with providers, global styles, and error handling
 */

// Type for pages with custom layouts
export type NextPageWithLayout<P = object, IP = P> = NextPage<P, IP> & {
  getLayout?: (page: ReactElement) => ReactNode;
};

type AppPropsWithLayout = AppProps & {
  Component: NextPageWithLayout;
};

export default function App({ Component, pageProps }: AppPropsWithLayout) {
  // Use the page's getLayout if defined, otherwise render page as-is
  const getLayout = Component.getLayout ?? ((page) => page);

  // Setup global error handlers on mount
  useEffect(() => {
    setupGlobalErrorHandlers();
  }, []);

  return (
    <>
      <Head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
        <title>Elite Signboard Management</title>
      </Head>
      <ErrorBoundary>
        <AppProvider>{getLayout(<Component {...pageProps} />)}</AppProvider>
      </ErrorBoundary>
    </>
  );
}
