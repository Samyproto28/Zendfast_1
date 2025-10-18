  
\*\*Documento 3: Tech Stack Document \- Zendfast\*\*

1\. Información General del Stack

Aplicación: Zendfast    
Plataforma Objetivo: Móvil (iOS/Android)    
Arquitectura: Local-First con Sincronización Cloud    
Patrón de Desarrollo: Feature-First \+ Clean Architecture    
Filosofía UX/UI: Diseño minimalista con micro-interacciones de alta calidad  

2\. Especificaciones de Plataforma

2.1 Flutter Framework  
\`\`\`yaml  
Versión: Stable Channel (Última disponible)  
Plataformas Soportadas: iOS, Android  
Versiones Mínimas:  
  \- iOS: 13.0+  
  \- Android: 10.0 (API 29)+  
Web Support: No implementado en v1.0  
\`\`\`

2.2 Configuración de Desarrollo  
\`\`\`yaml  
IDE Principal: Cursor AI (optimizado para desarrollo con IA)  
Estructura: Feature-First Architecture  
Linting: flutter_lints + análisis estricto personalizado  
\`\`\`

3\. Backend y Servicios Cloud

3.1 Supabase Configuration  
\`\`\`yaml  
Servicios Utilizados:  
  \- Auth: Gestión completa de usuarios  
  \- Database: PostgreSQL con RLS obligatorio  
  \- Edge Functions: Lógica backend, notificaciones (OneSignal), analíticas y monitoreo (Sentry)  
Seguridad:  
  \- Row Level Security: MANDATORIO en todas las tablas de usuario  
  \- Políticas de acceso granular por usuario  
Storage: No implementado en v1.0  
\`\`\`

3.2 Configuración de Seguridad Supabase  
\`\`\`sql  
\-- Ejemplo de configuración RLS obligatoria  
ALTER TABLE user\_profiles ENABLE ROW LEVEL SECURITY;  
ALTER TABLE fasting\_sessions ENABLE ROW LEVEL SECURITY;  
ALTER TABLE hydration\_logs ENABLE ROW LEVEL SECURITY;  
ALTER TABLE user\_metrics ENABLE ROW LEVEL SECURITY;  
\`\`\`

4\. Monetización y Paywall

4.1 Superwall Integration  
\`\`\`yaml  
Modelo de Negocio: Freemium  
Suscripciones v1.0:  
  \- Mensual: $X.XX/mes  
  \- Anual: $XX.XX/año  
Futuras Versiones:  
  \- Semanal: Planificado post-lanzamiento  
A/B Testing: Activo para optimización de conversión  
Disponibilidad: Global (todos los países)  
\`\`\`

4.2 Configuración de Productos  
\`\`\`dart  
// Configuración de productos Superwall  
const subscriptionProducts \= {  
  'monthly\_premium': 'Acceso Premium Mensual',  
  'yearly\_premium': 'Acceso Premium Anual',  
};  
\`\`\`

5\. Gestión de Estado y Datos

5.1 State Management  
\`\`\`yaml  
Patrón Principal: Riverpod  
Justificación: Modernidad, escalabilidad y potencia  
Providers: StateNotifierProvider para lógica compleja  
Consumers: Consumer/ConsumerWidget para UI reactiva  
\`\`\`

5.2 Persistencia de Datos  
\`\`\`yaml  
Arquitectura: Local-First
Base de Datos Local: Isar v3 (versión 3.1.0, elegida por su soporte para consultas complejas, relaciones y rendimiento escalable en datasets grandes)
Sincronización:
  - Default: Solo WiFi
  - Opcional: Datos móviles (configuración usuario)
  - Datos sincronizados: Sesiones de ayuno, registros de hidratación y métricas de usuario con las tablas correspondientes en Supabase
  - Manejo de conflictos: Prioridad a datos locales con timestamp más reciente
Estrategia: Offline-first con sync inteligente
\`\`\`

5.3 Configuración de Sincronización  
\`\`\`dart  
// Configuración de sync inteligente  
class SyncConfig {  
  static const bool defaultWifiOnly \= true;  
  static const Duration syncInterval \= Duration(minutes: 15);  
  static const bool backgroundSync \= true;  
}  
\`\`\`

6\. Librerías y Dependencias Core

6.1 Dependencias Principales  
\`\`\`yaml  
dependencies:
  flutter: sdk: flutter
  
  State Management
  flutter_riverpod: latest
  
  Backend & Auth
  supabase_flutter: latest
  
  Paywall
  superwall_flutter: latest
  
  Local Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  Nota: Inicializar Isar con esquemas para FastingSession, HydrationLog y UserMetrics, usando path_provider para el directorio de almacenamiento.
  
  Notifications
  onesignal_flutter: latest
  
  Background Services
  flutter_background_service: latest
  
  Animations
  lottie: latest
  
  Analytics & Monitoring
  sentry_flutter: latest
  
  UI & Navigation
  go_router: latest
  flutter_hooks: latest
\`\`\`

6.2 Dependencias de Desarrollo  
\`\`\`yaml  
dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: latest
  build_runner: latest
  isar_generator: ^3.1.0
  riverpod_generator: latest
  custom_lint: latest
\`\`\`

7\. Servicios de Notificaciones

7.1 OneSignal Push Notifications  
\`\`\`yaml  
Implementación: OneSignal Push Notifications vía Supabase Edge Functions  
Justificación: Integración directa con Supabase, alta fiabilidad en iOS y Android  
Tipos de Notificaciones:  
  \- Inicio/Fin de ayuno  
  \- Recordatorios de hidratación  
  \- Motivación durante ayuno  
  \- Noticias educativas  
Background: Ejecución garantizada con flutter_background_service  
\`\`\`

7.2 Configuración de Notificaciones  
\`\`\`dart  
// Tipos de notificaciones push  
enum NotificationType {  
  fastingStart('fasting_start'),  
  fastingEnd('fasting_end'),  
  hydrationReminder('hydration_reminder'),  
  motivation('motivation'),  
  educational('educational');  
}  
\`\`\`

8\. Animaciones y UX

8.1 Sistema de Animaciones  
\`\`\`yaml  
Librería Principal: Lottie  
Uso Específico:  
  - Animación de respiración guiada (4-4-8)  
  - Micro-interacciones en botones  
  - Transiciones entre estados  
  - Feedback visual de progreso  
Filosofía: Animaciones sutiles y no intrusivas, priorizando la claridad y la respuesta inmediata al usuario. Las animaciones deben reforzar la experiencia, nunca distraer ni ralentizar la interacción.  
Guidelines:  
  - Usar animaciones para guiar la atención y dar feedback de acciones.
  - Micro-interacciones en botones y cambios de estado para reforzar la percepción de fluidez.
  - Evitar animaciones largas o bloqueantes.
  - Mantener la coherencia visual en transiciones y feedback.
  - Preferir animaciones nativas de Flutter y Lottie para rendimiento óptimo.
\`\`\`

8.2 Configuración de Animaciones  
\`\`\`dart  
// Configuración de respiración guiada  
class BreathingConfig {  
  static const Duration inhale \= Duration(seconds: 4);  
  static const Duration hold \= Duration(seconds: 4);  
  static const Duration exhale \= Duration(seconds: 8);  
}  
\`\`\`

9\. Servicios Externos e Integraciones

9.1 Content Management  
\`\`\`yaml  
Learning Content:  
  \- Videos: YouTube Player API / Enlaces directos  
  \- Artículos: Contenido web externo  
  \- Estudios: Enlaces a publicaciones científicas  
Cacheable: Solo metadatos, contenido siempre online  
\`\`\`

9.2 Analíticas y Monitoreo  
\`\`\`yaml  
Analíticas:  
  \- Supabase analytics_events:  
    \- Eventos de usuario críticos  
    \- Funnel de conversión  
    \- Retención y engagement  
Monitoreo de Errores:  
  \- Sentry: Integración vía Supabase Edge Functions para captura y reporte de errores  
\`\`\`

10\. Configuración de Build y Deployment

10.1 Flavors y Entornos  
\`\`\`yaml  
development:  
  \- Supabase: Proyecto de desarrollo/testing  
  \- Analytics: Separado de producción  
  \- Debug: Habilitado  
  \- Obfuscation: Deshabilitada

production:  
  \- Supabase: Proyecto de producción  
  \- Analytics: Producción real  
  \- Debug: Deshabilitado  
  \- Obfuscation: OBLIGATORIA  
\`\`\`

10.2 CI/CD Pipeline  
\`\`\`yaml  
Plataforma: Codemagic  
Justificación: Soporte nativo iOS desde Windows  
Automatización:  
  \- Build automático por flavor  
  \- Testing automatizado  
  \- Despliegue a stores  
  \- Generación de artifacts  
\`\`\`

10.3 Configuración de Build  
\`\`\`bash  
 Build de desarrollo  
flutter build apk \--flavor development \--debug

 Build de producción (con obfuscación obligatoria)  
flutter build apk \--flavor production \--release \--obfuscate \--split-debug-info=build/symbols  
flutter build ios \--flavor production \--release \--obfuscate \--split-debug-info=build/symbols  
\`\`\`

11\. Arquitectura de Carpetas

11.1 Estructura Feature-First  
\`\`\`  
lib/  
core/  
  constants/  
  themes/  
  utils/  
  services/  
features/  
  authentication/  
  fasting/  
  hydration/  
  learning/  
  metrics/  
  profile/  
shared/  
  widgets/  
  models/  
  providers/  
main.dart  
\`\`\`

11.2 Estructura por Feature  
\`\`\`  
features/fasting/  
data/  
  models/  
  repositories/  
  data\_sources/  
domain/  
  entities/  
  repositories/  
  use\_cases/  
presentation/  
  pages/  
  widgets/  
  providers/  
fasting\_feature.dart  
\`\`\`

12\. Configuración de Testing

12.1 Testing Strategy  
\`\`\`yaml  
Unit Tests: Lógica de negocio, providers y operaciones de Isar (lectura/escritura de sesiones de ayuno y hidratación)
Widget Tests: Componentes UI críticos
Integration Tests: Flujos principales de usuario, incluyendo sincronización de Isar con Supabase
Performance Tests: Validar tiempos de lectura/escritura de Isar para datasets grandes (ej. 1000 sesiones de ayuno)
Coverage Mínimo: 70% para features core 
\`\`\`

13\. Configuración de Linting

13.1 Analysis Options  
\`\`\`yaml  
 analysis\_options.yaml  
include: package:flutter\_lints/flutter.yaml

analyzer:  
  exclude:  
    \- /.g.dart  
    \- /.freezed.dart  
    
linter:  
  rules:  
     Reglas adicionales estrictas para Cursor AI  
    \- prefer\_const\_constructors  
    \- avoid\_print  
    \- prefer\_final\_locals  
    \- use\_key\_in\_widget\_constructors  
\`\`\`

14\. Configuración Cursor AI Específica

14.1 .cursorrules Configuration  
\`\`\`  
 Reglas específicas para Zendfast  
\- Utilizar Riverpod para todo el state management  
\- Seguir arquitectura feature-first estrictamente  
\- Implementar RLS en todas las queries de Supabase  
\- Usar const constructors siempre que sea posible  
\- Documentar todas las funciones públicas  
\- Implementar error handling robusto  
\- Seguir principios de local-first architecture

