\# Documento 5: Backend Structure Document \- Zendfast

\#\# 1\. Información General del Backend

> **Resumen:** Esta sección describe la visión general del backend de Zendfast, incluyendo la plataforma, arquitectura, enfoque de seguridad y paradigma de desarrollo. Es la base conceptual para entender el resto del documento.

\*\*Aplicación:\*\* Zendfast    
\*\*Plataforma Backend:\*\* Supabase (PostgreSQL \+ Edge Functions)    
\*\*Arquitectura:\*\* Local-First con Sincronización Inteligente    
\*\*Seguridad:\*\* Row Level Security (RLS) Obligatorio    
\*\*Paradigma:\*\* BaaS (Backend as a Service) con lógica personalizada  

\#\# 2\. Arquitectura de Base de Datos

> **Resumen:** Aquí se detalla el modelo de datos principal, el esquema SQL, las tablas críticas y las políticas de seguridad a nivel de base de datos. Es fundamental para comprender cómo se almacenan y protegen los datos de usuario y de negocio.

\#\#\# 2.1 Esquema General  
\`\`\`sql  
\-- Configuración de base de datos principal  
\-- Database: zendfast\_production / zendfast\_development  
\-- Schema: public (default)  
\-- RLS: HABILITADO en TODAS las tablas de usuario  
\`\`\`

\#\#\# 2.2 Estructura de Tablas Principales

\#\#\#\# Tabla: \`user\_profiles\`  
\`\`\`sql  
CREATE TABLE public.user\_profiles (  
    id UUID REFERENCES auth.users(id) PRIMARY KEY,  
    created\_at TIMESTAMPTZ DEFAULT NOW(),  
    updated\_at TIMESTAMPTZ DEFAULT NOW(),  
      
    \-- Datos demográficos para cálculo de hidratación  
    weight\_kg DECIMAL(5,2) NOT NULL,  
    height\_cm INTEGER NOT NULL,  
      
    \-- Estado de onboarding  
    is\_first\_time\_faster BOOLEAN DEFAULT true,  
    onboarding\_completed BOOLEAN DEFAULT false,  
    detox\_plan\_recommended BOOLEAN DEFAULT false,  
    detox\_plan\_accepted BOOLEAN DEFAULT false,  
      
    \-- Configuraciones personalizadas  
    ml\_per\_glass INTEGER DEFAULT 250,  
    daily\_hydration\_goal INTEGER GENERATED ALWAYS AS (  
        \-- Cálculo automático: peso \* 30-35ml por kg  
        ROUND(weight\_kg \* 32)::INTEGER  
    ) STORED,  
      
    \-- Configuraciones de tema y notificaciones  
    theme\_mode TEXT DEFAULT 'system' CHECK (theme\_mode IN ('light', 'dark', 'system')),  
    notifications\_enabled BOOLEAN DEFAULT true,  
    notification\_water\_enabled BOOLEAN DEFAULT true,  
    notification\_motivation\_enabled BOOLEAN DEFAULT true,  
    notification\_educational\_enabled BOOLEAN DEFAULT false,  
      
    \-- Estado de suscripción  
    subscription\_status TEXT DEFAULT 'free' CHECK (subscription\_status IN ('free', 'premium')),  
    subscription\_type TEXT CHECK (subscription\_type IN ('monthly\_premium', 'yearly\_premium')),  
    subscription\_expires\_at TIMESTAMPTZ,  
      
    CONSTRAINT valid\_weight CHECK (weight\_kg \> 30 AND weight\_kg \< 300),  
    CONSTRAINT valid\_height CHECK (height\_cm \> 100 AND height\_cm \< 250\)  
);

\-- RLS para user\_profiles  
ALTER TABLE user\_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON user\_profiles  
    FOR SELECT USING (auth.uid() \= id);

CREATE POLICY "Users can update own profile" ON user\_profiles  
    FOR UPDATE USING (auth.uid() \= id);

CREATE POLICY "Users can insert own profile" ON user\_profiles  
    FOR INSERT WITH CHECK (auth.uid() \= id);

\-- Índices para performance  
CREATE INDEX idx\_user\_profiles\_subscription ON user\_profiles(subscription\_status, subscription\_expires\_at);  
\`\`\`

\#\#\#\# Tabla: \`fasting\_plans\`  
\`\`\`sql  
CREATE TABLE public.fasting\_plans (  
    id SERIAL PRIMARY KEY,  
    plan\_name TEXT NOT NULL UNIQUE,  
    plan\_type TEXT NOT NULL,  
    fasting\_hours INTEGER NOT NULL,  
    eating\_hours INTEGER NOT NULL,  
    description TEXT,  
    is\_active BOOLEAN DEFAULT true,  
    created\_at TIMESTAMPTZ DEFAULT NOW(),  
      
    \-- Planes predefinidos  
    CONSTRAINT valid\_plan\_type CHECK (plan\_type IN ('intermittent', 'extended', 'detox')),  
    CONSTRAINT valid\_hours CHECK (fasting\_hours \+ eating\_hours \= 24 OR plan\_type \= 'extended')  
);

\-- Datos iniciales de planes  
INSERT INTO fasting\_plans (plan\_name, plan\_type, fasting\_hours, eating\_hours, description) VALUES  
('12/12', 'intermittent', 12, 12, 'Plan para principiantes'),  
('14/10', 'intermittent', 14, 10, 'Plan intermedio'),  
('16/8', 'intermittent', 16, 8, 'Plan más popular'),  
('18/6', 'intermittent', 18, 6, 'Plan avanzado'),  
('24 horas', 'extended', 24, 0, 'Ayuno de día completo'),  
('48 horas', 'extended', 48, 0, 'Ayuno extendido'),  
('Desintoxicación 48h', 'detox', 48, 0, 'Plan de desintoxicación: solo carne, huevo, queso \+ sal');

\-- No requiere RLS (datos públicos de referencia)  
\`\`\`

\#\#\#\# Tabla: \`fasting\_sessions\`  
\`\`\`sql  
CREATE TABLE public.fasting\_sessions (  
    id UUID DEFAULT gen\_random\_uuid() PRIMARY KEY,  
    user\_id UUID REFERENCES auth.users(id) NOT NULL,  
    plan\_id INTEGER REFERENCES fasting\_plans(id) NOT NULL,  
      
    created\_at TIMESTAMPTZ DEFAULT NOW(),  
    updated\_at TIMESTAMPTZ DEFAULT NOW(),  
      
    \-- Tiempos de la sesión  
    start\_time TIMESTAMPTZ NOT NULL,  
    planned\_end\_time TIMESTAMPTZ NOT NULL,  
    actual\_end\_time TIMESTAMPTZ,  
      
    \-- Estado de la sesión  
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'interrupted', 'paused')),  
      
    \-- Datos de interrupción  
    interruption\_reason TEXT CHECK (interruption\_reason IN ('panic\_button', 'broke\_fast', 'meditation\_failed', 'manual\_stop')),  
    interruption\_note TEXT,  
    time\_completed\_minutes INTEGER,  
      
    \-- Métricas de la sesión  
    panic\_button\_used BOOLEAN DEFAULT false,  
    meditation\_attempts INTEGER DEFAULT 0,  
    meditation\_successful INTEGER DEFAULT 0,  
      
    \-- Validaciones  
    CONSTRAINT valid\_session\_times CHECK (planned\_end\_time \> start\_time),  
    CONSTRAINT interruption\_requires\_reason CHECK (  
        (status \= 'interrupted' AND interruption\_reason IS NOT NULL) OR   
        (status \!= 'interrupted')  
    )  
);

\-- RLS para fasting\_sessions  
ALTER TABLE fasting\_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own fasting sessions" ON fasting\_sessions  
    FOR ALL USING (auth.uid() \= user\_id);

\-- Índices para performance  
CREATE INDEX idx\_fasting\_sessions\_user\_status ON fasting\_sessions(user\_id, status);  
CREATE INDEX idx\_fasting\_sessions\_start\_time ON fasting\_sessions(start\_time);  
\`\`\`

\#\#\#\# Tabla: \`hydration\_logs\`  
\`\`\`sql  
CREATE TABLE public.hydration\_logs (  
    id UUID DEFAULT gen\_random\_uuid() PRIMARY KEY,  
    user\_id UUID REFERENCES auth.users(id) NOT NULL,  
      
    date DATE DEFAULT CURRENT\_DATE,  
    timestamp TIMESTAMPTZ DEFAULT NOW(),  
      
    \-- Datos de hidratación  
    ml\_consumed INTEGER NOT NULL,  
    daily\_progress INTEGER DEFAULT 0,  
    goal\_achieved BOOLEAN DEFAULT false,  
      
    \-- Metadata  
    created\_at TIMESTAMPTZ DEFAULT NOW(),  
      
    CONSTRAINT valid\_ml\_consumed CHECK (ml\_consumed \> 0 AND ml\_consumed \<= 1000\)  
);

\-- RLS para hydration\_logs  
ALTER TABLE hydration\_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own hydration logs" ON hydration\_logs  
    FOR ALL USING (auth.uid() \= user\_id);

\-- Índices para performance  
CREATE INDEX idx\_hydration\_logs\_user\_date ON hydration\_logs(user\_id, date);  
\`\`\`

\#\#\#\# Tabla: \`learning\_content\`  
\`\`\`sql  
CREATE TABLE public.learning\_content (  
    id UUID DEFAULT gen\_random\_uuid() PRIMARY KEY,  
    created\_at TIMESTAMPTZ DEFAULT NOW(),  
    updated\_at TIMESTAMPTZ DEFAULT NOW(),  
      
    \-- Contenido básico  
    title TEXT NOT NULL,  
    description TEXT,  
    content\_type TEXT NOT NULL CHECK (content\_type IN ('article', 'video', 'study', 'guide')),  
      
    \-- URLs y referencias  
    external\_url TEXT,  
    youtube\_video\_id TEXT,  
    thumbnail\_url TEXT,  
      
    \-- Categorización  
    category TEXT NOT NULL CHECK (category IN ('articles', 'videos', 'studies', 'guides')),  
    tags TEXT\[\],  
      
    \-- Estado y visibilidad  
    is\_published BOOLEAN DEFAULT false,  
    featured BOOLEAN DEFAULT false,  
    order\_index INTEGER DEFAULT 0,  
      
    \-- Metadata para SEO/Analytics  
    view\_count INTEGER DEFAULT 0,  
    reading\_time\_minutes INTEGER,  
      
    CONSTRAINT valid\_content\_url CHECK (  
        (content\_type \= 'video' AND youtube\_video\_id IS NOT NULL) OR  
        (content\_type \!= 'video' AND external\_url IS NOT NULL)  
    )  
);

\-- No requiere RLS (contenido público)  
\-- Políticas para administradores únicamente

CREATE INDEX idx\_learning\_content\_category ON learning\_content(category, is\_published);  
CREATE INDEX idx\_learning\_content\_featured ON learning\_content(featured, order\_index);  
\`\`\`

\#\#\#\# Tabla: \`user\_content\_interactions\`  
\`\`\`sql  
CREATE TABLE public.user\_content\_interactions (  
    id UUID DEFAULT gen\_random\_uuid() PRIMARY KEY,  
    user\_id UUID REFERENCES auth.users(id) NOT NULL,  
    content\_id UUID REFERENCES learning\_content(id) NOT NULL,  
      
    created\_at TIMESTAMPTZ DEFAULT NOW(),  
    updated\_at TIMESTAMPTZ DEFAULT NOW(),  
      
    \-- Tipos de interacción  
    interaction\_type TEXT NOT NULL CHECK (interaction\_type IN ('viewed', 'favorited', 'completed')),  
      
    \-- Datos de progreso  
    time\_spent\_seconds INTEGER DEFAULT 0,  
    progress\_percentage INTEGER DEFAULT 0 CHECK (progress\_percentage \>= 0 AND progress\_percentage \<= 100),  
      
    UNIQUE(user\_id, content\_id, interaction\_type)  
);

\-- RLS para user\_content\_interactions  
ALTER TABLE user\_content\_interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own content interactions" ON user\_content\_interactions  
    FOR ALL USING (auth.uid() \= user\_id);  
\`\`\`

\#\#\#\# Tabla: \`system\_logs\`  
\`\`\`sql  
CREATE TABLE public.system\_logs (  
    id UUID DEFAULT gen\_random\_uuid() PRIMARY KEY,  
    log\_type TEXT NOT NULL,  
    message TEXT NOT NULL,  
    timestamp TIMESTAMPTZ DEFAULT NOW(),  
    metadata JSONB  
);

\-- No requiere RLS (logs del sistema)  
\`\`\`

## 3. Edge Functions

> **Resumen:** Sección dedicada a las funciones edge de Supabase, que encapsulan la lógica de negocio crítica, integración con servicios externos (notificaciones, analíticas, monitoreo) y operaciones avanzadas de sincronización y métricas.

### 3.1 Tipos TypeScript  
\`\`\`typescript  
// Interfaces principales para Edge Functions  
interface FastingSession {  
  id: string  
  user\_id: string  
  plan\_id: number  
  start\_time: string  
  planned\_end\_time: string  
  actual\_end\_time?: string  
  status: 'active' | 'completed' | 'interrupted' | 'paused'  
  interruption\_reason?: string  
  interruption\_note?: string  
  panic\_button\_used: boolean  
  meditation\_attempts: number  
  meditation\_successful: number  
}

interface LearningContent {  
  id: string  
  title: string  
  description?: string  
  content\_type: 'article' | 'video' | 'study' | 'guide'  
  external\_url?: string  
  youtube\_video\_id?: string  
  thumbnail\_url?: string  
  category: string  
  tags: string\[\]  
  is\_published: boolean  
  featured: boolean  
}

interface UserMetrics {  
  totalFastingHours: number  
  completedSessions: number  
  currentStreak: number  
  averageSessionDuration: number  
  successRate: number  
  panicButtonUsage: number  
  hydrationGoalAchievement: number  
}  
\`\`\`

### 3.2 Función: Cálculo de Métricas de Usuario  
\`\`\`typescript  
// Edge Function: calculate-user-metrics  
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"  
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Funciones utilitarias  
function calculateTotalHours(sessions: any\[\]): number {  
  return sessions  
    .filter(s \=\> s.status \=== 'completed')  
    .reduce((total, session) \=\> {  
      const start \= new Date(session.start\_time)  
      const end \= new Date(session.actual\_end\_time || session.planned\_end\_time)  
      return total \+ (end.getTime() \- start.getTime()) / (1000 \* 60 \* 60\)  
    }, 0\)  
}

function calculateCurrentStreak(sessions: any\[\]): number {  
  const completedSessions \= sessions  
    .filter(s \=\> s.status \=== 'completed')  
    .sort((a, b) \=\> new Date(b.start\_time).getTime() \- new Date(a.start\_time).getTime())  
    
  let streak \= 0  
  let lastDate \= new Date()  
    
  for (const session of completedSessions) {  
    const sessionDate \= new Date(session.start\_time)  
    const daysDiff \= Math.floor((lastDate.getTime() \- sessionDate.getTime()) / (1000 \* 60 \* 60 \* 24))  
      
    if (daysDiff \<= 1\) {  
      streak++  
      lastDate \= sessionDate  
    } else {  
      break  
    }  
  }  
    
  return streak  
}

function calculateAverageDuration(sessions: any\[\]): number {  
  const completedSessions \= sessions.filter(s \=\> s.status \=== 'completed')  
  if (completedSessions.length \=== 0\) return 0  
    
  const totalHours \= calculateTotalHours(completedSessions)  
  return totalHours / completedSessions.length  
}

function calculateSuccessRate(sessions: any\[\]): number {  
  if (sessions.length \=== 0\) return 0  
  const completedCount \= sessions.filter(s \=\> s.status \=== 'completed').length  
  return (completedCount / sessions.length) \* 100  
}

function calculatePanicUsage(sessions: any\[\]): number {  
  const panicSessions \= sessions.filter(s \=\> s.panic\_button\_used)  
  const successfulPanicSessions \= panicSessions.filter(s \=\> s.status \=== 'completed')  
    
  if (panicSessions.length \=== 0\) return 0  
  return (successfulPanicSessions.length / panicSessions.length) \* 100  
}

function calculateHydrationSuccess(hydrationLogs: any\[\]): number {  
  if (\!hydrationLogs || hydrationLogs.length \=== 0\) return 0  
  const successfulDays \= hydrationLogs.filter(log \=\> log.goal\_achieved).length  
  const uniqueDays \= new Set(hydrationLogs.map(log \=\> log.date)).size  
    
  return uniqueDays \> 0 ? (successfulDays / uniqueDays) \* 100 : 0  
}

serve(async (req) \=\> {  
  try {  
    const { userId } \= await req.json()  
      
    const supabase \= createClient(  
      Deno.env.get('SUPABASE\_URL') ?? '',  
      Deno.env.get('SUPABASE\_SERVICE\_ROLE\_KEY') ?? ''  
    )

    // Calcular métricas de ayuno  
    const { data: sessions } \= await supabase  
      .from('fasting\_sessions')  
      .select('\*')  
      .eq('user\_id', userId)  
      .order('start\_time', { ascending: false })

    // Calcular métricas de hidratación  
    const { data: hydrationLogs } \= await supabase  
      .from('hydration\_logs')  
      .select('\*')  
      .eq('user\_id', userId)  
      .gte('date', new Date(Date.now() \- 30 \* 24 \* 60 \* 60 \* 1000).toISOString())

    const metrics: UserMetrics \= {  
      totalFastingHours: calculateTotalHours(sessions || \[\]),  
      completedSessions: sessions?.filter(s \=\> s.status \=== 'completed').length || 0,  
      currentStreak: calculateCurrentStreak(sessions || \[\]),  
      averageSessionDuration: calculateAverageDuration(sessions || \[\]),  
      successRate: calculateSuccessRate(sessions || \[\]),  
      panicButtonUsage: calculatePanicUsage(sessions || \[\]),  
      hydrationGoalAchievement: calculateHydrationSuccess(hydrationLogs || \[\])  
    }

    return new Response(JSON.stringify(metrics), {  
      headers: { 'Content-Type': 'application/json' }  
    })

  } catch (error) {  
    return new Response(JSON.stringify({ error: error.message }), {  
      status: 400,  
      headers: { 'Content-Type': 'application/json' }  
    })  
  }  
})  
\`\`\`

### 3.3 Función: Gestión de Notificaciones Push  
```typescript  
// Edge Function: schedule-notifications  
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"  
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface NotificationPayload {  
  userId: string  
  type: 'fasting_start' | 'fasting_end' | 'hydration_reminder' | 'motivation' | 'educational'  
  scheduledTime: string  
  customMessage?: string  
}

serve(async (req) => {  
  try {  
    const { userId, sessionId, planType } = await req.json()  
    
    const supabase = createClient(  
      Deno.env.get('SUPABASE_URL') ?? '',  
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  
    )  
    
    // Obtener configuraciones de notificación del usuario  
    const { data: profile } = await supabase  
      .from('user_profiles')  
      .select('notification_*')  
      .eq('id', userId)  
      .single()

    if (!profile?.notifications_enabled) {  
      return new Response(JSON.stringify({ message: 'Notifications disabled' }))  
    }

    // Programar notificaciones basadas en el plan de ayuno  
    const notifications = generateNotificationSchedule(sessionId, planType, profile)  
    
    // Enviar a OneSignal vía Edge Function  
    for (const notification of notifications) {  
      await sendOneSignalNotification(notification, userId)  
    }

    return new Response(JSON.stringify({   
      message: 'Notifications scheduled successfully',  
      count: notifications.length   
    }))

  } catch (error) {  
    return new Response(JSON.stringify({ error: error.message }), {  
      status: 400  
    })  
  }  
})

function generateNotificationSchedule(sessionId: string, planType: string, profile: any) {  
  const notifications = []  
  
  // Notificación de inicio  
  notifications.push({  
    type: 'fasting_start',  
    message: '¡Tu ayuno ha comenzado! 💪',  
    delay: 0  
  })  
  
  // Recordatorios de agua cada 2-3 horas  
  if (profile.notification_water_enabled) {  
    for (let i = 2; i <= 12; i += 3) {  
      notifications.push({  
        type: 'hydration_reminder',  
        message: '💧 Recuerda hidratarte',  
        delay: i * 60 * 60 * 1000 // horas en milliseconds  
      })  
    }  
  }  
  
  // Motivación cada 4-6 horas  
  if (profile.notification_motivation_enabled) {  
    for (let i = 4; i <= 16; i += 6) {  
      notifications.push({  
        type: 'motivation',  
        message: `¡Vas muy bien! Ya llevas ${i} horas`,  
        delay: i * 60 * 60 * 1000  
      })  
    }  
  }  
  
  return notifications  
}

async function sendOneSignalNotification(notification: any, userId: string) {  
  // Implementación de integración con OneSignal vía API REST  
  // Esta función se conectaría con OneSignal para programar notificaciones push  
  // Ejemplo simplificado:
  await fetch('https://onesignal.com/api/v1/notifications', {  
    method: 'POST',  
    headers: {  
      'Content-Type': 'application/json',  
      'Authorization': `Basic ${Deno.env.get('ONESIGNAL_API_KEY')}`  
    },  
    body: JSON.stringify({  
      app_id: Deno.env.get('ONESIGNAL_APP_ID'),  
      include_external_user_ids: [userId],  
      headings: { en: 'Zendfast' },  
      contents: { en: notification.message },  
      send_after: new Date(Date.now() + (notification.delay || 0)).toISOString(),  
      data: { type: notification.type }  
    })  
  })  
}  
```

### 3.4 Función: Sincronización de Datos  
\`\`\`typescript  
// Edge Function: sync-user-data  
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"  
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface SyncData {  
  fastingSessions: any\[\]  
  hydrationLogs: any\[\]  
  userSettings: any  
  lastSyncTimestamp: string  
}

serve(async (req) => {  
  try {  
    const { userId, localData, lastSync } = await req.json()  
      
    const supabase = createClient(  
      Deno.env.get('SUPABASE_URL') ?? '',  
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  
    )  
      
    // Resolver conflictos usando timestamp  
    const resolvedData = await resolveDataConflicts(supabase, userId, localData, lastSync)  
      
    // Actualizar datos en Supabase  
    await updateUserData(supabase, userId, resolvedData)  
      
    // Obtener datos actualizados para enviar al cliente  
    const updatedData = await getUserData(supabase, userId, lastSync)  
      
    return new Response(JSON.stringify({  
      success: true,  
      data: updatedData,  
      syncTimestamp: new Date().toISOString()  
    }))

  } catch (error) {  
    return new Response(JSON.stringify({ error: error.message }), {  
      status: 400  
    })  
  }  
})

async function resolveDataConflicts(supabase: any, userId: string, localData: SyncData, lastSync: string) {  
  // Estrategia: Prioridad a datos locales con timestamp más reciente  
  // Server-side data wins only if local data is corrupted or invalid  
    
  const { data: serverData } = await supabase  
    .from('fasting_sessions')  
    .select('*')  
    .eq('user_id', userId)  
    .gte('updated_at', lastSync)  
    
  // Implementar lógica de resolución de conflictos  
  return mergeDataWithConflictResolution(localData, serverData)  
}

function mergeDataWithConflictResolution(localData: SyncData, serverData: any\[\]) {  
  // Lógica de merge basada en timestamps  
  // Priorizar datos más recientes  
  return localData // Simplificado para el ejemplo  
}

async function updateUserData(supabase: any, userId: string, data: any) {  
  // Actualizar datos en batch  
  // Implementar transacciones para consistencia  
}

async function getUserData(supabase: any, userId: string, lastSync: string) {  
  // Obtener datos actualizados del servidor  
  return {}// Datos sincronizados  
}  
\`\`\`

## 4. Row Level Security (RLS) Policies

> **Resumen:** Políticas de seguridad obligatorias para garantizar el aislamiento de datos entre usuarios y la protección de información sensible. Incluye ejemplos y plantillas reutilizables.

### 4.1 Políticas de Seguridad Obligatorias  
\`\`\`sql  
\-- Política base para todas las tablas de usuario  
\-- Template para aplicar en todas las tablas sensibles

\-- Para fasting\_sessions  
CREATE POLICY "fasting\_sessions\_user\_isolation" ON fasting\_sessions  
    FOR ALL USING (auth.uid() \= user\_id);

\-- Para hydration\_logs    
CREATE POLICY "hydration\_logs\_user\_isolation" ON hydration\_logs  
    FOR ALL USING (auth.uid() \= user\_id);

\-- Para user\_profiles  
CREATE POLICY "user\_profiles\_own\_data\_only" ON user\_profiles  
    FOR ALL USING (auth.uid() \= id);

\-- Para user\_content\_interactions  
CREATE POLICY "content\_interactions\_user\_only" ON user\_content\_interactions  
    FOR ALL USING (auth.uid() \= user\_id);

\-- Política para administradores (solo analytics agregados)  
CREATE POLICY "admin\_aggregate\_analytics" ON fasting\_sessions  
    FOR SELECT USING (  
        auth.jwt() \-\>\> 'role' \= 'admin' AND   
        current\_setting('request.headers.aggregate\_only', true) \= 'true'  
    );  
\`\`\`

### 4.2 Funciones de Seguridad Personalizadas  
\`\`\`sql  
-- Función para validar límites de ayuno seguros
-- Esta función asegura que los usuarios no puedan crear sesiones de ayuno que excedan límites saludables, considerando su peso y otras restricciones. Es una capa de protección adicional a las validaciones de frontend.
CREATE OR REPLACE FUNCTION validate_fasting_duration(
    p_fasting_hours INTEGER,
    p_user_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    user_profile RECORD;
BEGIN
    SELECT weight_kg, height_cm INTO user_profile
    FROM user_profiles   
    WHERE id = p_user_id;
      
    -- Límites de seguridad basados en perfil de usuario  
    IF p_fasting_hours > 48 THEN
        RETURN false; -- Máximo 48 horas
    END IF;
      
    -- Validaciones adicionales basadas en peso/salud  
    IF user_profile.weight_kg < 50 AND p_fasting_hours > 24 THEN
        RETURN false; -- Restricción para personas de bajo peso
    END IF;
      
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función de trigger corregida
-- Este trigger se ejecuta antes de insertar o actualizar una sesión de ayuno activa, validando automáticamente que la duración sea segura para el usuario.
CREATE OR REPLACE FUNCTION validate_fasting_limits()
RETURNS TRIGGER AS $$
DECLARE
    planned_hours INTEGER;
BEGIN
    -- Calcular horas planificadas
    planned_hours := EXTRACT(EPOCH FROM (NEW.planned_end_time - NEW.start_time)) / 3600;
      
    -- Validar usando la función de seguridad
    IF NOT validate_fasting_duration(planned_hours, NEW.user_id) THEN
        RAISE EXCEPTION 'Duración de ayuno excede límites de seguridad';
    END IF;
      
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validación automática  
CREATE TRIGGER validate_fasting_session_safety  
    BEFORE INSERT OR UPDATE ON fasting_sessions  
    FOR EACH ROW  
    WHEN (NEW.status = 'active')  
    EXECUTE FUNCTION validate_fasting_limits();  
\`\`\`

## 5. APIs y Endpoints

> **Resumen:** Definición de los endpoints principales del backend, sus rutas, interfaces y payloads. Esta sección es clave para la integración con el frontend y otros servicios.

### 5.1 Endpoints Core de Ayuno  
\`\`\`typescript  
// API Routes para funcionalidad principal

// GET /api/fasting/current-session  
// Obtener sesión activa de ayuno  
interface CurrentSessionResponse {  
  session: FastingSession | null  
  timeRemaining: number  
  status: 'active' | 'inactive' | 'paused'  
  canUsePanicButton: boolean  
}

// POST /api/fasting/start-session  
// Iniciar nueva sesión de ayuno  
interface StartSessionRequest {  
  planId: number  
  startTime: string  
  customDuration?: number  
}

// PUT /api/fasting/interrupt-session  
// Interrumpir sesión actual (botón de pánico)  
interface InterruptSessionRequest {  
  sessionId: string  
  reason: 'panic\_button' | 'broke\_fast' | 'meditation\_failed'  
  note?: string  
  meditationAttempted: boolean  
}

// GET /api/fasting/user-metrics  
// Obtener métricas de usuario  
interface UserMetricsResponse {  
  totalFastingHours: number  
  completedSessions: number  
  currentStreak: number  
  successRate: number  
  weeklyHours: number  
  monthlyHours: number  
}  
\`\`\`

### 5.2 Endpoints de Hidratación  
\`\`\`typescript  
// POST /api/hydration/log-intake  
// Registrar consumo de agua  
interface LogIntakeRequest {  
  mlConsumed: number  
  timestamp?: string  
}

// GET /api/hydration/daily-progress  
// Obtener progreso de hidratación del día  
interface DailyProgressResponse {  
  totalConsumed: number  
  goalAmount: number  
  progressPercentage: number  
  goalAchieved: boolean  
  lastIntake?: string  
}

// PUT /api/hydration/update-settings  
// Actualizar configuración de hidratación  
interface HydrationSettingsRequest {  
  mlPerGlass: number  
  reminderFrequency: number  
}  
\`\`\`

### 5.3 Endpoints de Learning Content  
\`\`\`typescript  
// GET /api/learning/content  
// Obtener contenido por categoría  
interface ContentListResponse {  
  content: LearningContent\[\]  
  categories: string\[\]  
  totalCount: number  
  hasMore: boolean  
}

// POST /api/learning/track-interaction  
// Trackear interacción con contenido  
interface TrackInteractionRequest {  
  contentId: string  
  interactionType: 'viewed' | 'favorited' | 'completed'  
  timeSpent?: number  
  progressPercentage?: number  
}

// GET /api/learning/user-favorites    
// Obtener contenido favorito del usuario  
interface UserFavoritesResponse {  
  favorites: LearningContent\[\]  
  totalCount: number  
}  
\`\`\`

## 6. Configuración de Sincronización

> **Resumen:** Estrategia local-first, reglas de sincronización inteligente y resolución de conflictos entre datos locales y del servidor. Fundamental para la experiencia offline y la integridad de datos.

### 6.1 Estrategia Local-First  
\`\`\`typescript  
// Configuración de sincronización inteligente  
interface SyncConfiguration {  
  // Sincronización automática cada 15 minutos  
  automaticSyncInterval: 15 \* 60 \* 1000 // 15 minutos en ms  
    
  // Solo WiFi por defecto  
  wifiOnlyDefault: true  
    
  // Datos críticos para sincronización inmediata  
  criticalDataTypes: \[  
    'fasting\_session\_start',  
    'fasting\_session\_end',   
    'panic\_button\_usage',  
    'subscription\_changes'  
  \]  
    
  // Datos que pueden sincronizarse en batch  
  batchDataTypes: \[  
    'hydration\_logs',  
    'user\_settings\_changes',  
    'content\_interactions',  
    'metrics\_updates'  
  \]  
}

// Función de resolución de conflictos  
interface ConflictResolution {  
  strategy: 'client\_wins' | 'server\_wins' | 'timestamp\_based'  
    
  // Reglas específicas por tipo de dato  
  rules: {  
    fasting\_sessions: 'timestamp\_based',  
    user\_profiles: 'client\_wins', // Usuario controla su perfil  
    hydration\_logs: 'merge\_by\_timestamp',  
    learning\_interactions: 'server\_wins' // Para analytics  
  }  
}  
\`\`\`

### 6.2 Background Sync Implementation  
\`\`\`typescript  
// Implementación de sincronización en background  
class BackgroundSyncService {  
  private syncQueue: SyncOperation\[\] \= \[\]  
  private isOnline: boolean \= true  
  private isWiFiOnly: boolean \= true  
    
  async scheduleBatchSync(data: any\[\], type: string) {  
    this.syncQueue.push({  
      id: generateId(),  
      data,  
      type,  
      timestamp: new Date().toISOString(),  
      retryCount: 0,  
      priority: this.getPriority(type)  
    })  
      
    // Ejecutar inmediatamente si es crítico  
    if (this.isCriticalData(type)) {  
      await this.executeSyncOperation(this.syncQueue\[this.syncQueue.length \- 1\])  
    }  
  }  
    
  private async executeSyncOperation(operation: SyncOperation) {  
    try {  
      const response \= await fetch('/api/sync/batch', {  
        method: 'POST',  
        headers: { 'Content-Type': 'application/json' },  
        body: JSON.stringify(operation)  
      })  
        
      if (response.ok) {  
        this.removeSyncOperation(operation.id)  
      } else {  
        await this.handleSyncFailure(operation)  
      }  
    } catch (error) {  
      await this.handleSyncFailure(operation)  
    }  
  }  
    
  private getPriority(type: string): number {  
    const priorities \= {  
      'fasting\_session\_start': 1,  
      'fasting\_session\_end': 1,  
      'panic\_button\_usage': 1,  
      'subscription\_changes': 1,  
      'hydration\_logs': 2,  
      'user\_settings\_changes': 2,  
      'content\_interactions': 3,  
      'metrics\_updates': 3  
    }  
    return priorities\[type\] || 3  
  }  
    
  private isCriticalData(type: string): boolean {  
    return \['fasting\_session\_start', 'fasting\_session\_end', 'panic\_button\_usage', 'subscription\_changes'\].includes(type)  
  }  
    
  private generateId(): string {  
    return Math.random().toString(36).substr(2, 9\)  
  }  
    
  private removeSyncOperation(id: string) {  
    this.syncQueue \= this.syncQueue.filter(op \=\> op.id \!=== id)  
  }  
    
  private async handleSyncFailure(operation: SyncOperation) {  
    operation.retryCount++  
    if (operation.retryCount < 3) {  
      // Reintenta después de un delay exponencial  
      setTimeout(() => this.executeSyncOperation(operation), Math.pow(2, operation.retryCount) * 1000)  
    }  
  }  
}

interface SyncOperation {  
  id: string  
  data: any\[\]  
  type: string  
  timestamp: string  
  retryCount: number  
  priority: number  
}  
\`\`\`

## 7. Analytics y Métricas

> **Resumen:** Eventos críticos de analíticas, vistas de KPIs y mecanismos para el seguimiento de éxito y uso de la app. Incluye la estructura de la tabla de eventos y vistas agregadas para reporting.

#### 7.1 Eventos de Analytics Críticos  
```sql  
-- Tabla para eventos de analytics  
CREATE TABLE public.analytics_events (  
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,  
    user_id UUID REFERENCES auth.users(id),  
    event_type TEXT NOT NULL,  
    event_data JSONB,  
    timestamp TIMESTAMPTZ DEFAULT NOW(),  
    session_id TEXT,  
    
    -- Índices para queries frecuentes  
    CONSTRAINT valid_event_type CHECK (event_type IN (  
        'fasting_started',  
        'fasting_completed',   
        'fasting_interrupted',  
        'panic_button_used',  
        'meditation_attempted',  
        'meditation_completed',  
        'hydration_logged',  
        'plan_changed',  
        'content_viewed',  
        'subscription_converted'  
    ))  
);

-- RLS para analytics (solo el usuario puede ver sus propios eventos)  
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_own_analytics_only" ON analytics_events  
    FOR SELECT USING (auth.uid() = user_id);

-- Política para admin analytics (solo datos agregados)  
CREATE POLICY "admin_aggregate_analytics_only" ON analytics_events  
    FOR SELECT USING (  
        auth.jwt() ->> 'role' = 'admin' AND  
        user_id IS NULL -- Solo eventos agregados sin user_id  
    );

-- Índices para performance  
CREATE INDEX idx_analytics_events_type_timestamp ON analytics_events(event_type, timestamp);  
CREATE INDEX idx_analytics_events_user_type ON analytics_events(user_id, event_type);  
```

#### 7.2 Métricas de Éxito KPI  
```sql  
-- Vista para métricas clave de éxito  
CREATE VIEW success_metrics AS  
SELECT   
    -- Tasa de finalización de ayunos (KPI principal)  
    ROUND(  
        (COUNT(*) FILTER (WHERE status = 'completed') * 100.0) /   
        NULLIF(COUNT(*), 0), 2  
    ) as completion_rate,  
    
    -- Uso efectivo del botón de pánico (diferenciador clave)  
    ROUND(  
        (COUNT(*) FILTER (WHERE panic_button_used = true AND status = 'completed') * 100.0) /  
        NULLIF(COUNT(*) FILTER (WHERE panic_button_used = true), 0), 2  
    ) as panic_button_success_rate,  
    
    -- Adopción del plan de desintoxicación  
    ROUND(  
        (COUNT(*) FILTER (WHERE plan_id = (SELECT id FROM fasting_plans WHERE plan_name = 'Desintoxicación 48h')) * 100.0) /  
        NULLIF(COUNT(DISTINCT user_id), 0), 2  
    ) as detox_adoption_rate,  
    
    -- Métricas temporales  
    DATE_TRUNC('day', start_time) as date_period  
FROM fasting_sessions   
WHERE start_time >= NOW() - INTERVAL '30 days'  
GROUP BY DATE_TRUNC('day', start_time)  
ORDER BY date_period DESC;  
```

### 7.3 Monitoreo de Errores con Sentry
> **Privacidad y tratamiento de errores:** Los errores críticos se reportan a Sentry a través de una Edge Function. Solo se envía información relevante para el diagnóstico (mensaje de error, ID de usuario, contexto técnico). No se transmiten datos sensibles de salud ni información personal innecesaria. Se recomienda anonimizar los datos de contexto y cumplir con las políticas de privacidad vigentes.
```typescript
// Edge Function: sentry-error-report
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const { error, userId, context } = await req.json()
    // Enviar error a Sentry vía API HTTP
    await fetch('https://sentry.io/api/YOUR_PROJECT_ID/store/', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Sentry-Auth': `Sentry sentry_key=${Deno.env.get('SENTRY_API_KEY')}, sentry_version=7, sentry_client=zendfast-edge`,
      },
      body: JSON.stringify({
        message: error,
        user: { id: userId },
        extra: context,
        timestamp: Date.now() / 1000
      })
    })
    return new Response(JSON.stringify({ success: true }))
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
```

## 8. Configuración de Desarrollo vs Producción

> **Resumen:** Diferencias clave entre los entornos de desarrollo y producción, incluyendo variables, claves, y configuraciones de seguridad y debugging.

#### 8.1 Configuración por Flavor  
```typescript  
// Configuración de entornos  
interface EnvironmentConfig {  
  development: {  
    supabaseUrl: 'https://dev-project.supabase.co',  
    supabaseAnonKey: 'dev-anon-key',  
    enableDebugLogs: true,  
    mockNotifications: true,  
    skipRealPayments: true,  
    enableTestUsers: true  
  },  
    
  production: {  
    supabaseUrl: 'https://prod-project.supabase.co',  
    supabaseAnonKey: 'prod-anon-key',  
    enableDebugLogs: false,  
    mockNotifications: false,  
    skipRealPayments: false,  
    enableTestUsers: false,  
    enableCodeObfuscation: true  
  }  
}  
```

#### 8.2 Políticas de Backup y Seguridad  
```sql  
-- Función de backup corregida para Supabase  
CREATE OR REPLACE FUNCTION backup_critical_data()  
RETURNS json AS $$
DECLARE
    backup_data json;
BEGIN
    SELECT json_build_object(
        'user_profiles', (
            SELECT json_agg(row_to_json(t))   
            FROM (SELECT * FROM user_profiles WHERE updated_at >= NOW() - INTERVAL '24 hours') t
        ),
        'fasting_sessions', (
            SELECT json_agg(row_to_json(t))   
            FROM (SELECT * FROM fasting_sessions WHERE updated_at >= NOW() - INTERVAL '24 hours') t
        ),
        'hydration_logs', (
            SELECT json_agg(row_to_json(t))   
            FROM (SELECT * FROM hydration_logs WHERE created_at >= NOW() - INTERVAL '24 hours') t
        ),
        'timestamp', NOW()
    ) INTO backup_data;
      
    -- Log del backup  
    INSERT INTO system_logs (log_type, message, timestamp)  
    VALUES ('backup', 'Daily backup completed successfully', NOW());  
      
    RETURN backup_data;  
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Edge Function para manejar backups  
-- backup-data.ts  
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"  
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {  
  try {  
    const supabase = createClient(  
      Deno.env.get('SUPABASE_URL') ?? '',  
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  
    )

    const { data: backupData } = await supabase.rpc('backup_critical_data')  
      
    // Enviar a servicio de backup externo (AWS S3, etc.)  
    // await uploadToS3(backupData)  
      
    return new Response(JSON.stringify({  
      success: true,  
      backup_size: JSON.stringify(backupData).length,  
      timestamp: new Date().toISOString()  
    }))

  } catch (error) {  
    return new Response(JSON.stringify({ error: error.message }), {  
      status: 500  
    })  
  }  
})  
```

## 9. Integración con Servicios Externos

> **Resumen:** Integraciones clave con servicios externos como Superwall (paywall), OneSignal (notificaciones) y Sentry (monitoreo de errores y analíticas). Se detalla cómo se conectan y qué lógica se implementa en cada caso.

#### 9.1 Configuración Superwall  
```typescript  
// Webhook handler para eventos de Superwall  
interface SuperwallWebhook {  
  event_type: 'subscription_started' | 'subscription_cancelled' | 'subscription_renewed'  
  user_id: string  
  product_id: 'monthly_premium' | 'yearly_premium'  
  transaction_data: {  
    revenue: number  
    currency: string  
    expires_at: string  
  }  
}

// Edge Function: handle-superwall-webhook  
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"  
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {  
  try {  
    const webhookData: SuperwallWebhook = await req.json()  
      
    const supabase = createClient(  
      Deno.env.get('SUPABASE_URL') ?? '',  
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  
    )  
      
    // Actualizar estado de suscripción del usuario  
    await supabase  
      .from('user_profiles')  
      .update({  
        subscription_status: 'premium',  
        subscription_type: webhookData.product_id,  
        subscription_expires_at: webhookData.transaction_data.expires_at  
      })  
      .eq('id', webhookData.user_id)  
      
    // Registrar evento para analytics  
    await supabase  
      .from('analytics_events')  
      .insert({  
        user_id: webhookData.user_id,  
        event_type: 'subscription_converted',  
        event_data: webhookData.transaction_data  
      })  
        
    return new Response(JSON.stringify({ success: true }))

  } catch (error) {  
    return new Response(JSON.stringify({ error: error.message }), {  
      status: 400  
    })  
  }  
})  
```

#### 9.2 Integración Analíticas y Monitoreo
```typescript  
// Configuración de eventos para Firebase Analytics  
interface AnalyticsEvent {  
  event_name: string  
  parameters: Record<string, any>  
}

const ANALYTICS_EVENTS = {  
  fasting_started: {  
    event_name: 'fasting_session_start',  
    parameters: {  
      plan_type: 'string',  
      planned_duration: 'number',  
      is_first_time: 'boolean'  
    }  
  },  
    
  panic_button_used: {  
    event_name: 'panic_button_activation',  
    parameters: {  
      session_duration_minutes: 'number',  
      meditation_chosen: 'boolean',  
      final_outcome: 'string'  
    }  
  },  
    
  subscription_flow: {  
    event_name: 'subscription_funnel',  
    parameters: {  
      step: 'string', // 'viewed', 'started', 'completed'  
      product_id: 'string',  
      conversion_value: 'number'  
    }  
  }  
}

// Edge Function: track-analytics-event  
serve(async (req) => {  
  try {  
    const { userId, eventType, parameters } = await req.json()  
      
    const supabase = createClient(  
      Deno.env.get('SUPABASE_URL') ?? '',  
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  
    )  
      
    // Guardar evento en Supabase  
    await supabase  
      .from('analytics_events')  
      .insert({  
        user_id: userId,  
        event_type: eventType,  
        event_data: parameters,  
        timestamp: new Date().toISOString()  
      })  
      
    // Enviar a Firebase Analytics (opcional)  
    // await sendToFirebaseAnalytics(eventType, parameters)  
      
    return new Response(JSON.stringify({ success: true }))

  } catch (error) {  
    return new Response(JSON.stringify({ error: error.message }), {  
      status: 400  
    })  
  }  
})  
```

## 10. Configuración Cursor AI Específica

> **Resumen:** Reglas y comandos específicos para mantener la calidad, seguridad y consistencia del backend bajo la filosofía de desarrollo asistido por IA (Cursor AI).

#### 10.1 .cursorrules para Backend  
```  
# Backend Rules para Zendfast

# Seguridad Obligatoria  
- SIEMPRE habilitar Row Level Security en tablas de usuario  
- Validar todos los inputs de usuario server-side  
- Usar políticas RLS granulares por usuario  
- Nunca exponer datos de salud sin autenticación  
- Implementar rate limiting en Edge Functions

# Arquitectura Local-First  
- Diseñar APIs para sincronización batch  
- Implementar resolución de conflictos por timestamp  
- Optimizar para funcionalidad offline  
- Minimizar dependencias de conexión en tiempo real  
- Priorizar datos críticos en sincronización

# Supabase Best Practices    
- Usar Edge Functions para lógica compleja  
- Aprovechar PostgreSQL triggers para validaciones  
- Implementar índices para queries frecuentes  
- Usar JSONB para datos no relacionales  
- Configurar connection pooling apropiadamente

# Analytics y KPIs  
- Trackear métricas de éxito definidas (completion_rate, panic_button_success_rate)  
- Implementar eventos de analytics críticos  
- Separar datos de usuario de métricas agregadas  
- Mantener privacidad en todas las métricas  
- Usar vistas para queries agregadas complejas

# Performance  
- Usar connection pooling  
- Implementar caching para datos estáticos  
- Optimizar queries con EXPLAIN ANALYZE  
- Evitar N+1 queries en relaciones  
- Implementar paginación en listados grandes

# Error Handling  
- Implementar manejo robusto de errores en Edge Functions  
- Logging detallado para debugging  
- Fallbacks para servicios externos  
- Validación de datos en múltiples capas  
- Retry logic para operaciones críticas

# Desarrollo y Testing  
- Usar migraciones para cambios de esquema  
- Implementar seeds para datos de desarrollo  
- Crear tests para Edge Functions críticas  
- Validar políticas RLS con diferentes usuarios  
- Monitorear performance de queries en producción  
```

#### 10.2 Comandos de Validación  
```bash  
# Comandos para validar el esquema y configuración  
supabase db diff --use-migra --schema public  
supabase db lint  
supabase functions deploy --no-verify-jwt  
supabase db reset --linked  
supabase gen types typescript --linked > types/database.ts

# Tests de Edge Functions  
supabase functions serve  
supabase test db  
```

#### 10.3 Estructura de Archivos Sugerida  
```  
/supabase  
  /migrations  
    20240101000000_initial_schema.sql  
    20240102000000_add_rls_policies.sql  
    20240103000000_add_indexes.sql  
  /functions  
    /calculate-user-metrics  
      index.ts  
    /schedule-notifications  
      index.ts  
    /sync-user-data  
      index.ts  
    /handle-superwall-webhook  
      index.ts  
    /backup-data  
      index.ts  
  /seed.sql  
  /tests  
    analytics.test.ts  
    rls.test.ts  
    sync.test.ts  
```

