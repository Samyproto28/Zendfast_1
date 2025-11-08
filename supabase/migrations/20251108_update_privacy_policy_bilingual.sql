-- Migration: Update Privacy Policy to Bilingual (Add English Version)
-- Created: 2025-11-08
-- Description: Adds English version of Privacy Policy and fixes version constraint to support multiple languages

-- ==============================================================================
-- FIX VERSION CONSTRAINT (Allow same version in different languages)
-- ==============================================================================

-- Drop existing unique constraint on version
ALTER TABLE public.privacy_policy
    DROP CONSTRAINT IF EXISTS privacy_policy_version_key;

-- Create compound unique constraint (version + language)
-- This allows version 1 in Spanish AND version 1 in English
CREATE UNIQUE INDEX IF NOT EXISTS idx_privacy_policy_version_language
    ON public.privacy_policy(version, language);

-- ==============================================================================
-- INSERT ENGLISH PRIVACY POLICY (Version 1.0)
-- ==============================================================================

INSERT INTO public.privacy_policy (
    version,
    content,
    language,
    effective_date,
    is_active
) VALUES (
    1,
    E'# Zendfast Privacy Policy\n\n' ||
    E'**Effective Date:** November 1, 2025\n' ||
    E'**Version:** 1.0\n\n' ||
    E'## 1. Introduction\n\n' ||
    E'At Zendfast, we respect your privacy and are committed to protecting your personal data. This Privacy Policy describes how we collect, use, store, and protect your personal information in accordance with the EU General Data Protection Regulation (GDPR) and the California Consumer Privacy Act (CCPA).\n\n' ||
    E'## 2. Data We Collect\n\n' ||
    E'### 2.1 Profile Information\n' ||
    E'- **Health data:** Weight, height, age, gender, fasting goals\n' ||
    E'- **Account data:** Email, password (encrypted), username\n' ||
    E'- **Preferences:** Daily hydration goal, fasting plan type\n\n' ||
    E'### 2.2 Usage Data\n' ||
    E'- **Fasting sessions:** Start time, duration, completion, interruptions\n' ||
    E'- **Hydration logs:** Water intake amount, timestamps\n' ||
    E'- **Content interactions:** Articles read, videos watched, viewing time\n' ||
    E'- **Aggregate metrics:** Fasting streak, total completed fasts, total duration\n\n' ||
    E'### 2.3 Technical Data\n' ||
    E'- **Analytics:** App usage events, sessions, device type\n' ||
    E'- **Diagnostics:** Error logs, crash information\n\n' ||
    E'## 3. How We Use Your Data\n\n' ||
    E'We use your personal data to:\n\n' ||
    E'1. **Provide the service:** Track your fasts, calculate metrics, display your progress\n' ||
    E'2. **Personalization:** Recommend fasting plans, relevant educational content\n' ||
    E'3. **Product improvement:** Analyze usage patterns, identify bugs, optimize performance\n' ||
    E'4. **Communication:** Send push notifications, marketing emails (only with consent)\n' ||
    E'5. **Legal compliance:** Comply with legal and regulatory obligations\n\n' ||
    E'## 4. Legal Basis for Processing (GDPR)\n\n' ||
    E'We process your data under the following legal bases:\n\n' ||
    E'- **Explicit consent:** For analytics, marketing, non-essential cookies\n' ||
    E'- **Contract performance:** To provide the services you requested\n' ||
    E'- **Legitimate interest:** To improve our services and prevent fraud\n' ||
    E'- **Legal obligation:** To comply with legal requirements\n\n' ||
    E'## 5. Sharing Data with Third Parties\n\n' ||
    E'We do not sell your personal data. We may share data with:\n\n' ||
    E'- **Service providers:** Supabase (database hosting), Google Analytics (with consent)\n' ||
    E'- **Legal compliance:** Government authorities when required by law\n' ||
    E'- **Rights protection:** To protect our legal rights or safety\n\n' ||
    E'## 6. Your Rights (GDPR/CCPA)\n\n' ||
    E'You have the following rights over your data:\n\n' ||
    E'### 6.1 GDPR Rights\n' ||
    E'- **Right of access (Art. 15):** Obtain a copy of your personal data\n' ||
    E'- **Right to rectification (Art. 16):** Correct inaccurate data\n' ||
    E'- **Right to erasure (Art. 17):** Permanently delete your data\n' ||
    E'- **Right to data portability (Art. 20):** Export your data in structured format\n' ||
    E'- **Right to object (Art. 21):** Object to processing of your data\n' ||
    E'- **Right to restriction (Art. 18):** Restrict data processing\n\n' ||
    E'### 6.2 CCPA Rights (California Residents)\n' ||
    E'- **Right to know:** What data we collect and how we use it\n' ||
    E'- **Right to delete:** Request deletion of your data\n' ||
    E'- **Right to opt-out of sale:** We don\'t sell data, but you can enable "Do Not Sell"\n' ||
    E'- **Non-discrimination:** We will not discriminate for exercising your rights\n\n' ||
    E'### 6.3 How to Exercise Your Rights\n\n' ||
    E'You can exercise these rights from the app:\n\n' ||
    E'1. **Export data:** Settings → Privacy → Export My Data (generates ZIP with JSON + CSV)\n' ||
    E'2. **Delete account:** Settings → Privacy → Delete Account (30-day grace period)\n' ||
    E'3. **Manage consents:** Settings → Privacy → Manage Consents\n\n' ||
    E'## 7. Data Retention\n\n' ||
    E'We retain your data while your account is active. Upon account deletion:\n\n' ||
    E'- **30-day grace period:** You can cancel deletion during this period\n' ||
    E'- **After 30 days:** All your data is permanently deleted\n' ||
    E'- **Audit data:** Retained for 90 additional days for legal compliance\n\n' ||
    E'## 8. Data Security\n\n' ||
    E'We implement appropriate security measures:\n\n' ||
    E'- **Encryption:** Passwords hashed with bcrypt, data in transit with TLS/SSL\n' ||
    E'- **Authentication:** Secure authentication system with Supabase Auth\n' ||
    E'- **Access control:** Row Level Security (RLS) in database\n' ||
    E'- **Backups:** Automatic daily database backups\n\n' ||
    E'## 9. Cookies and Tracking Technologies\n\n' ||
    E'The app uses local storage for:\n\n' ||
    E'- **Essential cookies:** User session, preferences (always active)\n' ||
    E'- **Non-essential cookies:** Analytics, personalization (require consent)\n\n' ||
    E'You can manage non-essential cookies in Settings → Consents.\n\n' ||
    E'## 10. International Transfers\n\n' ||
    E'Your data may be transferred and processed on servers located outside your country of residence. We ensure these transfers comply with GDPR through:\n\n' ||
    E'- **Standard Contractual Clauses (SCC)**\n' ||
    E'- **Privacy certifications**\n' ||
    E'- **GDPR-compliant providers**\n\n' ||
    E'## 11. Children\'s Privacy\n\n' ||
    E'Zendfast is not designed for children under 16 years of age. We do not knowingly collect data from children. If we discover we have collected data from a child, we will delete the information immediately.\n\n' ||
    E'## 12. Changes to This Policy\n\n' ||
    E'We may update this Privacy Policy occasionally. We will notify you of significant changes through:\n\n' ||
    E'- Push notification in the app\n' ||
    E'- Email (if you have consented to communications)\n' ||
    E'- Informational banner in the app\n\n' ||
    E'Continued use of the app after changes constitutes acceptance of the new policy.\n\n' ||
    E'## 13. Contact\n\n' ||
    E'For questions about this policy or to exercise your rights, contact us:\n\n' ||
    E'- **Email:** [PRIVACY_EMAIL]\n' ||
    E'- **Address:** [COMPANY_ADDRESS]\n' ||
    E'- **Data Protection Officer (DPO):** [DPO_EMAIL]\n\n' ||
    E'## 14. Supervisory Authority\n\n' ||
    E'If you reside in the EU, you have the right to file a complaint with your local Data Protection Authority if you believe the processing of your personal data violates the GDPR.\n\n' ||
    E'---\n\n' ||
    E'**Last Updated:** November 1, 2025\n\n' ||
    E'**Version:** 1.0\n\n' ||
    E'By using Zendfast, you accept this Privacy Policy. If you do not agree, please do not use the app.',
    'en',
    '2025-11-01 00:00:00+00',
    TRUE
) ON CONFLICT (version, language) DO NOTHING;

-- ==============================================================================
-- UPDATE SPANISH PRIVACY POLICY WITH PLACEHOLDERS
-- ==============================================================================

UPDATE public.privacy_policy
SET content = REPLACE(content, 'privacy@zendfast.com', '[PRIVACY_EMAIL]')
WHERE language = 'es' AND version = 1;

UPDATE public.privacy_policy
SET content = REPLACE(content, 'dpo@zendfast.com', '[DPO_EMAIL]')
WHERE language = 'es' AND version = 1;

UPDATE public.privacy_policy
SET content = REPLACE(content, '[Tu dirección aquí]', '[COMPANY_ADDRESS]')
WHERE language = 'es' AND version = 1;

-- ==============================================================================
-- SUCCESS MESSAGE
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Privacy Policy updated successfully:';
    RAISE NOTICE '   - English version (v1.0) added';
    RAISE NOTICE '   - Spanish version (v1.0) updated with placeholders';
    RAISE NOTICE '   - Version constraint fixed (version + language)';
    RAISE NOTICE '';
    RAISE NOTICE '📝 Placeholders to replace:';
    RAISE NOTICE '   - [PRIVACY_EMAIL] - Privacy contact email';
    RAISE NOTICE '   - [DPO_EMAIL] - Data Protection Officer email';
    RAISE NOTICE '   - [COMPANY_ADDRESS] - Company registered address';
    RAISE NOTICE '';
    RAISE NOTICE '🌐 Available languages:';
    RAISE NOTICE '   - Spanish (es) - Active';
    RAISE NOTICE '   - English (en) - Active';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Next steps:';
    RAISE NOTICE '   1. Update PrivacyPolicyScreen to support language switching';
    RAISE NOTICE '   2. Test both Spanish and English versions';
    RAISE NOTICE '   3. Replace placeholders with actual contact information';
END $$;
