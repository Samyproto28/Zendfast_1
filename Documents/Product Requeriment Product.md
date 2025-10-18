# PRD Optimizado para Cursor AI - Zendfast

> **Resumen:** Este documento define el alcance, objetivos, funcionalidades, flujos principales, criterios de éxito y restricciones legales/técnicas del producto Zendfast. Es la referencia principal para desarrollo, QA y diseño.

---

## Diagrama General de Flujos

```mermaid
flowchart TD
    Start([Inicio]) --> Onboarding[Onboarding]
    Onboarding --> PlanDetox[Plan de Desintoxicación]
    PlanDetox --> SeleccionPlan[Selección de Plan]
    SeleccionPlan --> Home[Home (Cronómetro)]
    Home --> BotonPanico[Botón de Pánico]
    BotonPanico --> ModalPanico[Modal de Pánico]
    ModalPanico --> Meditar[Meditación Guiada]
    ModalPanico --> RompiAyuno[Rompí el ayuno]
    Home --> Learning[Learning]
    Home --> Hidratacion[Seguimiento de Hidratación]
    Home --> Perfil[Perfil]
    Perfil --> Metricas[Métricas]
    Perfil --> Configuracion[Configuración]
    Perfil --> Historial[Historial]
    Perfil --> Calendario[Calendario]
```

---

## 1. Información del Producto

> **Resumen:** Presenta el nombre, categoría, plataforma y versión del producto. Define el contexto general para el resto del documento.

**Nombre:** Zendfast    
**Categoría:** Aplicación de Salud y Bienestar - Ayuno Intermitente    
**Plataforma:** Móvil (Flutter)    
**Versión:** 1.0  

## 2. Definición del Problema

> **Resumen:** Explica el problema principal que resuelve Zendfast y la audiencia objetivo. Justifica la necesidad del producto.

**Problema Principal:** Falta de una guía completa, herramientas integradas y seguimiento efectivo para el ayuno intermitente que incluya soporte emocional durante los momentos críticos.

**Audiencia Objetivo:** Personas que desean practicar ayuno intermitente para:  
- Quemar grasa  
- Recuperación celular  
- Mejorar la sensibilidad a la insulina

## 3. Historias de Usuario (Mejoradas)

> **Resumen:** Historias de usuario alineadas con los flujos y pantallas principales. Cada historia cubre un caso de uso clave y diferenciador.

1. **Historia 1**: Como usuario que está comenzando con el ayuno intermitente, quiero poder elegir entre diferentes planes de ayuno y establecer temporizadores para seguir un horario de ayuno estructurado.

2. **Historia 2**: Como usuario que está en período de ayuno y siente hambre, quiero tener un botón de pánico que me proporcione frases motivacionales, recomendaciones para evitar atracones y, si es necesario, meditaciones guiadas para ayudarme a resistir la tentación de comer.

3. **Historia 3**: Como usuario, quiero recibir recordatorios para beber agua a intervalos regulares durante mi ayuno para mantenerme hidratado y evitar la fatiga.

4. **Historia 4**: Como usuario interesado en aprender más sobre el ayuno intermitente, quiero tener acceso a una variedad de recursos educativos, como artículos, estudios y videos de YouTube, todo dentro de la aplicación.

5. **Historia 5**: Como usuario, quiero ver métricas sobre mi progreso en el ayuno, como el tiempo total de ayuno, mis ventanas de alimentación y mi peso, para poder rastrear mi consistencia y mejoras a lo largo del tiempo.

6. **Historia 6**: Como nuevo usuario, quiero seguir un plan de desintoxicación de carbohidratos de 48 horas antes de comenzar mi primer ayuno para reducir los antojos de azúcar y hacer que la experiencia de ayuno sea más cómoda.

7.  **Historia 7**: Como usuario, quiero que la aplicación me proporcione estrategias y consejos sobre cómo prevenir atracones después de romper el ayuno y cómo mantener mis niveles de energía durante el ayuno, como a través de una adecuada hidratación y actividad ligera.

## 4. Funcionalidades Core

> **Resumen:** Lista y describe las funcionalidades principales y secundarias, alineadas con los otros documentos técnicos. Incluye comentarios sobre diferenciadores y manejo de errores/accesibilidad.

### 4.1 Funcionalidades Principales  
1. **Planes y Cronómetro de Ayuno Intermitente**  
   - Selección de planes: 12/12, 14/10, 16/8, 18/6, 24 horas, 2 días  
   - Cronómetro de seguimiento en tiempo real  
   - Organización de horarios personalizados

2. **Botón de Pánico** (Funcionalidad Diferenciadora)  
   - Activación durante períodos de ayuno con antojos  
   - Frases motivacionales  
   - Recomendaciones anti-atracones  
   - Opciones: "Meditar" o "Rompí el ayuno"  
   - Respiración guiada para calmar antojos
   - **Comentario:** El botón de pánico es accesible solo durante el ayuno activo. El modal debe ser accesible (labels, focus, feedback háptico). Si falla la red, se muestra mensaje y se permite reintentar. El flujo completo se detalla en el diagrama de pánico.

3. **Seguimiento de Hidratación**  
   - Cálculo automático basado en peso y altura  
   - Recordatorios de hidratación  
   - Prevención de fatiga

4. **Sección Learning**  
   - Contenido educativo sobre ayuno intermitente  
   - Blog integrado  
   - Estudios públicos  
   - Videos de YouTube (requiere conexión)

5. **Métricas y Seguimiento**  
   - Historial de ayunos completados  
   - Horas de ayuno realizadas  
   - Estadísticas de progreso  
   - Análisis de patrones

6. **Plan de Desintoxicación Pre-Ayuno** (Funcionalidad Diferenciadora)  
   - Duración: 48 horas  
   - Protocolo: Solo carne, huevo, queso + sal  
   - Objetivo: Reducir antojos y dependencia del azúcar  
   - Opcional para usuarios primerizos
   - **Comentario:** El plan detox se recomienda solo a usuarios primerizos. Debe incluir advertencia médica y opción de saltar. Si el usuario rechaza, se continúa con el flujo normal.

### 4.2 Funcionalidades Secundarias  
- Sistema de autenticación (registro/login)  
- Onboarding con información general  
- Cuestionario de preferencias de usuario  
- Paywall con Superwall  
- Configuración de perfil personalizado

## 5. Especificaciones Técnicas

> **Resumen:** Define el stack tecnológico, dependencias y requisitos de arquitectura. Asegura consistencia con los otros documentos técnicos.

**Stack Tecnológico:**  
- Frontend: Flutter  
- Backend: Supabase  
- Paywall: Superwall  
- Funcionalidad: Mayoría offline (excepto Learning)

##  6. **Requisitos Técnicos**

> **Resumen:** Lista los requisitos técnicos clave para asegurar compatibilidad, seguridad y rendimiento.

* Desarrollo en **Flutter** para compatibilidad multiplataforma (iOS y Android).  
* Uso de **Supabase** como servicio de backend y base de datos.  
* Integración de **Superwall** para gestión de muros de pago y pruebas A/B.  
* Diseño de UX/UI moderno y fluido con micro-interacciones para mejorar la experiencia del usuario.  
* Optimización del rendimiento para garantizar velocidad y bajo consumo de recursos.  
* Cumplimiento con estándares de protección de datos para almacenar y transmitir información del usuario de manera segura.

## 7. Flujo de Usuario Principal

> **Resumen:** Describe el onboarding, configuración inicial, uso diario y flujos diferenciadores. Incluye diagramas y comentarios sobre manejo de errores y accesibilidad.

### Diagrama de Flujo de Pánico

```mermaid
flowchart TD
    BotonPanico[Botón de Pánico] --> ModalPanico[Modal de Pánico]
    ModalPanico --> Meditar[Meditación Guiada]
    ModalPanico --> RompiAyuno[Rompí el ayuno]
    Meditar --> Seguir[Seguir con el ayuno]
    Meditar --> NoAguanto[No aguanto]
    RompiAyuno --> RegistroInterrupcion[Registro de Interrupción]
    NoAguanto --> RegistroInterrupcion
    Seguir --> Home[Home (Cronómetro)]
```

### 7.1 Onboarding  
> **Comentario:** El onboarding debe ser accesible (labels, hints, contraste, navegación por teclado). Si falla la red, se permite reintentar o continuar en modo offline. El plan detox debe mostrar advertencia médica.

1. Descarga e instalación  
2. Splash screen (5 segundos)  
3. Información general del ayuno (salteable)  
4. Registro/Login  
5. Cuestionario de usuario (peso, altura, preferencias)  
6. Muro de pago (funciones premium)  
7. Pregunta: "¿Es tu primera vez haciendo ayuno?"  
8. Recomendación del plan de desintoxicación (opcional)

### 7.2 Configuración Inicial  
9. Selección de plan de ayuno  
10. Cálculo y asignación de hidratación diaria  
11. Programación de horarios de ayuno

### 7.3 Uso Diario  
12. Acceso a cronómetro y métricas  
13. Seguimiento de hidratación  
14. Botón de pánico (cuando esté en ayuno)  
15. Acceso a contenido Learning

### 7.4 Flujo Botón de Pánico  
> **Comentario:** El flujo de pánico debe ser accesible y resiliente a errores de red. Si falla el registro, se almacena localmente y se sincroniza después. El modal debe tener feedback visual y háptico.

- Activación durante ayuno con antojos  
- Frases motivacionales y recomendaciones  
- Opciones: "Meditar" o "Rompí el ayuno"  
- Si "Meditar": Respiración guiada → "Seguir con el ayuno" o "No aguanto"  
- Si "Seguir": Regreso a cronómetro principal  
- Si "No aguanto" o "Rompí el ayuno": Registro de interrupción

## 8. Requerimientos No Funcionales

> **Resumen:** Define requisitos de rendimiento, usabilidad y seguridad. Incluye recomendaciones para testing y accesibilidad.

> **Guía de testing:**
> - Probar funcionalidades core en modo offline y online.
> - Verificar accesibilidad (contraste, labels, touch targets) en todos los flujos.
> - Simular errores de red y verificar mensajes y recuperación.
> - Probar en dispositivos pequeños, medianos y grandes.

**Rendimiento:**  
- Funcionalidad offline para funciones core  
- Sincronización cuando hay conexión  
- Respuesta rápida en cronómetro
- Tiempos de carga < 2 segundos

**Usabilidad:**  
- Interfaz intuitiva y minimalista  
- Acceso rápido al botón de pánico  
- Navegación simple durante estados de ayuno
- Diseño moderno con micro-interacciones

**Seguridad:**  
- Autenticación segura con Supabase  
- Protección de datos de salud del usuario
- Cumplimiento de estándares de protección de datos

## 9. Criterios de Éxito

> **Resumen:** Define las métricas clave y criterios de aceptación para validar el éxito del producto.

**Métricas Clave:**  
- Tasa de finalización de ayunos  
- Uso efectivo del botón de pánico  
- Retención de usuarios  
- Adopción del plan de desintoxicación

**Criterios de Aceptación:**
- Todas las características implementadas funcionan correctamente
- Proceso de onboarding completo y fluido
- Navegación sin errores críticos
- Rendimiento cumple estándares de la industria

## 10. Restricciones y Consideraciones

> **Resumen:** Enumera restricciones técnicas, de desarrollo y legales. Incluye riesgos y mitigaciones legales.

> **Riesgos y mitigaciones legales:**
> - **Riesgo:** El usuario sigue el plan detox sin supervisión médica.
>   **Mitigación:** Mostrar advertencia clara y requerir confirmación.
> - **Riesgo:** Pérdida de datos sensibles por error de sincronización.
>   **Mitigación:** Guardar localmente y sincronizar seguro al recuperar conexión.
> - **Riesgo:** Incumplimiento de regulaciones de privacidad.
>   **Mitigación:** Cumplir GDPR/CCPA y mostrar política de privacidad clara.

**Desarrollo:**
- Utilizar LLMs en Cursor AI para asistir en generación de código
- Priorizar calidad sobre velocidad
- Aplicación ligera y eficiente

**Legales:**
- Incluir descargo de responsabilidad médica
- Advertencia sobre plan de desintoxicación
- Cumplimiento con regulaciones de privacidad