-- Migration: Seed Initial Privacy Policy
-- Created: 2025-10-31
-- Description: Inserts initial privacy policy content in Spanish

-- ==============================================================================
-- INSERT INITIAL SPANISH PRIVACY POLICY (Version 1.0)
-- ==============================================================================

INSERT INTO public.privacy_policy (
    version,
    content,
    language,
    effective_date,
    is_active
) VALUES (
    1,
    E'# Política de Privacidad de Zendfast\n\n' ||
    E'**Fecha de vigencia:** 1 de noviembre de 2025\n' ||
    E'**Versión:** 1.0\n\n' ||
    E'## 1. Introducción\n\n' ||
    E'En Zendfast, respetamos tu privacidad y estamos comprometidos con la protección de tus datos personales. Esta Política de Privacidad describe cómo recopilamos, usamos, almacenamos y protegemos tu información personal de acuerdo con el Reglamento General de Protección de Datos (GDPR) de la UE y la Ley de Privacidad del Consumidor de California (CCPA).\n\n' ||
    E'## 2. Datos que Recopilamos\n\n' ||
    E'### 2.1 Información de Perfil\n' ||
    E'- **Datos de salud:** Peso, altura, edad, género, objetivos de ayuno\n' ||
    E'- **Datos de cuenta:** Email, contraseña (encriptada), nombre de usuario\n' ||
    E'- **Preferencias:** Meta de hidratación diaria, tipo de plan de ayuno\n\n' ||
    E'### 2.2 Datos de Uso\n' ||
    E'- **Sesiones de ayuno:** Hora de inicio, duración, finalización, interrupciones\n' ||
    E'- **Registro de hidratación:** Cantidad de agua consumida, timestamps\n' ||
    E'- **Interacciones con contenido:** Artículos leídos, videos vistos, tiempo de visualización\n' ||
    E'- **Métricas agregadas:** Racha de ayunos, total de ayunos completados, duración total\n\n' ||
    E'### 2.3 Datos Técnicos\n' ||
    E'- **Analytics:** Eventos de uso de la app, sesiones, tipo de dispositivo\n' ||
    E'- **Diagnóstico:** Logs de errores, información de crasheos\n\n' ||
    E'## 3. Cómo Usamos tus Datos\n\n' ||
    E'Utilizamos tus datos personales para:\n\n' ||
    E'1. **Proveer el servicio:** Rastrear tus ayunos, calcular métricas, mostrar tu progreso\n' ||
    E'2. **Personalización:** Recomendar planes de ayuno, contenido educativo relevante\n' ||
    E'3. **Mejora del producto:** Analizar patrones de uso, identificar bugs, optimizar rendimiento\n' ||
    E'4. **Comunicación:** Enviar notificaciones push, emails de marketing (solo si consientes)\n' ||
    E'5. **Cumplimiento legal:** Cumplir con obligaciones legales y regulatorias\n\n' ||
    E'## 4. Base Legal para el Procesamiento (GDPR)\n\n' ||
    E'Procesamos tus datos bajo las siguientes bases legales:\n\n' ||
    E'- **Consentimiento explícito:** Para analytics, marketing, cookies no esenciales\n' ||
    E'- **Ejecución de contrato:** Para proveer los servicios que has solicitado\n' ||
    E'- **Interés legítimo:** Para mejorar nuestros servicios y prevenir fraude\n' ||
    E'- **Obligación legal:** Para cumplir con requisitos legales\n\n' ||
    E'## 5. Compartir Datos con Terceros\n\n' ||
    E'No vendemos tus datos personales. Podemos compartir datos con:\n\n' ||
    E'- **Proveedores de servicios:** Supabase (hosting de base de datos), Google Analytics (si consientes)\n' ||
    E'- **Cumplimiento legal:** Autoridades gubernamentales cuando sea requerido por ley\n' ||
    E'- **Protección de derechos:** Para proteger nuestros derechos legales o seguridad\n\n' ||
    E'## 6. Tus Derechos (GDPR/CCPA)\n\n' ||
    E'Tienes los siguientes derechos sobre tus datos:\n\n' ||
    E'### 6.1 Derechos GDPR\n' ||
    E'- **Derecho de acceso (Art. 15):** Obtener copia de tus datos personales\n' ||
    E'- **Derecho de rectificación (Art. 16):** Corregir datos incorrectos\n' ||
    E'- **Derecho de supresión (Art. 17):** Eliminar tus datos permanentemente\n' ||
    E'- **Derecho de portabilidad (Art. 20):** Exportar tus datos en formato estructurado\n' ||
    E'- **Derecho de oposición (Art. 21):** Oponerte al procesamiento de tus datos\n' ||
    E'- **Derecho de restricción (Art. 18):** Restringir el procesamiento de datos\n\n' ||
    E'### 6.2 Derechos CCPA (Californianos)\n' ||
    E'- **Derecho a saber:** Qué datos recopilamos y cómo los usamos\n' ||
    E'- **Derecho a eliminar:** Solicitar eliminación de tus datos\n' ||
    E'- **Derecho a optar por no vender:** No vendemos datos, pero puedes activar "Do Not Sell"\n' ||
    E'- **No discriminación:** No te discriminaremos por ejercer tus derechos\n\n' ||
    E'### 6.3 Cómo Ejercer tus Derechos\n\n' ||
    E'Puedes ejercer estos derechos desde la app:\n\n' ||
    E'1. **Exportar datos:** Configuración → Privacidad → Exportar Mis Datos (genera ZIP con JSON + CSV)\n' ||
    E'2. **Eliminar cuenta:** Configuración → Privacidad → Eliminar Cuenta (30 días de periodo de gracia)\n' ||
    E'3. **Gestionar consentimientos:** Configuración → Privacidad → Gestionar Consentimientos\n\n' ||
    E'## 7. Retención de Datos\n\n' ||
    E'Conservamos tus datos mientras tu cuenta esté activa. Al eliminar tu cuenta:\n\n' ||
    E'- **30 días de gracia:** Puedes cancelar la eliminación durante este periodo\n' ||
    E'- **Después de 30 días:** Todos tus datos se eliminan permanentemente\n' ||
    E'- **Datos de audit:** Se conservan por 90 días adicionales para cumplimiento legal\n\n' ||
    E'## 8. Seguridad de Datos\n\n' ||
    E'Implementamos medidas de seguridad apropiadas:\n\n' ||
    E'- **Encriptación:** Contraseñas hasheadas con bcrypt, datos en tránsito con TLS/SSL\n' ||
    E'- **Autenticación:** Sistema seguro de autenticación con Supabase Auth\n' ||
    E'- **Control de acceso:** Row Level Security (RLS) en base de datos\n' ||
    E'- **Respaldo:** Backups automáticos diarios de la base de datos\n\n' ||
    E'## 9. Cookies y Tecnologías de Rastreo\n\n' ||
    E'La app utiliza almacenamiento local para:\n\n' ||
    E'- **Cookies esenciales:** Sesión de usuario, preferencias (siempre activas)\n' ||
    E'- **Cookies no esenciales:** Analytics, personalización (requieren consentimiento)\n\n' ||
    E'Puedes gestionar las cookies no esenciales en Configuración → Consentimientos.\n\n' ||
    E'## 10. Transferencias Internacionales\n\n' ||
    E'Tus datos pueden ser transferidos y procesados en servidores ubicados fuera de tu país de residencia. Aseguramos que estas transferencias cumplen con GDPR mediante:\n\n' ||
    E'- **Cláusulas Contractuales Estándar (SCC)**\n' ||
    E'- **Certificaciones de privacidad**\n' ||
    E'- **Proveedores conformes con GDPR**\n\n' ||
    E'## 11. Menores de Edad\n\n' ||
    E'Zendfast no está diseñada para menores de 16 años. No recopilamos intencionalmente datos de menores. Si descubrimos que hemos recopilado datos de un menor, eliminaremos la información de inmediato.\n\n' ||
    E'## 12. Cambios a esta Política\n\n' ||
    E'Podemos actualizar esta Política de Privacidad ocasionalmente. Te notificaremos de cambios significativos mediante:\n\n' ||
    E'- Notificación push en la app\n' ||
    E'- Email (si has consentido comunicaciones)\n' ||
    E'- Banner informativo en la app\n\n' ||
    E'El uso continuado de la app después de cambios constituye aceptación de la nueva política.\n\n' ||
    E'## 13. Contacto\n\n' ||
    E'Para preguntas sobre esta política o ejercer tus derechos, contáctanos:\n\n' ||
    E'- **Email:** privacy@zendfast.com\n' ||
    E'- **Dirección:** [Tu dirección aquí]\n' ||
    E'- **Delegado de Protección de Datos (DPO):** dpo@zendfast.com\n\n' ||
    E'## 14. Autoridad Supervisora\n\n' ||
    E'Si resides en la UE, tienes derecho a presentar una queja ante tu Autoridad de Protección de Datos local si crees que el procesamiento de tus datos personales viola el GDPR.\n\n' ||
    E'---\n\n' ||
    E'**Última actualización:** 1 de noviembre de 2025\n\n' ||
    E'**Versión:** 1.0\n\n' ||
    E'Al usar Zendfast, aceptas esta Política de Privacidad. Si no estás de acuerdo, por favor no uses la app.',
    'es',
    '2025-11-01 00:00:00+00',
    TRUE
) ON CONFLICT (version) DO NOTHING;

-- ==============================================================================
-- SUCCESS MESSAGE
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Initial Spanish privacy policy inserted:';
    RAISE NOTICE '   - Version: 1.0';
    RAISE NOTICE '   - Language: Spanish (es)';
    RAISE NOTICE '   - Effective date: 2025-11-01';
    RAISE NOTICE '   - Status: Active';
    RAISE NOTICE '';
    RAISE NOTICE '📄 Privacy policy sections:';
    RAISE NOTICE '   - GDPR compliance (Articles 15-21)';
    RAISE NOTICE '   - CCPA rights for California residents';
    RAISE NOTICE '   - 30-day account deletion grace period';
    RAISE NOTICE '   - Data export instructions';
    RAISE NOTICE '   - Consent management details';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Next steps:';
    RAISE NOTICE '   1. Review privacy policy content with legal team';
    RAISE NOTICE '   2. Update contact information (email, address, DPO)';
    RAISE NOTICE '   3. Create English version (if needed)';
    RAISE NOTICE '   4. Test privacy policy screen in app';
END $$;
