-- Migration: Seed Initial Terms of Service
-- Created: 2025-11-08
-- Description: Inserts initial Terms of Service content in Spanish and English

-- ==============================================================================
-- INSERT SPANISH TERMS OF SERVICE (Version 1.0)
-- ==============================================================================

INSERT INTO public.terms_of_service (
    version,
    content,
    language,
    effective_date,
    is_active
) VALUES (
    1,
    E'# Términos y Condiciones de Uso de Zendfast\n\n' ||
    E'**Fecha de vigencia:** 8 de noviembre de 2025\n' ||
    E'**Versión:** 1.0\n\n' ||
    E'## 1. Aceptación de los Términos\n\n' ||
    E'Al acceder y utilizar la aplicación Zendfast ("la App"), aceptas estar vinculado por estos Términos y Condiciones de Uso ("Términos"). Si no estás de acuerdo con alguna parte de estos Términos, no debes utilizar la App.\n\n' ||
    E'Zendfast es operada por [COMPANY_NAME] ("nosotros", "nuestro" o "la Compañía"). Al usar la App, también aceptas nuestra Política de Privacidad.\n\n' ||
    E'## 2. Disclaimers Médicos y de Salud\n\n' ||
    E'### 2.1 No es Asesoramiento Médico\n\n' ||
    E'**IMPORTANTE:** Zendfast es una herramienta de seguimiento y educación sobre ayuno intermitente. **NO proporciona asesoramiento médico, diagnóstico o tratamiento**. La información proporcionada en la App es únicamente para fines educativos e informativos.\n\n' ||
    E'### 2.2 Consulta con Profesionales de la Salud\n\n' ||
    E'**ANTES DE COMENZAR CUALQUIER PROGRAMA DE AYUNO**, debes consultar con un médico u otro profesional de la salud calificado, especialmente si:\n\n' ||
    E'- Tienes condiciones médicas preexistentes (diabetes, trastornos alimentarios, problemas cardíacos, etc.)\n' ||
    E'- Estás embarazada, amamantando o planeas quedar embarazada\n' ||
    E'- Estás tomando medicamentos\n' ||
    E'- Eres menor de 18 años\n' ||
    E'- Tienes historial de trastornos alimentarios\n' ||
    E'- Tienes bajo peso o estás desnutrido\n\n' ||
    E'### 2.3 No Sustituye Atención Médica Profesional\n\n' ||
    E'Nunca ignores consejos médicos profesionales ni retrases la búsqueda de atención médica debido a información que hayas leído en la App. Si experimentas efectos adversos mientras ayunas, **detén el ayuno inmediatamente** y busca atención médica.\n\n' ||
    E'### 2.4 Limitación de Responsabilidad Médica\n\n' ||
    E'**LA COMPAÑÍA NO SE HACE RESPONSABLE** de cualquier lesión, daño o problema de salud que pueda resultar del uso de la App o de seguir prácticas de ayuno intermitente. El uso de la App es bajo tu propio riesgo.\n\n' ||
    E'## 3. Elegibilidad y Uso de la App\n\n' ||
    E'### 3.1 Edad Mínima\n\n' ||
    E'Debes tener al menos 18 años de edad para usar Zendfast. La App no está diseñada para menores de edad.\n\n' ||
    E'### 3.2 Capacidad Legal\n\n' ||
    E'Al usar la App, declaras que tienes capacidad legal para celebrar un contrato vinculante con nosotros.\n\n' ||
    E'### 3.3 Restricciones Geográficas\n\n' ||
    E'La App está disponible globalmente, pero ciertos servicios o funciones pueden no estar disponibles en todas las jurisdicciones.\n\n' ||
    E'## 4. Licencia de Uso\n\n' ||
    E'### 4.1 Licencia Otorgada\n\n' ||
    E'Te otorgamos una licencia limitada, no exclusiva, no transferible y revocable para usar la App únicamente para tu uso personal y no comercial, sujeto a estos Términos.\n\n' ||
    E'### 4.2 Restricciones de Uso\n\n' ||
    E'**NO PUEDES:**\n\n' ||
    E'- Modificar, adaptar, hackear o realizar ingeniería inversa de la App\n' ||
    E'- Usar la App para fines ilegales o no autorizados\n' ||
    E'- Copiar, distribuir o divulgar cualquier parte de la App\n' ||
    E'- Usar bots, scrapers u otras herramientas automatizadas\n' ||
    E'- Intentar obtener acceso no autorizado a nuestros sistemas\n' ||
    E'- Cargar contenido malicioso (virus, malware, etc.)\n' ||
    E'- Interferir con el funcionamiento normal de la App\n\n' ||
    E'## 5. Cuenta de Usuario\n\n' ||
    E'### 5.1 Creación de Cuenta\n\n' ||
    E'Para usar ciertas funciones de la App, debes crear una cuenta proporcionando información precisa y completa.\n\n' ||
    E'### 5.2 Seguridad de la Cuenta\n\n' ||
    E'Eres responsable de:\n\n' ||
    E'- Mantener la confidencialidad de tus credenciales de acceso\n' ||
    E'- Todas las actividades que ocurran bajo tu cuenta\n' ||
    E'- Notificarnos inmediatamente de cualquier uso no autorizado\n\n' ||
    E'### 5.3 Suspensión y Terminación\n\n' ||
    E'Nos reservamos el derecho de suspender o terminar tu cuenta si:\n\n' ||
    E'- Violas estos Términos\n' ||
    E'- Usas la App de manera fraudulenta o ilegal\n' ||
    E'- Tu cuenta permanece inactiva por un período prolongado\n' ||
    E'- Lo requerimos para cumplir con la ley\n\n' ||
    E'## 6. Suscripciones y Pagos\n\n' ||
    E'### 6.1 Planes de Suscripción\n\n' ||
    E'Zendfast ofrece funciones gratuitas y de suscripción premium. Los planes de suscripción disponibles, características y precios se muestran en la App.\n\n' ||
    E'### 6.2 Facturación y Renovación Automática\n\n' ||
    E'- **Facturación Recurrente:** Las suscripciones se renuevan automáticamente al final de cada período de suscripción (mensual, trimestral, anual)\n' ||
    E'- **Cargos Automáticos:** Se te cobrará automáticamente el precio de suscripción vigente a menos que canceles antes de la fecha de renovación\n' ||
    E'- **Cambios de Precio:** Te notificaremos con anticipación razonable de cualquier cambio de precio\n\n' ||
    E'### 6.3 Método de Pago\n\n' ||
    E'Los pagos se procesan a través de Apple App Store, Google Play Store o Superwall (nuestro proveedor de pagos). Al suscribirte, autorizas a estos proveedores a cargar tu método de pago.\n\n' ||
    E'### 6.4 Cancelación de Suscripción\n\n' ||
    E'Puedes cancelar tu suscripción en cualquier momento:\n\n' ||
    E'- **iOS:** Configuración → [Tu Nombre] → Suscripciones → Zendfast → Cancelar Suscripción\n' ||
    E'- **Android:** Google Play Store → Menú → Suscripciones → Zendfast → Cancelar\n' ||
    E'- **En la App:** Configuración → Suscripción → Gestionar Suscripción\n\n' ||
    E'La cancelación entrará en vigor al final del período de facturación actual. No se emitirán reembolsos prorrateados por cancelaciones a mitad de período.\n\n' ||
    E'### 6.5 Política de Reembolsos\n\n' ||
    E'**Todos los pagos son finales y no reembolsables**, excepto:\n\n' ||
    E'- Cuando lo requiera la ley aplicable\n' ||
    E'- Errores técnicos que resulten en cargos duplicados\n' ||
    E'- A nuestra sola discreción en circunstancias excepcionales\n\n' ||
    E'Las solicitudes de reembolso deben enviarse a [SUPPORT_EMAIL] dentro de los 14 días posteriores al cargo.\n\n' ||
    E'### 6.6 Período de Prueba Gratuita\n\n' ||
    E'Podemos ofrecer períodos de prueba gratuita para nuevos usuarios. Al finalizar el período de prueba, se te cobrará automáticamente a menos que canceles antes de que termine la prueba.\n\n' ||
    E'### 6.7 Cambios en Planes de Suscripción\n\n' ||
    E'Nos reservamos el derecho de:\n\n' ||
    E'- Modificar o descontinuar planes de suscripción\n' ||
    E'- Cambiar características incluidas en cada plan\n' ||
    E'- Ajustar precios (con aviso previo a usuarios existentes)\n\n' ||
    E'## 7. Propiedad Intelectual\n\n' ||
    E'### 7.1 Contenido de la Compañía\n\n' ||
    E'Todo el contenido de la App, incluyendo pero no limitado a:\n\n' ||
    E'- Textos, gráficos, logotipos, íconos, imágenes\n' ||
    E'- Videos, artículos educativos, planes de ayuno\n' ||
    E'- Software, código fuente, algoritmos\n' ||
    E'- Diseño de interfaz de usuario\n\n' ||
    E'Es propiedad de [COMPANY_NAME] o sus licenciantes y está protegido por leyes de derechos de autor, marcas comerciales y otras leyes de propiedad intelectual.\n\n' ||
    E'### 7.2 Contenido del Usuario\n\n' ||
    E'Retienes la propiedad de cualquier contenido que proporciones (comentarios, retroalimentación, sugerencias). Al enviarnos contenido, nos otorgas una licencia mundial, libre de regalías, perpetua e irrevocable para usar, modificar y distribuir ese contenido.\n\n' ||
    E'### 7.3 Marca Registrada\n\n' ||
    E'"Zendfast", nuestro logotipo y otras marcas son propiedad de [COMPANY_NAME]. No puedes usar nuestras marcas sin nuestro permiso previo por escrito.\n\n' ||
    E'## 8. Privacidad y Protección de Datos\n\n' ||
    E'### 8.1 Política de Privacidad\n\n' ||
    E'Tu privacidad es importante para nosotros. Consulta nuestra [Política de Privacidad](#) para entender cómo recopilamos, usamos y protegemos tus datos personales.\n\n' ||
    E'### 8.2 Cumplimiento GDPR/CCPA\n\n' ||
    E'Cumplimos con el GDPR (Reglamento General de Protección de Datos) de la UE y la CCPA (Ley de Privacidad del Consumidor de California). Tienes derechos específicos sobre tus datos personales según se describe en nuestra Política de Privacidad.\n\n' ||
    E'## 9. Responsabilidades del Usuario\n\n' ||
    E'### 9.1 Información Precisa\n\n' ||
    E'Te comprometes a proporcionar información precisa, actual y completa sobre tu perfil de salud (peso, altura, edad, etc.).\n\n' ||
    E'### 9.2 Uso Responsable\n\n' ||
    E'Te comprometes a:\n\n' ||
    E'- Usar la App de manera responsable y segura\n' ||
    E'- Seguir las mejores prácticas de ayuno intermitente\n' ||
    E'- Escuchar a tu cuerpo y detener el ayuno si experimentas efectos adversos\n' ||
    E'- No promover hábitos alimenticios no saludables o trastornos alimenticios\n\n' ||
    E'### 9.3 Conducta Prohibida\n\n' ||
    E'**NO DEBES:**\n\n' ||
    E'- Usar la App para promover contenido ilegal, ofensivo o dañino\n' ||
    E'- Acosar, intimidar o amenazar a otros usuarios\n' ||
    E'- Suplantar la identidad de otra persona\n' ||
    E'- Violar los derechos de privacidad de otros\n' ||
    E'- Compartir información falsa o engañosa\n\n' ||
    E'## 10. Limitaciones de Responsabilidad\n\n' ||
    E'### 10.1 Descargo de Garantías\n\n' ||
    E'LA APP SE PROPORCIONA "TAL CUAL" Y "SEGÚN DISPONIBILIDAD", SIN GARANTÍAS DE NINGÚN TIPO, EXPRESAS O IMPLÍCITAS, INCLUYENDO PERO NO LIMITADO A:\n\n' ||
    E'- Garantías de comerciabilidad\n' ||
    E'- Idoneidad para un propósito particular\n' ||
    E'- No violación de derechos de terceros\n' ||
    E'- Precisión, confiabilidad o disponibilidad continua\n\n' ||
    E'### 10.2 Limitación de Daños\n\n' ||
    E'EN LA MEDIDA MÁXIMA PERMITIDA POR LA LEY, [COMPANY_NAME] NO SERÁ RESPONSABLE DE:\n\n' ||
    E'- Daños indirectos, incidentales, especiales o consecuentes\n' ||
    E'- Pérdida de beneficios, datos, uso o goodwill\n' ||
    E'- Lesiones personales o daños a la salud resultantes del uso de la App\n' ||
    E'- Problemas causados por terceros (proveedores de servicios, tiendas de aplicaciones)\n\n' ||
    E'**NUESTRA RESPONSABILIDAD TOTAL** hacia ti por cualquier reclamo bajo estos Términos no excederá la cantidad que hayas pagado por la App en los últimos 12 meses.\n\n' ||
    E'### 10.3 Indemnización\n\n' ||
    E'Aceptas defendernos, indemnizarnos y mantenernos indemnes de cualquier reclamo, daño, obligación, pérdida, responsabilidad, costo o deuda, y gastos que surjan de:\n\n' ||
    E'- Tu uso de la App\n' ||
    E'- Tu violación de estos Términos\n' ||
    E'- Tu violación de los derechos de terceros\n\n' ||
    E'## 11. Modificaciones a la App y Términos\n\n' ||
    E'### 11.1 Cambios a la App\n\n' ||
    E'Nos reservamos el derecho de:\n\n' ||
    E'- Modificar, suspender o discontinuar cualquier parte de la App\n' ||
    E'- Actualizar características o funcionalidades\n' ||
    E'- Realizar mantenimiento programado o de emergencia\n\n' ||
    E'No somos responsables si la App no está disponible en cualquier momento.\n\n' ||
    E'### 11.2 Cambios a los Términos\n\n' ||
    E'Podemos actualizar estos Términos ocasionalmente. Te notificaremos de cambios significativos mediante:\n\n' ||
    E'- Notificación push en la App\n' ||
    E'- Email (si has proporcionado tu correo electrónico)\n' ||
    E'- Banner informativo en la App\n\n' ||
    E'El uso continuado de la App después de cambios constituye aceptación de los nuevos Términos. Si no estás de acuerdo con los cambios, debes dejar de usar la App.\n\n' ||
    E'## 12. Terminación de Cuenta\n\n' ||
    E'### 12.1 Terminación por el Usuario\n\n' ||
    E'Puedes eliminar tu cuenta en cualquier momento desde:\n\n' ||
    E'Configuración → Privacidad → Eliminar Cuenta\n\n' ||
    E'**Período de Gracia de 30 Días:**\n\n' ||
    E'- Tus datos se marcan para eliminación pero se conservan durante 30 días\n' ||
    E'- Puedes cancelar la eliminación durante este período\n' ||
    E'- Después de 30 días, todos tus datos se eliminan permanentemente\n\n' ||
    E'### 12.2 Terminación por la Compañía\n\n' ||
    E'Podemos suspender o terminar tu cuenta inmediatamente si:\n\n' ||
    E'- Violas estos Términos\n' ||
    E'- Participas en actividades fraudulentas o ilegales\n' ||
    E'- Tu cuenta ha sido inactiva por más de 2 años\n' ||
    E'- Lo requiere la ley o autoridades gubernamentales\n\n' ||
    E'### 12.3 Efectos de la Terminación\n\n' ||
    E'Al terminar tu cuenta:\n\n' ||
    E'- Pierdes acceso a todas las funciones de la App\n' ||
    E'- Tus suscripciones activas se cancelan (sin reembolso)\n' ||
    E'- Tus datos se eliminan según nuestra Política de Privacidad\n\n' ||
    E'## 13. Jurisdicción y Ley Aplicable\n\n' ||
    E'### 13.1 Ley Aplicable\n\n' ||
    E'Estos Términos se rigen por las leyes de [JURISDICTION], sin dar efecto a ningún principio de conflictos de leyes.\n\n' ||
    E'### 13.2 Jurisdicción\n\n' ||
    E'Cualquier disputa que surja de estos Términos será sometida a la jurisdicción exclusiva de los tribunales de [JURISDICTION].\n\n' ||
    E'### 13.3 Resolución de Disputas\n\n' ||
    E'**Negociación Informal:**\n\n' ||
    E'Si tienes una disputa, primero intenta resolverla contactándonos en [SUPPORT_EMAIL]. Intentaremos resolver la disputa de manera informal.\n\n' ||
    E'**Arbitraje:**\n\n' ||
    E'Si no podemos resolver la disputa informalmente en 60 días, cualquier disputa se resolverá mediante arbitraje vinculante de acuerdo con las reglas de [ARBITRATION_BODY].\n\n' ||
    E'**Renuncia a Acciones Colectivas:**\n\n' ||
    E'Aceptas que cualquier disputa se resolverá individualmente y no como parte de una acción colectiva o class action.\n\n' ||
    E'### 13.4 Derechos de Consumidores de la UE\n\n' ||
    E'Si resides en la Unión Europea, nada en estos Términos afecta tus derechos como consumidor según las leyes de protección al consumidor de la UE.\n\n' ||
    E'## 14. Servicios de Terceros\n\n' ||
    E'### 14.1 Integraciones de Terceros\n\n' ||
    E'La App puede integrarse con servicios de terceros:\n\n' ||
    E'- **Supabase:** Hosting de base de datos y autenticación\n' ||
    E'- **OneSignal:** Notificaciones push\n' ||
    E'- **Superwall:** Procesamiento de pagos\n' ||
    E'- **Sentry:** Monitoreo de errores\n\n' ||
    E'### 14.2 Términos de Terceros\n\n' ||
    E'El uso de servicios de terceros está sujeto a sus propios términos y condiciones. No somos responsables de las acciones u omisiones de proveedores de terceros.\n\n' ||
    E'### 14.3 App Stores\n\n' ||
    E'Si descargas la App desde Apple App Store o Google Play Store, también estás sujeto a sus términos de servicio.\n\n' ||
    E'## 15. Disposiciones Generales\n\n' ||
    E'### 15.1 Acuerdo Completo\n\n' ||
    E'Estos Términos, junto con nuestra Política de Privacidad, constituyen el acuerdo completo entre tú y [COMPANY_NAME] con respecto al uso de la App.\n\n' ||
    E'### 15.2 Divisibilidad\n\n' ||
    E'Si cualquier disposición de estos Términos se considera inválida o inaplicable, las demás disposiciones permanecerán en pleno vigor y efecto.\n\n' ||
    E'### 15.3 Renuncia\n\n' ||
    E'Nuestra falta de aplicación de cualquier derecho o disposición de estos Términos no se considerará una renuncia a dichos derechos.\n\n' ||
    E'### 15.4 Cesión\n\n' ||
    E'No puedes transferir o ceder tus derechos u obligaciones bajo estos Términos sin nuestro consentimiento previo por escrito. Podemos ceder estos Términos sin restricciones.\n\n' ||
    E'### 15.5 Notificaciones\n\n' ||
    E'Todas las notificaciones bajo estos Términos se enviarán por correo electrónico a la dirección asociada con tu cuenta o mediante notificación en la App.\n\n' ||
    E'### 15.6 Fuerza Mayor\n\n' ||
    E'No seremos responsables por ningún retraso o falla en el cumplimiento de nuestras obligaciones debido a causas fuera de nuestro control razonable.\n\n' ||
    E'## 16. Contacto\n\n' ||
    E'Para preguntas sobre estos Términos, contáctanos:\n\n' ||
    E'- **Email:** [SUPPORT_EMAIL]\n' ||
    E'- **Email de Privacidad:** [PRIVACY_EMAIL]\n' ||
    E'- **Dirección:** [COMPANY_ADDRESS]\n' ||
    E'- **Website:** https://zendfast.app\n\n' ||
    E'---\n\n' ||
    E'**Última actualización:** 8 de noviembre de 2025\n\n' ||
    E'**Versión:** 1.0\n\n' ||
    E'Al usar Zendfast, reconoces que has leído, entendido y aceptas estar vinculado por estos Términos y Condiciones de Uso.',
    'es',
    '2025-11-08 00:00:00+00',
    TRUE
) ON CONFLICT (version, language) DO NOTHING;

-- ==============================================================================
-- INSERT ENGLISH TERMS OF SERVICE (Version 1.0)
-- ==============================================================================

INSERT INTO public.terms_of_service (
    version,
    content,
    language,
    effective_date,
    is_active
) VALUES (
    1,
    E'# Zendfast Terms and Conditions of Use\n\n' ||
    E'**Effective Date:** November 8, 2025\n' ||
    E'**Version:** 1.0\n\n' ||
    E'## 1. Acceptance of Terms\n\n' ||
    E'By accessing and using the Zendfast application ("the App"), you agree to be bound by these Terms and Conditions of Use ("Terms"). If you do not agree with any part of these Terms, you must not use the App.\n\n' ||
    E'Zendfast is operated by [COMPANY_NAME] ("we", "our", or "the Company"). By using the App, you also accept our Privacy Policy.\n\n' ||
    E'## 2. Medical and Health Disclaimers\n\n' ||
    E'### 2.1 Not Medical Advice\n\n' ||
    E'**IMPORTANT:** Zendfast is a tracking and educational tool for intermittent fasting. It **DOES NOT provide medical advice, diagnosis, or treatment**. Information provided in the App is for educational and informational purposes only.\n\n' ||
    E'### 2.2 Consult Healthcare Professionals\n\n' ||
    E'**BEFORE STARTING ANY FASTING PROGRAM**, you must consult with a physician or other qualified healthcare professional, especially if you:\n\n' ||
    E'- Have pre-existing medical conditions (diabetes, eating disorders, heart problems, etc.)\n' ||
    E'- Are pregnant, nursing, or planning to become pregnant\n' ||
    E'- Are taking medications\n' ||
    E'- Are under 18 years of age\n' ||
    E'- Have a history of eating disorders\n' ||
    E'- Are underweight or malnourished\n\n' ||
    E'### 2.3 Does Not Replace Professional Medical Care\n\n' ||
    E'Never ignore professional medical advice or delay seeking medical care because of information you have read in the App. If you experience adverse effects while fasting, **stop fasting immediately** and seek medical attention.\n\n' ||
    E'### 2.4 Medical Liability Limitation\n\n' ||
    E'**THE COMPANY IS NOT LIABLE** for any injury, damage, or health issue that may result from using the App or following intermittent fasting practices. Use of the App is at your own risk.\n\n' ||
    E'## 3. Eligibility and App Use\n\n' ||
    E'### 3.1 Minimum Age\n\n' ||
    E'You must be at least 18 years old to use Zendfast. The App is not designed for minors.\n\n' ||
    E'### 3.2 Legal Capacity\n\n' ||
    E'By using the App, you represent that you have legal capacity to enter into a binding contract with us.\n\n' ||
    E'### 3.3 Geographic Restrictions\n\n' ||
    E'The App is available globally, but certain services or features may not be available in all jurisdictions.\n\n' ||
    E'## 4. License to Use\n\n' ||
    E'### 4.1 License Granted\n\n' ||
    E'We grant you a limited, non-exclusive, non-transferable, and revocable license to use the App solely for your personal, non-commercial use, subject to these Terms.\n\n' ||
    E'### 4.2 Use Restrictions\n\n' ||
    E'**YOU MAY NOT:**\n\n' ||
    E'- Modify, adapt, hack, or reverse engineer the App\n' ||
    E'- Use the App for illegal or unauthorized purposes\n' ||
    E'- Copy, distribute, or disclose any part of the App\n' ||
    E'- Use bots, scrapers, or other automated tools\n' ||
    E'- Attempt to gain unauthorized access to our systems\n' ||
    E'- Upload malicious content (viruses, malware, etc.)\n' ||
    E'- Interfere with the normal operation of the App\n\n' ||
    E'## 5. User Account\n\n' ||
    E'### 5.1 Account Creation\n\n' ||
    E'To use certain features of the App, you must create an account by providing accurate and complete information.\n\n' ||
    E'### 5.2 Account Security\n\n' ||
    E'You are responsible for:\n\n' ||
    E'- Maintaining the confidentiality of your access credentials\n' ||
    E'- All activities that occur under your account\n' ||
    E'- Notifying us immediately of any unauthorized use\n\n' ||
    E'### 5.3 Suspension and Termination\n\n' ||
    E'We reserve the right to suspend or terminate your account if:\n\n' ||
    E'- You violate these Terms\n' ||
    E'- You use the App fraudulently or illegally\n' ||
    E'- Your account remains inactive for an extended period\n' ||
    E'- Required by law\n\n' ||
    E'## 6. Subscriptions and Payments\n\n' ||
    E'### 6.1 Subscription Plans\n\n' ||
    E'Zendfast offers free and premium subscription features. Available subscription plans, features, and pricing are displayed in the App.\n\n' ||
    E'### 6.2 Billing and Auto-Renewal\n\n' ||
    E'- **Recurring Billing:** Subscriptions automatically renew at the end of each subscription period (monthly, quarterly, annual)\n' ||
    E'- **Automatic Charges:** You will be automatically charged the current subscription price unless you cancel before the renewal date\n' ||
    E'- **Price Changes:** We will notify you with reasonable advance notice of any price changes\n\n' ||
    E'### 6.3 Payment Method\n\n' ||
    E'Payments are processed through Apple App Store, Google Play Store, or Superwall (our payment provider). By subscribing, you authorize these providers to charge your payment method.\n\n' ||
    E'### 6.4 Subscription Cancellation\n\n' ||
    E'You can cancel your subscription at any time:\n\n' ||
    E'- **iOS:** Settings → [Your Name] → Subscriptions → Zendfast → Cancel Subscription\n' ||
    E'- **Android:** Google Play Store → Menu → Subscriptions → Zendfast → Cancel\n' ||
    E'- **In-App:** Settings → Subscription → Manage Subscription\n\n' ||
    E'Cancellation takes effect at the end of the current billing period. No prorated refunds will be issued for mid-period cancellations.\n\n' ||
    E'### 6.5 Refund Policy\n\n' ||
    E'**All payments are final and non-refundable**, except:\n\n' ||
    E'- When required by applicable law\n' ||
    E'- Technical errors resulting in duplicate charges\n' ||
    E'- At our sole discretion in exceptional circumstances\n\n' ||
    E'Refund requests must be submitted to [SUPPORT_EMAIL] within 14 days of the charge.\n\n' ||
    E'### 6.6 Free Trial Period\n\n' ||
    E'We may offer free trial periods for new users. At the end of the trial period, you will be automatically charged unless you cancel before the trial ends.\n\n' ||
    E'### 6.7 Changes to Subscription Plans\n\n' ||
    E'We reserve the right to:\n\n' ||
    E'- Modify or discontinue subscription plans\n' ||
    E'- Change features included in each plan\n' ||
    E'- Adjust pricing (with prior notice to existing users)\n\n' ||
    E'## 7. Intellectual Property\n\n' ||
    E'### 7.1 Company Content\n\n' ||
    E'All App content, including but not limited to:\n\n' ||
    E'- Text, graphics, logos, icons, images\n' ||
    E'- Videos, educational articles, fasting plans\n' ||
    E'- Software, source code, algorithms\n' ||
    E'- User interface design\n\n' ||
    E'Is owned by [COMPANY_NAME] or its licensors and is protected by copyright, trademark, and other intellectual property laws.\n\n' ||
    E'### 7.2 User Content\n\n' ||
    E'You retain ownership of any content you provide (comments, feedback, suggestions). By submitting content to us, you grant us a worldwide, royalty-free, perpetual, and irrevocable license to use, modify, and distribute that content.\n\n' ||
    E'### 7.3 Trademark\n\n' ||
    E'"Zendfast", our logo, and other marks are owned by [COMPANY_NAME]. You may not use our trademarks without our prior written permission.\n\n' ||
    E'## 8. Privacy and Data Protection\n\n' ||
    E'### 8.1 Privacy Policy\n\n' ||
    E'Your privacy is important to us. See our [Privacy Policy](#) to understand how we collect, use, and protect your personal data.\n\n' ||
    E'### 8.2 GDPR/CCPA Compliance\n\n' ||
    E'We comply with the EU General Data Protection Regulation (GDPR) and the California Consumer Privacy Act (CCPA). You have specific rights over your personal data as described in our Privacy Policy.\n\n' ||
    E'## 9. User Responsibilities\n\n' ||
    E'### 9.1 Accurate Information\n\n' ||
    E'You agree to provide accurate, current, and complete information about your health profile (weight, height, age, etc.).\n\n' ||
    E'### 9.2 Responsible Use\n\n' ||
    E'You agree to:\n\n' ||
    E'- Use the App responsibly and safely\n' ||
    E'- Follow best practices for intermittent fasting\n' ||
    E'- Listen to your body and stop fasting if you experience adverse effects\n' ||
    E'- Not promote unhealthy eating habits or eating disorders\n\n' ||
    E'### 9.3 Prohibited Conduct\n\n' ||
    E'**YOU MUST NOT:**\n\n' ||
    E'- Use the App to promote illegal, offensive, or harmful content\n' ||
    E'- Harass, intimidate, or threaten other users\n' ||
    E'- Impersonate another person\n' ||
    E'- Violate others\' privacy rights\n' ||
    E'- Share false or misleading information\n\n' ||
    E'## 10. Limitation of Liability\n\n' ||
    E'### 10.1 Disclaimer of Warranties\n\n' ||
    E'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE", WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO:\n\n' ||
    E'- Warranties of merchantability\n' ||
    E'- Fitness for a particular purpose\n' ||
    E'- Non-infringement of third-party rights\n' ||
    E'- Accuracy, reliability, or continuous availability\n\n' ||
    E'### 10.2 Limitation of Damages\n\n' ||
    E'TO THE MAXIMUM EXTENT PERMITTED BY LAW, [COMPANY_NAME] SHALL NOT BE LIABLE FOR:\n\n' ||
    E'- Indirect, incidental, special, or consequential damages\n' ||
    E'- Loss of profits, data, use, or goodwill\n' ||
    E'- Personal injury or health damage resulting from use of the App\n' ||
    E'- Issues caused by third parties (service providers, app stores)\n\n' ||
    E'**OUR TOTAL LIABILITY** to you for any claim under these Terms shall not exceed the amount you have paid for the App in the last 12 months.\n\n' ||
    E'### 10.3 Indemnification\n\n' ||
    E'You agree to defend, indemnify, and hold us harmless from any claim, damage, obligation, loss, liability, cost, or debt, and expense arising from:\n\n' ||
    E'- Your use of the App\n' ||
    E'- Your violation of these Terms\n' ||
    E'- Your violation of third-party rights\n\n' ||
    E'## 11. Modifications to the App and Terms\n\n' ||
    E'### 11.1 Changes to the App\n\n' ||
    E'We reserve the right to:\n\n' ||
    E'- Modify, suspend, or discontinue any part of the App\n' ||
    E'- Update features or functionality\n' ||
    E'- Perform scheduled or emergency maintenance\n\n' ||
    E'We are not liable if the App is unavailable at any time.\n\n' ||
    E'### 11.2 Changes to Terms\n\n' ||
    E'We may update these Terms occasionally. We will notify you of significant changes through:\n\n' ||
    E'- Push notification in the App\n' ||
    E'- Email (if you have provided your email)\n' ||
    E'- Informational banner in the App\n\n' ||
    E'Continued use of the App after changes constitutes acceptance of the new Terms. If you do not agree with the changes, you must stop using the App.\n\n' ||
    E'## 12. Account Termination\n\n' ||
    E'### 12.1 User Termination\n\n' ||
    E'You can delete your account at any time from:\n\n' ||
    E'Settings → Privacy → Delete Account\n\n' ||
    E'**30-Day Grace Period:**\n\n' ||
    E'- Your data is marked for deletion but retained for 30 days\n' ||
    E'- You can cancel the deletion during this period\n' ||
    E'- After 30 days, all your data is permanently deleted\n\n' ||
    E'### 12.2 Company Termination\n\n' ||
    E'We may suspend or terminate your account immediately if:\n\n' ||
    E'- You violate these Terms\n' ||
    E'- You engage in fraudulent or illegal activities\n' ||
    E'- Your account has been inactive for more than 2 years\n' ||
    E'- Required by law or government authorities\n\n' ||
    E'### 12.3 Effects of Termination\n\n' ||
    E'Upon account termination:\n\n' ||
    E'- You lose access to all App features\n' ||
    E'- Your active subscriptions are canceled (no refund)\n' ||
    E'- Your data is deleted according to our Privacy Policy\n\n' ||
    E'## 13. Jurisdiction and Applicable Law\n\n' ||
    E'### 13.1 Governing Law\n\n' ||
    E'These Terms are governed by the laws of [JURISDICTION], without giving effect to any principles of conflicts of law.\n\n' ||
    E'### 13.2 Jurisdiction\n\n' ||
    E'Any dispute arising from these Terms shall be subject to the exclusive jurisdiction of the courts of [JURISDICTION].\n\n' ||
    E'### 13.3 Dispute Resolution\n\n' ||
    E'**Informal Negotiation:**\n\n' ||
    E'If you have a dispute, first attempt to resolve it by contacting us at [SUPPORT_EMAIL]. We will attempt to resolve the dispute informally.\n\n' ||
    E'**Arbitration:**\n\n' ||
    E'If we cannot resolve the dispute informally within 60 days, any dispute shall be resolved through binding arbitration in accordance with [ARBITRATION_BODY] rules.\n\n' ||
    E'**Class Action Waiver:**\n\n' ||
    E'You agree that any dispute shall be resolved individually and not as part of a class or collective action.\n\n' ||
    E'### 13.4 EU Consumer Rights\n\n' ||
    E'If you reside in the European Union, nothing in these Terms affects your rights as a consumer under EU consumer protection laws.\n\n' ||
    E'## 14. Third-Party Services\n\n' ||
    E'### 14.1 Third-Party Integrations\n\n' ||
    E'The App may integrate with third-party services:\n\n' ||
    E'- **Supabase:** Database hosting and authentication\n' ||
    E'- **OneSignal:** Push notifications\n' ||
    E'- **Superwall:** Payment processing\n' ||
    E'- **Sentry:** Error monitoring\n\n' ||
    E'### 14.2 Third-Party Terms\n\n' ||
    E'Use of third-party services is subject to their own terms and conditions. We are not responsible for the actions or omissions of third-party providers.\n\n' ||
    E'### 14.3 App Stores\n\n' ||
    E'If you download the App from Apple App Store or Google Play Store, you are also subject to their terms of service.\n\n' ||
    E'## 15. General Provisions\n\n' ||
    E'### 15.1 Entire Agreement\n\n' ||
    E'These Terms, together with our Privacy Policy, constitute the entire agreement between you and [COMPANY_NAME] regarding use of the App.\n\n' ||
    E'### 15.2 Severability\n\n' ||
    E'If any provision of these Terms is found invalid or unenforceable, the remaining provisions shall remain in full force and effect.\n\n' ||
    E'### 15.3 Waiver\n\n' ||
    E'Our failure to enforce any right or provision of these Terms shall not be deemed a waiver of such rights.\n\n' ||
    E'### 15.4 Assignment\n\n' ||
    E'You may not transfer or assign your rights or obligations under these Terms without our prior written consent. We may assign these Terms without restriction.\n\n' ||
    E'### 15.5 Notices\n\n' ||
    E'All notices under these Terms shall be sent by email to the address associated with your account or via in-App notification.\n\n' ||
    E'### 15.6 Force Majeure\n\n' ||
    E'We shall not be liable for any delay or failure to perform our obligations due to causes beyond our reasonable control.\n\n' ||
    E'## 16. Contact\n\n' ||
    E'For questions about these Terms, contact us:\n\n' ||
    E'- **Email:** [SUPPORT_EMAIL]\n' ||
    E'- **Privacy Email:** [PRIVACY_EMAIL]\n' ||
    E'- **Address:** [COMPANY_ADDRESS]\n' ||
    E'- **Website:** https://zendfast.app\n\n' ||
    E'---\n\n' ||
    E'**Last Updated:** November 8, 2025\n\n' ||
    E'**Version:** 1.0\n\n' ||
    E'By using Zendfast, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions of Use.',
    'en',
    '2025-11-08 00:00:00+00',
    TRUE
) ON CONFLICT (version, language) DO NOTHING;

-- ==============================================================================
-- SUCCESS MESSAGE
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Terms of Service inserted successfully:';
    RAISE NOTICE '   - Version: 1.0';
    RAISE NOTICE '   - Languages: Spanish (es) + English (en)';
    RAISE NOTICE '   - Effective date: 2025-11-08';
    RAISE NOTICE '   - Status: Active';
    RAISE NOTICE '';
    RAISE NOTICE '📄 ToS sections include:';
    RAISE NOTICE '   - Medical disclaimers and health warnings';
    RAISE NOTICE '   - Subscription terms (billing, cancellation, refunds)';
    RAISE NOTICE '   - User responsibilities and prohibited conduct';
    RAISE NOTICE '   - Limitation of liability and indemnification';
    RAISE NOTICE '   - Dispute resolution and arbitration';
    RAISE NOTICE '   - GDPR/CCPA compliance references';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Next steps:';
    RAISE NOTICE '   1. Review ToS content with legal team';
    RAISE NOTICE '   2. Update placeholders: [COMPANY_NAME], [SUPPORT_EMAIL], etc.';
    RAISE NOTICE '   3. Create TermsOfServiceScreen in Flutter';
    RAISE NOTICE '   4. Implement legal acceptance flow in onboarding';
    RAISE NOTICE '   5. Test ToS screen and acceptance flow';
END $$;
