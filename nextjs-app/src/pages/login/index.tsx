import { useState, type FormEvent, type ReactElement } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import Image from 'next/image';
import { useAuth } from '@/state';
import { AppLayout } from '@/components/layout';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/login/styles';

/**
 * Login Page
 * Premium desktop-first design matching Flutter's LoginScreen
 */

// Icons
const EyeIcon = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
    <circle cx="12" cy="12" r="3" />
  </svg>
);

const EyeOffIcon = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
    <line x1="1" y1="1" x2="23" y2="23" />
  </svg>
);

const LoginPage: NextPageWithLayout = () => {
  const [employeeId, setEmployeeId] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const { login, state: authState, getDashboardRoute } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    try {
      await login(employeeId, password);
      const dashboardRoute = getDashboardRoute();
      router.push(dashboardRoute);
    } catch (error) {
      console.error('Login failed:', error);
    }
  };

  return (
    <>
      <Head>
        <title>Sign In | Elite Signboard Management</title>
      </Head>

      <div css={styles.pageContainer}>
        {/* Left panel with image (desktop only) */}
        <div css={styles.leftPanel}>
          <Image
            src="/images/login.png"
            alt="Elite Signboard"
            fill
            style={{ objectFit: 'cover' }}
            priority
          />
          <div css={styles.imageOverlay} />
          <div css={styles.brandingOverlay}>
            <div css={styles.logoContainer}>
              <Image
                src="/images/elite_logo.png"
                alt="Elite"
                width={140}
                height={56}
                style={{ objectFit: 'contain' }}
              />
            </div>
            <p css={styles.brandTagline}>
              Streamline your signboard manufacturing with our comprehensive management platform.
            </p>
          </div>
        </div>

        {/* Right panel with login form */}
        <div css={styles.rightPanel}>
          <div css={styles.loginCard}>
            <div css={styles.logoMobile}>
              <Image
                src="/images/elite_logo.png"
                alt="Elite"
                width={120}
                height={48}
                style={{ objectFit: 'contain' }}
              />
            </div>

            <h2 css={styles.title}>Welcome back</h2>
            <p css={styles.subtitle}>Sign in with your employee credentials</p>

            <form css={styles.form} onSubmit={handleSubmit}>
              <div css={styles.inputGroup}>
                <label css={styles.inputLabel} htmlFor="employeeId">Employee ID</label>
                <input
                  css={styles.styledInput}
                  id="employeeId"
                  type="text"
                  placeholder="Enter your employee ID"
                  value={employeeId}
                  onChange={(e) => setEmployeeId(e.target.value)}
                  disabled={authState.isLoading}
                  autoComplete="username"
                  autoFocus
                />
              </div>

              <div css={styles.inputGroup}>
                <label css={styles.inputLabel} htmlFor="password">Password</label>
                <div css={styles.passwordWrapper}>
                  <input
                    css={styles.styledInput}
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    disabled={authState.isLoading}
                    autoComplete="current-password"
                  />
                  <button
                    css={styles.togglePasswordButton}
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                  >
                    {showPassword ? <EyeOffIcon /> : <EyeIcon />}
                  </button>
                </div>
              </div>

              {authState.error && <div css={styles.errorMessage}>{authState.error}</div>}

              <button css={styles.submitButton} type="submit" disabled={authState.isLoading}>
                {authState.isLoading ? <div css={styles.spinner} /> : 'Sign In'}
              </button>
            </form>

            <div css={styles.divider}>
              <span>Test Accounts</span>
            </div>

            <div css={styles.testCredentials}>
              <h4>🧪 Quick Login (Test Accounts)</h4>
              <div css={styles.quickLoginGrid}>
                {[
                  { role: 'Admin', id: 'adm001', pass: 'admin123', init: 'A' },
                  { role: 'Receptionist', id: 'rec001', pass: 'recep123', init: 'R' },
                  { role: 'Salesperson', id: 'sal001', pass: 'sales123', init: 'S' },
                  { role: 'Designer', id: 'des001', pass: 'design123', init: 'D' },
                  { role: 'Production', id: 'prod001', pass: 'prod123', init: 'P' },
                  { role: 'Printing', id: 'pri001', pass: 'print123', init: 'Pr' },
                  { role: 'Accounts', id: 'acc001', pass: 'acc123', init: 'Ac' },
                ].map((acc) => (
                  <button
                    key={acc.id}
                    css={styles.quickLoginButton}
                    type="button"
                    onClick={() => {
                      setEmployeeId(acc.id);
                      setPassword(acc.pass);
                    }}
                  >
                    <div className="initial">{acc.init}</div>
                    <span className="role">{acc.role}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

// Use auth layout (no sidebar/header)
LoginPage.getLayout = (page: ReactElement) => <AppLayout variant="auth">{page}</AppLayout>;

export default LoginPage;
