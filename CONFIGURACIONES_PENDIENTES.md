# 🔧 Configuraciones Pendientes - Zendfast

> **Última actualización:** 2025-11-09
> **Estado del proyecto:** En desarrollo - Configuraciones externas requeridas antes de producción

---

## 📊 Resumen Ejecutivo

Este documento detalla **todas las configuraciones externas** que quedaron pendientes durante el desarrollo de la aplicación Zendfast. Estas configuraciones son necesarias para habilitar funcionalidades completas o para deployment a producción.

### Prioridades:
- 🔴 **CRÍTICAS:** Bloquean el launch a producción
- 🟡 **IMPORTANTES:** Mejoran la experiencia del usuario
- 🟢 **OPCIONALES:** Nice to have

---

## 🔴 CRÍTICO 1: OneSignal + Firebase + Apple Developer

**Tarea:** #5 - Configurar OneSignal para notificaciones push
**Estado:** ✅ Código implementado | ❌ Configuración externa pendiente
**Tiempo estimado:** ~45 minutos
**Bloqueante para:** Notificaciones push en producción

### ✅ Estado Actual

- [x] OneSignalService completamente implementado
- [x] LocalNotificationService como fallback funcional (NO requiere configuración)
- [x] Templates de notificaciones listos
- [x] Deep linking integrado
- [x] Sistema dual funcional

### ❌ Configuraciones Pendientes

#### 1.1 Firebase Configuration (Android)

**Necesitas crear:**

1. **Proyecto Firebase para Producción**
   - Nombre: `Zendfast`
   - Package name: `com.zendfast.app`
   - Descargar: `google-services.json`
   - Ubicación: `android/app/src/production/`

2. **Proyecto Firebase para Development**
   - Nombre: `Zendfast Dev`
   - Package name: `com.zendfast.app.dev`
   - Descargar: `google-services.json`
   - Ubicación: `android/app/src/development/`

**Pasos:**
```bash
# 1. Ir a https://console.firebase.google.com
# 2. Crear nuevo proyecto "Zendfast"
# 3. Agregar app Android con package name: com.zendfast.app
# 4. Descargar google-services.json
# 5. Colocar en: android/app/src/production/google-services.json

# 6. Repetir para proyecto "Zendfast Dev" con package: com.zendfast.app.dev
# 7. Colocar en: android/app/src/development/google-services.json
```

#### 1.2 Apple Push Notification Service (APNs)

**Necesitas generar:**

1. **APNs Authentication Key** (Recomendado)
   - Ir a: https://developer.apple.com/account/resources/authkeys/list
   - Crear nueva key con capability "Apple Push Notifications service (APNs)"
   - Descargar archivo `.p8`
   - **GUARDAR:** Key ID y Team ID

   **O alternativamente:**

2. **APNs Certificate** (Legacy)
   - Ir a: https://developer.apple.com/account/resources/certificates/list
   - Crear "Apple Push Notification service SSL"
   - Descargar certificado `.cer`
   - Convertir a `.p12` usando Keychain Access

**Para ambos App IDs:**
- `com.zendfast.app` (Production)
- `com.zendfast.app.dev` (Development)

#### 1.3 OneSignal Dashboard Configuration

**Necesitas crear 2 apps en OneSignal:**

1. **Zendfast (Production)**
   ```bash
   # 1. Ir a https://app.onesignal.com
   # 2. Create New App/Website
   # 3. Nombre: "Zendfast"
   # 4. Plataforma: Android + iOS

   # Android:
   # - Subir google-services.json de producción
   # - Firebase Server Key (obtener de Firebase Project Settings)

   # iOS:
   # - Subir APNs .p8 key O .p12 certificate
   # - Ingresar Team ID y Key ID (si usas .p8)

   # 5. Copiar OneSignal App ID
   ```

2. **Zendfast Dev (Development)**
   ```bash
   # Repetir proceso anterior pero con:
   # - google-services.json de development
   # - APNs certificate/key para bundle ID: com.zendfast.app.dev
   ```

#### 1.4 Actualizar Variables de Entorno

**Archivo:** `.env.development`
```env
ONESIGNAL_APP_ID=<ONESIGNAL_DEV_APP_ID_AQUI>
```

**Archivo:** `.env.production`
```env
ONESIGNAL_APP_ID=<ONESIGNAL_PROD_APP_ID_AQUI>
```

### 📝 Checklist de OneSignal

```markdown
- [ ] Crear proyecto Firebase "Zendfast" (producción)
- [ ] Crear proyecto Firebase "Zendfast Dev" (development)
- [ ] Descargar google-services.json para ambos
- [ ] Colocar archivos en carpetas correctas de Android
- [ ] Generar APNs Authentication Key en Apple Developer
- [ ] Guardar Key ID y Team ID de Apple
- [ ] Crear app "Zendfast" en OneSignal dashboard
- [ ] Configurar Android (Firebase) en OneSignal prod
- [ ] Configurar iOS (APNs) en OneSignal prod
- [ ] Copiar OneSignal App ID de producción
- [ ] Crear app "Zendfast Dev" en OneSignal dashboard
- [ ] Configurar Android (Firebase) en OneSignal dev
- [ ] Configurar iOS (APNs) en OneSignal dev
- [ ] Copiar OneSignal App ID de development
- [ ] Actualizar ONESIGNAL_APP_ID en .env.development
- [ ] Actualizar ONESIGNAL_APP_ID en .env.production
- [ ] Probar notificación push en device físico (dev)
- [ ] Probar notificación push en device físico (prod)
```

---

## 🔴 CRÍTICO 2: iOS Flavors - Configuración Manual en Xcode

**Tarea:** #40 - Configurar flavors de Flutter (development/production)
**Estado:** ✅ Android completo | ❌ iOS requiere setup manual
**Tiempo estimado:** ~45 minutos
**Bloqueante para:** Builds de iOS separados por environment

### ✅ Estado Actual

- [x] Android flavors completamente configurados
- [x] Scripts de build configurados
- [x] Documentación creada en `docs/FLAVORS.md`
- [x] Variables de entorno por flavor

### ❌ Configuraciones Pendientes en Xcode

⚠️ **IMPORTANTE:** iOS requiere configuración manual que NO puede automatizarse desde Flutter

#### 2.1 Build Configurations en Xcode

**Archivo de referencia:** `docs/FLAVORS.md`

**Pasos detallados:**

```bash
# 1. Abrir proyecto en Xcode
open ios/Runner.xcworkspace

# 2. En Xcode Navigator, seleccionar proyecto "Runner"
# 3. En la sección "Info" del proyecto, ver "Configurations"
# 4. Duplicar configuraciones existentes:
```

**Crear estas 4 configuraciones:**

| Original | Nueva Configuración |
|----------|---------------------|
| Debug | Development-Debug |
| Release | Development-Release |
| Debug | Production-Debug |
| Release | Production-Release |

**Cómo duplicar:**
1. Click en `+` debajo de la lista de configurations
2. Seleccionar "Duplicate 'Debug' Configuration"
3. Renombrar a "Development-Debug"
4. Repetir para las otras 3

#### 2.2 Schemes en Xcode

**Crear 2 schemes:**

1. **Development Scheme**
   ```
   - En menu: Product → Scheme → Manage Schemes
   - Duplicar scheme "Runner"
   - Renombrar a "Development"
   - Editar scheme:
     - Build Configuration (Run): Development-Debug
     - Build Configuration (Profile): Development-Release
     - Build Configuration (Archive): Development-Release
   ```

2. **Production Scheme**
   ```
   - Duplicar scheme "Runner" nuevamente
   - Renombrar a "Production"
   - Editar scheme:
     - Build Configuration (Run): Production-Debug
     - Build Configuration (Profile): Production-Release
     - Build Configuration (Archive): Production-Release
   ```

#### 2.3 Bundle Identifiers por Configuration

**En Build Settings del target Runner:**

1. Buscar "Product Bundle Identifier"
2. Expandir la flecha
3. Configurar para cada build configuration:

```
Development-Debug:   com.zendfast.app.dev
Development-Release: com.zendfast.app.dev
Production-Debug:    com.zendfast.app
Production-Release:  com.zendfast.app
```

#### 2.4 Provisioning Profiles (Apple Developer Portal)

**Necesitas crear en https://developer.apple.com:**

1. **App ID para Development**
   - Identifier: `com.zendfast.app.dev`
   - Name: "Zendfast Dev"
   - Capabilities: Push Notifications, Associated Domains

2. **App ID para Production**
   - Identifier: `com.zendfast.app`
   - Name: "Zendfast"
   - Capabilities: Push Notifications, Associated Domains

3. **Provisioning Profiles:**
   - Development profile para `com.zendfast.app.dev`
   - Development profile para `com.zendfast.app`
   - Distribution profile para `com.zendfast.app`

#### 2.5 Signing en Xcode

**Para cada Build Configuration:**

```
Development-Debug:
  - Signing Team: [Tu equipo]
  - Provisioning Profile: [Dev profile para .dev]
  - Bundle ID: com.zendfast.app.dev

Development-Release:
  - Signing Team: [Tu equipo]
  - Provisioning Profile: [Dev profile para .dev]
  - Bundle ID: com.zendfast.app.dev

Production-Debug:
  - Signing Team: [Tu equipo]
  - Provisioning Profile: [Dev profile para .app]
  - Bundle ID: com.zendfast.app

Production-Release:
  - Signing Team: [Tu equipo]
  - Provisioning Profile: [Distribution profile]
  - Bundle ID: com.zendfast.app
```

### 📝 Checklist de iOS Flavors

```markdown
- [ ] Abrir proyecto en Xcode
- [ ] Crear 4 Build Configurations
  - [ ] Development-Debug
  - [ ] Development-Release
  - [ ] Production-Debug
  - [ ] Production-Release
- [ ] Crear 2 Schemes
  - [ ] Development (apunta a Development configs)
  - [ ] Production (apunta a Production configs)
- [ ] Configurar Bundle IDs por configuration
- [ ] Crear App ID com.zendfast.app.dev en Apple Developer
- [ ] Crear App ID com.zendfast.app en Apple Developer
- [ ] Habilitar Push Notifications capability
- [ ] Habilitar Associated Domains capability
- [ ] Crear Development Provisioning Profile (.dev)
- [ ] Crear Development Provisioning Profile (.app)
- [ ] Crear Distribution Provisioning Profile (.app)
- [ ] Configurar Signing & Capabilities en Xcode
- [ ] Verificar build de Development en simulador
- [ ] Verificar build de Production en simulador
- [ ] Verificar build de Development en device físico
- [ ] Verificar build de Production en device físico
```

---

## 🔴 CRÍTICO 3: Dominio y Deep Linking

**Tarea:** #56 - Configurar go_router con deep linking completo
**Estado:** ✅ Código implementado | ❌ Dominio y certificados pendientes
**Tiempo estimado:** 1-2 horas
**Bloqueante para:** Universal Links (iOS) y App Links (Android)

### ✅ Estado Actual

- [x] go_router configurado con todas las rutas
- [x] Archivos `.well-known` creados con placeholders
- [x] Deep linking desde OneSignal implementado
- [x] Código listo para producción

### ❌ Configuraciones Pendientes

#### 3.1 Dominio zendfast.app

**Necesitas:**

1. **Registrar dominio** (si no está registrado)
   - Dominio: `zendfast.app`
   - Registrar en: Namecheap, Google Domains, Cloudflare, etc.

2. **Configurar DNS**
   ```
   Tipo: A
   Host: @
   Value: [IP de tu servidor web]
   TTL: 3600

   Tipo: A
   Host: www
   Value: [IP de tu servidor web]
   TTL: 3600
   ```

3. **Configurar SSL/TLS Certificate**
   - Usar Let's Encrypt (gratis)
   - O certificado del provider de hosting
   - **REQUERIDO:** HTTPS para Universal Links y App Links

#### 3.2 Apple Developer Team ID

**Archivo que necesita actualización:**
`.well-known/apple-app-site-association`

**Valor actual (placeholder):**
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["TEAM_ID.com.zendfast.app"]
    }]
  }
}
```

**Cómo obtener tu Team ID:**
```bash
# Opción 1: Apple Developer Portal
# 1. Ir a https://developer.apple.com/account
# 2. En la esquina superior derecha, ver tu Team ID (10 caracteres)

# Opción 2: Desde Xcode
# 1. Abrir proyecto en Xcode
# 2. Seleccionar target Runner
# 3. Ir a "Signing & Capabilities"
# 4. Ver "Team" - el ID está entre paréntesis

# Ejemplo: ABC123XYZ (sería ABC123XYZ)
```

**Actualización requerida:**
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["ABC123XYZ.com.zendfast.app"],  // ← Reemplazar con tu Team ID real
      "components": [
        {"/": "/fasting/*"},
        {"/": "/panic"},
        {"/": "/learning/*"},
        {"/": "/profile"}
      ]
    }]
  }
}
```

#### 3.3 Android SHA-256 Fingerprints

**Archivo que necesita actualización:**
`.well-known/assetlinks.json`

**Valores actuales (placeholders):**
```json
{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.zendfast.app",
    "sha256_cert_fingerprints": [
      "REPLACE_WITH_YOUR_RELEASE_KEY_SHA256_FINGERPRINT",
      "REPLACE_WITH_YOUR_DEBUG_KEY_SHA256_FINGERPRINT"
    ]
  }
}
```

**Cómo obtener los fingerprints:**

1. **Debug Key Fingerprint** (para testing)
   ```bash
   # En Linux/Mac
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # En Windows
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

   # Buscar línea: SHA256: XX:XX:XX:...
   # Copiar el hash SIN los dos puntos (:)
   ```

2. **Release Key Fingerprint** (CRÍTICO para producción)

   ⚠️ **PRIMERO necesitas crear el release keystore:**

   ```bash
   # Crear release keystore
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload

   # Te pedirá:
   # - Password (GUARDAR EN LUGAR SEGURO)
   # - Información de la organización

   # Obtener fingerprint
   keytool -list -v -keystore android/app/upload-keystore.jks -alias upload

   # Copiar SHA256 fingerprint
   ```

3. **Configurar keystore en el proyecto:**

   Crear archivo `android/key.properties`:
   ```properties
   storePassword=<password-del-keystore>
   keyPassword=<password-de-la-key>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

**Actualización del archivo `assetlinks.json`:**
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.zendfast.app",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99",  // ← Release fingerprint
        "11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00"   // ← Debug fingerprint
      ]
    }
  },
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.zendfast.app.dev",
      "sha256_cert_fingerprints": [
        "11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00"   // ← Debug fingerprint
      ]
    }
  }
]
```

#### 3.4 Hosting de Archivos .well-known

**Archivos a hostear:**

```
https://zendfast.app/.well-known/apple-app-site-association
https://zendfast.app/.well-known/assetlinks.json
```

**Configuración del servidor web:**

```nginx
# Nginx ejemplo
server {
    listen 443 ssl;
    server_name zendfast.app;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location /.well-known/apple-app-site-association {
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        alias /var/www/zendfast/.well-known/apple-app-site-association;
    }

    location /.well-known/assetlinks.json {
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        alias /var/www/zendfast/.well-known/assetlinks.json;
    }
}
```

**Verificación:**
```bash
# Apple
curl -v https://zendfast.app/.well-known/apple-app-site-association

# Android
curl -v https://zendfast.app/.well-known/assetlinks.json

# Ambos deben retornar 200 OK y contenido JSON válido
```

#### 3.5 Associated Domains en Xcode

**Configuración en Xcode:**

1. Seleccionar target "Runner"
2. Ir a "Signing & Capabilities"
3. Click en "+ Capability"
4. Agregar "Associated Domains"
5. Agregar dominio:
   ```
   applinks:zendfast.app
   ```

#### 3.6 Verificación de App Links en Google Play Console

**Después de subir APK/AAB a Google Play:**

1. Ir a Google Play Console
2. Setup → App Integrity
3. App signing → Ver certificado SHA-256
4. **Verificar que coincida** con el fingerprint en `assetlinks.json`

### 📝 Checklist de Deep Linking

```markdown
**Dominio:**
- [ ] Registrar dominio zendfast.app
- [ ] Configurar DNS apuntando a servidor web
- [ ] Configurar SSL/TLS certificate (HTTPS requerido)
- [ ] Verificar dominio accesible vía HTTPS

**Apple Universal Links:**
- [ ] Obtener Apple Developer Team ID
- [ ] Actualizar apple-app-site-association con Team ID real
- [ ] Subir archivo a https://zendfast.app/.well-known/
- [ ] Verificar archivo accesible (curl)
- [ ] Agregar Associated Domains capability en Xcode
- [ ] Probar Universal Link en device físico

**Android App Links:**
- [ ] Generar Android release keystore
- [ ] Guardar passwords en lugar seguro
- [ ] Configurar android/key.properties
- [ ] Obtener SHA-256 fingerprint de release key
- [ ] Obtener SHA-256 fingerprint de debug key
- [ ] Actualizar assetlinks.json con fingerprints reales
- [ ] Subir archivo a https://zendfast.app/.well-known/
- [ ] Verificar archivo accesible (curl)
- [ ] Subir APK a Google Play Console
- [ ] Verificar fingerprint en App Integrity
- [ ] Probar App Link en device físico
```

---

## 🟡 IMPORTANTE: Landing Pages Web

**Tarea:** #45 - Crear documentación legal (Privacy Policy y Terms of Service)
**Estado:** ✅ In-app completo | ❌ Hosting web pendiente
**Tiempo estimado:** ~1 hora
**Bloqueante para:** Submission a App Stores (URLs públicas requeridas)

### ✅ Estado Actual

- [x] Privacy Policy completo (bilingüe es/en)
- [x] Terms of Service completo (bilingüe es/en)
- [x] Documentos almacenados en Supabase
- [x] Pantallas funcionales en la app
- [x] Acceptance flow en onboarding implementado

### ❌ Configuraciones Pendientes

#### 4.1 URLs Públicas Requeridas

**Apple App Store y Google Play Store REQUIEREN:**

```
Privacy Policy URL: https://zendfast.app/privacy
Terms of Service URL: https://zendfast.app/terms
```

⚠️ **IMPORTANTE:** Estas URLs deben ser **públicamente accesibles** antes de submission.

#### 4.2 Opciones de Hosting

**Opción 1: Landing Pages Estáticas (Recomendado - Simple)**

Crear archivos HTML básicos:

```html
<!-- privacy.html -->
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de Privacidad - Zendfast</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 { color: #069494; }
        /* Más estilos... */
    </style>
</head>
<body>
    <!-- Contenido del Privacy Policy desde Supabase -->
</body>
</html>
```

**Hostear en:**
- Netlify (gratis, SSL automático)
- Vercel (gratis, SSL automático)
- GitHub Pages (gratis, SSL automático)
- Tu propio servidor web

**Opción 2: Fetch Dinámico desde Supabase**

Crear páginas que fetch el contenido desde Supabase:

```javascript
// Fetch y mostrar privacy policy dinámicamente
fetch('https://your-supabase-url/rest/v1/legal_documents?type=eq.privacy_policy')
  .then(res => res.json())
  .then(data => {
    document.getElementById('content').innerHTML = data[0].content_es;
  });
```

**Opción 3: Subdominio en Supabase Edge Functions**

Si prefieres mantener todo en Supabase.

#### 4.3 Estructura Mínima Requerida

```
web/
├── index.html          # Landing page (opcional)
├── privacy.html        # REQUERIDO
├── terms.html          # REQUERIDO
└── css/
    └── style.css
```

### 📝 Checklist de Landing Pages

```markdown
- [ ] Decidir opción de hosting (Netlify/Vercel/GitHub Pages)
- [ ] Crear privacy.html con contenido del Privacy Policy
- [ ] Crear terms.html con contenido de Terms of Service
- [ ] Agregar estilos responsive
- [ ] Implementar toggle de idioma (es/en)
- [ ] Configurar dominio zendfast.app
- [ ] Apuntar DNS a hosting elegido
- [ ] Configurar SSL (automático en Netlify/Vercel)
- [ ] Verificar https://zendfast.app/privacy accesible
- [ ] Verificar https://zendfast.app/terms accesible
- [ ] Probar responsive en mobile
- [ ] Agregar URLs a App Store Connect
- [ ] Agregar URLs a Google Play Console
```

---

## 🟡 IMPORTANTE: Configuración de Email

**Contexto:** Varias funcionalidades requieren envío de emails
**Estado:** ⚠️ Usando templates default de Supabase
**Tiempo estimado:** 30 minutos
**Bloqueante para:** Mejor experiencia de autenticación

### ❌ Configuraciones Pendientes

#### 5.1 Supabase Auth Email Templates

**Configuración actual:** Templates default de Supabase

**Personalización recomendada:**

1. **Ir a Supabase Dashboard:**
   - Project Settings → Authentication → Email Templates

2. **Personalizar templates:**
   - Confirm signup
   - Magic Link
   - Change Email Address
   - Reset Password

3. **Elementos a personalizar:**
   ```html
   <!-- Logo -->
   <img src="https://zendfast.app/logo.png" alt="Zendfast" />

   <!-- Colores brand -->
   <style>
     .button {
       background-color: #069494; /* Teal principal */
     }
   </style>

   <!-- Sender name -->
   From: Zendfast <noreply@zendfast.app>

   <!-- Footer personalizado -->
   <p>Equipo de Zendfast</p>
   <p>https://zendfast.app</p>
   ```

#### 5.2 SMTP Personalizado (Opcional)

**Por qué configurar SMTP custom:**
- Mejor deliverability
- Dominio propio (@zendfast.app)
- Tracking de emails
- Sin límites de Supabase

**Providers recomendados:**
- SendGrid (12,000 emails gratis/mes)
- Mailgun (5,000 emails gratis/mes)
- Amazon SES (muy barato)
- Resend (nuevo, buena DX)

**Configuración en Supabase:**
```
Project Settings → Authentication → SMTP Settings

SMTP Host: smtp.sendgrid.net
SMTP Port: 587
SMTP User: apikey
SMTP Password: <tu-sendgrid-api-key>
Sender Email: noreply@zendfast.app
Sender Name: Zendfast
```

#### 5.3 Notificaciones de Backup por Email

**Referencia:** Tarea #65 - Edge Function 'backup-data'

La función de backup menciona:
> "Configurar notificaciones vía OneSignal/email en caso de fallos"

**Pendiente:** Configurar email de notificaciones para:
- Fallos en backups automáticos
- Alertas de sistema
- Reportes administrativos

**Requiere:** SMTP configurado o servicio de email

### 📝 Checklist de Email

```markdown
**Supabase Auth:**
- [ ] Personalizar template "Confirm signup"
- [ ] Personalizar template "Magic Link"
- [ ] Personalizar template "Reset Password"
- [ ] Personalizar template "Change Email"
- [ ] Agregar logo de Zendfast
- [ ] Usar colores brand (#069494)
- [ ] Configurar sender name "Zendfast"
- [ ] Probar envío de cada template

**SMTP Custom (Opcional):**
- [ ] Registrar cuenta en SendGrid/Mailgun
- [ ] Verificar dominio zendfast.app
- [ ] Configurar SPF records en DNS
- [ ] Configurar DKIM records en DNS
- [ ] Obtener SMTP credentials
- [ ] Configurar en Supabase Dashboard
- [ ] Probar envío desde dominio custom
- [ ] Verificar deliverability

**Notificaciones de Backup:**
- [ ] Decidir sistema de alertas (email/OneSignal)
- [ ] Configurar en Edge Function backup-data
- [ ] Definir email receptor de alertas
- [ ] Probar notificación de fallo
```

---

## 🟢 OPCIONAL: OneSignal REST API Key

**Contexto:** Ya tienes un REST API Key en `.env`
**Estado:** ✅ Funcional
**Tiempo estimado:** 5 minutos

### Cuándo Regenerar

**Solo necesitas regenerar si:**
- Comprometiste el key (git commit público, leak, etc.)
- Quieres rotar keys por seguridad
- Necesitas keys separados para dev/prod

### Cómo Regenerar

```bash
# 1. Ir a OneSignal Dashboard
# 2. Settings → Keys & IDs
# 3. REST API Key → Regenerate
# 4. Copiar nuevo key
# 5. Actualizar en .env:

ONESIGNAL_REST_API_KEY=<nuevo-key-aqui>
```

---

## 📋 Plan de Acción Sugerido

### Fase 1: Fundamentos (2-3 horas)

**Prioridad máxima para poder hacer builds y testing:**

1. ✅ **iOS Flavors** (45 min)
   - Configuración en Xcode
   - Provisioning profiles
   - Verificar builds

2. ✅ **Firebase Projects** (30 min)
   - Crear proyectos
   - Descargar google-services.json
   - Colocar en proyecto

3. ✅ **Apple APNs** (30 min)
   - Generar APNs key
   - Guardar credenciales

4. ✅ **OneSignal Setup** (45 min)
   - Crear apps en dashboard
   - Configurar Firebase
   - Configurar APNs
   - Actualizar .env files

### Fase 2: Infraestructura Web (2-3 horas)

**Para submission a stores y deep linking:**

5. ✅ **Dominio** (30 min)
   - Registrar zendfast.app
   - Configurar DNS
   - Configurar SSL

6. ✅ **Deep Linking** (1 hora)
   - Obtener Team ID
   - Generar release keystore
   - Obtener SHA-256 fingerprints
   - Actualizar archivos .well-known
   - Hostear archivos
   - Verificar configuración

7. ✅ **Landing Pages** (1 hora)
   - Crear privacy.html y terms.html
   - Configurar hosting
   - Verificar URLs públicas

### Fase 3: Polish (30 min - 1 hora)

**Mejoras opcionales:**

8. ⭐ **Email Customization** (30 min)
   - Personalizar templates Supabase
   - Opcionalmente configurar SMTP

---

## 🔗 Links Útiles

### Documentación Oficial

- **Firebase Console:** https://console.firebase.google.com
- **Apple Developer Portal:** https://developer.apple.com/account
- **OneSignal Dashboard:** https://app.onesignal.com
- **Google Play Console:** https://play.google.com/console
- **App Store Connect:** https://appstoreconnect.apple.com

### Guías Específicas

- **Flutter Flavors:** `docs/FLAVORS.md` (en el proyecto)
- **OneSignal Flutter Setup:** https://documentation.onesignal.com/docs/flutter-sdk-setup
- **iOS Universal Links:** https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app
- **Android App Links:** https://developer.android.com/training/app-links

### Herramientas

- **Verificador de Universal Links:** https://search.developer.apple.com/appsearch-validation-tool
- **Verificador de App Links:** https://developers.google.com/digital-asset-links/tools/generator
- **SSL Checker:** https://www.sslshopper.com/ssl-checker.html

---

## ❓ Preguntas Frecuentes

### ¿Puedo lanzar sin OneSignal configurado?

✅ **Sí**, el sistema tiene LocalNotificationService como fallback que funciona sin configuración externa. Pero perderás:
- Notificaciones push remotas
- Scheduling desde backend
- Engagement automático

### ¿Puedo usar solo un flavor por ahora?

⚠️ **No recomendado**. Los flavors son críticos para:
- Testing sin afectar producción
- Datos separados entre dev/prod
- Configuraciones diferentes

Mínimo configura Development flavor.

### ¿Es obligatorio el dominio para App Store submission?

✅ **Sí**, necesitas URLs públicas para:
- Privacy Policy
- Terms of Service

Pero **NO** necesitas dominio custom, puedes usar:
- GitHub Pages: `username.github.io/zendfast/privacy`
- Netlify: `zendfast.netlify.app/privacy`

Sin embargo, deep linking **SÍ requiere** dominio custom.

### ¿Qué pasa si no configuro deep linking?

⚠️ Las notificaciones push funcionarán pero:
- No navegarán a pantalla específica
- Solo abrirán la app
- UX degradada

---

## 📞 Soporte

Si tienes dudas sobre alguna configuración:

1. Revisar documentación en `docs/` del proyecto
2. Consultar logs de implementación en tareas completadas
3. Revisar código de referencia en archivos mencionados

---

**Última actualización:** 2025-11-09
**Versión del documento:** 1.0
**Mantenido por:** Equipo de desarrollo Zendfast
