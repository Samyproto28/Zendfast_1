# OneSignal Push Notifications - Setup Guide

## 📋 Estado Actual

✅ **Código Implementado**: Toda la integración de OneSignal está completa y lista para usar.

⏳ **Configuración Externa**: Requiere configurar Firebase (Android) y Apple Developer (iOS).

💡 **Fallback Disponible**: Las notificaciones locales funcionan AHORA sin configuración externa.

---

## 🎯 Resumen

Esta app tiene **DOS sistemas de notificaciones**:

### 1. **Notificaciones Locales** (✅ YA FUNCIONAN)
- No requieren internet
- No requieren Firebase ni Apple Developer
- Perfectas para recordatorios de ayuno e hidratación
- **Limitación**: Solo funcionan cuando la app está instalada

### 2. **Push Notifications con OneSignal** (⏳ REQUIERE CONFIGURACIÓN)
- Notificaciones remotas desde servidor
- Segmentación de usuarios
- Analytics de apertura
- Deep linking avanzado
- **Requiere**: Firebase (Android) + Apple Developer (iOS)

---

## 🚀 Activación Rápida (30 minutos)

### Prerequis

itos
- [ ] Cuenta de Firebase (https://console.firebase.google.com/) - **GRATIS**
- [ ] Apple Developer Account ($99/año) - **SOLO PARA iOS**
- [ ] Acceso al dashboard de OneSignal (ya configurado)

---

## 📱 PARTE 1: Configuración de Android (Firebase)

### Paso 1: Crear Proyecto en Firebase (5 min)

1. Ve a https://console.firebase.google.com/
2. Click en "Agregar proyecto"
3. Nombre del proyecto: **ZendFast** (o el que prefieras)
4. **IMPORTANTE**: Desactiva Google Analytics si no lo necesitas (más rápido)
5. Click en "Crear proyecto"

### Paso 2: Agregar App Android (3 min)

1. En el proyecto de Firebase, click en **Android icon** (⚙️)
2. Configurar:
   - **Nombre del paquete de Android**: `com.zendfast.app`
   - **Alias de la app**: ZendFast (opcional)
   - **Certificado SHA-1**: Dejar en blanco por ahora (opcional)
3. Click en "Registrar app"

### Paso 3: Descargar google-services.json (2 min)

1. Descarga el archivo `google-services.json`
2. **IMPORTANTE**: Colócalo en `android/app/google-services.json`
   ```bash
   # Desde la raíz del proyecto:
   mv ~/Downloads/google-services.json android/app/
   ```
3. Verifica que el archivo esté en el lugar correcto:
   ```
   zendfast_1/
   └── android/
       └── app/
           └── google-services.json  ← AQUÍ
   ```

### Paso 4: Obtener Server Key de Firebase (3 min)

1. En Firebase Console, ve a **Project Settings** (⚙️ arriba izquierda)
2. Pestaña **Cloud Messaging**
3. En "Cloud Messaging API (Legacy)", click en **⋮** > **Manage API in Google Cloud Console**
4. Habilita "Cloud Messaging API" si está deshabilitada
5. Vuelve a Firebase > Cloud Messaging
6. Copia el **Server Key** (empieza con `AAAA...`)

### Paso 5: Configurar Server Key en OneSignal (2 min)

1. Ve a tu dashboard de OneSignal: https://onesignal.com/
2. Selecciona tu app: **mandible** (App ID: `40e6b7f3-f221-4e13-8961-31d872603dca`)
3. Ve a **Settings** > **Platforms** > **Google Android (FCM)**
4. Pega el **Server Key** en el campo "Firebase Server Key"
5. Click en "Save"

✅ **Android configurado!** Las push notifications ahora funcionarán en Android.

---

## 🍎 PARTE 2: Configuración de iOS (Apple Developer)

### Prerequisitos iOS
- [ ] Apple Developer Account activa ($99/año)
- [ ] Acceso a developer.apple.com
- [ ] Conocimiento básico de Xcode

### Paso 1: Crear App ID en Apple Developer (5 min)

1. Ve a https://developer.apple.com/account/resources/identifiers/list
2. Click en **+** para crear nuevo App ID
3. Selecciona **App IDs** > **Continue**
4. Configurar:
   - **Description**: ZendFast
   - **Bundle ID**: `com.zendfast.app` (debe coincidir exactamente)
   - **Capabilities**: Marca **Push Notifications**
5. Click en "Continue" > "Register"

### Paso 2: Generar APNs Auth Key (5 min)

1. Ve a https://developer.apple.com/account/resources/authkeys/list
2. Click en **+** para crear nueva key
3. Configurar:
   - **Key Name**: ZendFast Push Notifications
   - Marca **Apple Push Notifications service (APNs)**
4. Click en "Continue" > "Register"
5. **IMPORTANTE**: Descarga el archivo `.p8` (solo se puede descargar UNA VEZ)
6. Anota el **Key ID** (ejemplo: `AB12CD34EF`)
7. Anota el **Team ID** (en la esquina superior derecha, ejemplo: `XYZ1234ABC`)

### Paso 3: Configurar APNs en OneSignal (3 min)

1. Ve a OneSignal Dashboard > **Settings** > **Platforms** > **Apple iOS (APNs)**
2. Selecciona método de autenticación: **Token Authentication** (.p8)
3. Configura:
   - **Key ID**: El que anotaste (ejemplo: `AB12CD34EF`)
   - **Team ID**: El que anotaste (ejemplo: `XYZ1234ABC`)
   - **Bundle ID**: `com.zendfast.app`
   - **Upload .p8 file**: Sube el archivo descargado
4. **Sandbox Mode**: Activa para testing, desactiva para producción
5. Click en "Save"

### Paso 4: Configurar en Xcode (5 min)

**Nota**: Esto requiere macOS y Xcode.

1. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Selecciona el target **Runner** en el navegador izquierdo
3. Pestaña **Signing & Capabilities**
4. Click en **+ Capability** > Agregar **Push Notifications**
5. Click en **+ Capability** > Agregar **Background Modes**
   - Marca **Remote notifications**
6. Verifica que **Automatically manage signing** esté activado
7. Selecciona tu Team de desarrollo

✅ **iOS configurado!** Las push notifications ahora funcionarán en iOS.

---

## 🔧 PARTE 3: Activar en el Código (2 minutos)

### Paso 1: Descomentar Google Services en Gradle

Edita `android/build.gradle.kts`:
```kotlin
dependencies {
    // Uncomment when google-services.json is added
    classpath("com.google.gms:google-services:4.4.0")  // ← QUITAR "//"
}
```

Edita `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← DESCOMENTAR ESTA LÍNEA
}
```

### Paso 2: Regenerar Código

```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Regenerar archivos Isar (incluye PushNotification model)
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar que compila
flutter build apk --debug   # Para Android
flutter build ios --debug   # Para iOS (requiere Mac)
```

### Paso 3: Probar en Dispositivo Real

```bash
# Android
flutter run

# iOS
flutter run -d <device_id>
```

**IMPORTANTE**: Las push notifications NO funcionan en simuladores, solo en dispositivos reales.

---

## ✅ Verificación de Funcionamiento

### Test 1: Notificación de Prueba desde OneSignal

1. Ve a OneSignal Dashboard > **Messages** > **New Push**
2. Configurar:
   - **Audience**: Send to all users
   - **Message**: "🎉 Test notification from OneSignal!"
   - **Launch URL**: `zendfast://home`
3. Click en **Send Message**
4. Verifica que la notificación llegue al dispositivo
5. Toca la notificación y verifica que abre la app en home

### Test 2: Notificación Local (No requiere OneSignal)

Desde el código, puedes probar las notificaciones locales:

```dart
import 'package:zendfast_1/services/local_notification_service.dart';

// Mostrar notificación inmediata
await LocalNotificationService.instance.showNotification(
  id: 1,
  title: '💧 Stay Hydrated!',
  body: 'Time to drink water!',
  payload: 'hydration',
);

// Programar para el futuro
await LocalNotificationService.instance.scheduleFastingMilestone(
  time: DateTime.now().add(Duration(hours: 4)),
  hours: 4,
  targetHours: 16,
);
```

---

## 🐛 Troubleshooting

### Android: Notificaciones no llegan

**Problema**: Configuración incorrecta de Firebase

1. Verifica que `google-services.json` está en `android/app/`
2. Verifica que el **package name** en Firebase sea exactamente `com.zendfast.app`
3. Verifica que el **Server Key** en OneSignal sea correcto
4. Ejecuta `flutter clean && flutter pub get`

**Problema**: Build falla con error de Google Services

1. Asegúrate de haber descomentado las líneas en `build.gradle.kts`
2. Verifica que el archivo `google-services.json` sea válido (abre y verifica JSON)
3. Intenta: `cd android && ./gradlew clean`

### iOS: No recibo notificaciones

**Problema**: Certificado APNs no configurado

1. Verifica que descargaste el archivo `.p8` correctamente
2. Verifica que el **Key ID** y **Team ID** sean correctos en OneSignal
3. Verifica que **Push Notifications** esté habilitado en Xcode Capabilities

**Problema**: "Push Notifications entitlement not found"

1. Abre el proyecto en Xcode
2. Ve a **Signing & Capabilities**
3. Agrega **Push Notifications** capability manualmente
4. Clean build: `Product` > `Clean Build Folder` (Cmd+Shift+K)

### Ambas Plataformas: No veo notificaciones

**Problema**: Permisos no otorgados

1. Verifica permisos en Settings del dispositivo:
   - Android: Settings > Apps > ZendFast > Notifications
   - iOS: Settings > ZendFast > Notifications
2. Solicita permisos desde el código:
   ```dart
   await OneSignalService.instance.requestPermission();
   ```

**Problema**: App en primer plano

- Por defecto, las notificaciones se muestran en background
- En foreground, OneSignal llama a `notificationStream` pero no muestra nada
- Esto es configurable en `OneSignalService`

---

## 📊 Uso Básico del Sistema

### Desde el Código: Enviar Notificación con Template

```dart
import 'package:zendfast_1/services/onesignal_service.dart';

// Template de inicio de ayuno
final template = OneSignalService.instance.fastingStartTemplate(
  fastingPlan: '16:8',
  targetHours: 16,
);

// Template de hito
final template = OneSignalService.instance.fastingMilestoneTemplate(
  hours: 8,
  targetHours: 16,
);

// Template de hidratación
final template = OneSignalService.instance.hydrationReminderTemplate(
  glassesConsumed: 3,
  targetGlasses: 8,
);
```

### Desde OneSignal Dashboard: Enviar a Segmentos

1. Dashboard > **Audience** > **Segments** > **New Segment**
2. Crear segmento basado en tags:
   - Users where `fasting_plan` equals `16:8`
   - Users where `experience_level` equals `beginner`
3. Dashboard > **Messages** > **New Push**
4. Seleccionar segmento creado
5. Configurar mensaje y enviar

### Configurar Tags de Usuario

```dart
import 'package:zendfast_1/services/onesignal_service.dart';

// Al iniciar sesión o completar onboarding
await OneSignalService.instance.setExternalUserId(user.id);

await OneSignalService.instance.setUserTags({
  'fasting_plan': '16:8',
  'experience_level': 'beginner',
  'timezone': 'America/New_York',
  'preferred_language': 'en',
  'notification_frequency': 'high',
});

// Al cerrar sesión
await OneSignalService.instance.removeExternalUserId();
```

---

## 🔒 Seguridad y Best Practices

### Variables de Entorno

**NUNCA** subas a git:
- `google-services.json` (Android)
- Archivos `.p8` (iOS)

Están en `.gitignore` por defecto.

### API Keys

Las API keys de OneSignal están en `.env`:
```env
ONESIGNAL_APP_ID=40e6b7f3-f221-4e13-8961-31d872603dca
ONESIGNAL_REST_API_KEY=os_v2_app_...
```

Asegúrate de que `.env` esté en `.gitignore`.

### Producción vs Desarrollo

Para producción:
1. Usa **Production** mode en Apple certificates (no Sandbox)
2. Usa **Release** builds, no debug
3. Verifica que los certificados no estén expirados

---

## 📚 Recursos Adicionales

- [OneSignal Docs](https://documentation.onesignal.com/)
- [Firebase Console](https://console.firebase.google.com/)
- [Apple Developer](https://developer.apple.com/)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## ✨ Próximos Pasos

Una vez configurado:

1. **Integrar con TimerService**: Programar notificaciones automáticas durante ayuno
2. **Integrar con AuthService**: Setear tags de usuario al login
3. **Crear NotificationCenterScreen**: Pantalla para ver historial de notificaciones
4. **Analytics**: Usar OneSignal analytics para medir engagement
5. **A/B Testing**: Probar diferentes mensajes de notificación

---

**¿Preguntas?** Revisa la sección de Troubleshooting o consulta los logs de la app con `flutter logs`.
