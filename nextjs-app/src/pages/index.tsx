import Head from 'next/head';
import Image from 'next/image';
import { useRouter } from 'next/router';
import * as styles from '@/styles/pages/home.styles';

export default function CoverPage() {
  const router = useRouter();

  const handleGetStarted = () => {
    router.push('/login');
  };

  return (
    <>
      <Head>
        <title>Elite Signboard Management</title>
        <meta name="description" content="Streamline your signboard manufacturing with our comprehensive management platform." />
      </Head>

      <div css={styles.pageContainer}>
        <div css={styles.backgroundImage}>
          <Image
            src="/images/login.png"
            alt="Elite Signboard"
            fill
            style={{ objectFit: 'cover' }}
            priority
          />
        </div>
        <div css={styles.overlay} />

        <div css={styles.content}>
          <div css={styles.logoContainer}>
            <Image
              src="/images/elite_logo.png"
              alt="Elite"
              width={180}
              height={72}
              style={{ objectFit: 'contain' }}
            />
          </div>

          <h1 css={styles.tagline}>Signboard Manufacturing Made Simple</h1>
          <p css={styles.subtitle}>
            Streamline your workflow, manage jobs efficiently, and deliver exceptional signboards with our all-in-one platform.
          </p>

          <button css={styles.ctaButton} onClick={handleGetStarted}>
            Get Started
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M5 12h14M12 5l7 7-7 7" />
            </svg>
          </button>
        </div>

        <div css={styles.footer}>
          <p css={styles.footerText}>© 2024 Elite Signboard Management. All rights reserved.</p>
        </div>
      </div>
    </>
  );
}
