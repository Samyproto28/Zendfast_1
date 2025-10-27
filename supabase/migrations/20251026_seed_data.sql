-- Migration: Seed initial data
-- Created: 2025-10-26
-- Description: Populate motivational phrases and learning content in Spanish

-- ========================================
-- SEED: Motivational Phrases (Spanish)
-- ========================================

-- Inicio de Ayuno (Start of Fast)
INSERT INTO public.motivational_phrases (phrase_text, category, language) VALUES
('¡Comienza tu viaje hacia una mejor salud! Cada ayuno es un paso adelante.', 'inicio_ayuno', 'es'),
('Hoy es un nuevo día para cuidar tu cuerpo. ¡Vamos!', 'inicio_ayuno', 'es'),
('Tu cuerpo agradecerá este tiempo de descanso digestivo.', 'inicio_ayuno', 'es'),
('Recuerda: el ayuno es un regalo para tu metabolismo.', 'inicio_ayuno', 'es'),
('Iniciando tu ayuno con determinación y esperanza.', 'inicio_ayuno', 'es'),
('Cada ayuno fortalece tu disciplina y salud.', 'inicio_ayuno', 'es'),
('Hoy eliges la salud sobre la comodidad momentánea.', 'inicio_ayuno', 'es'),
('Tu fuerza de voluntad es más poderosa que cualquier antojo.', 'inicio_ayuno', 'es'),
('El ayuno es meditación para el cuerpo.', 'inicio_ayuno', 'es'),
('¡Estás invirtiendo en tu bienestar futuro!', 'inicio_ayuno', 'es'),
('Confía en el proceso. Tu cuerpo sabe qué hacer.', 'inicio_ayuno', 'es'),
('Hoy comienzas con propósito y terminarás con orgullo.', 'inicio_ayuno', 'es'),
('El ayuno es tu aliado, no tu enemigo.', 'inicio_ayuno', 'es'),
('Preparado para activar tu poder metabólico.', 'inicio_ayuno', 'es'),
('Cada hora que pasa es un logro que celebrar.', 'inicio_ayuno', 'es'),
('Tu salud celular está renovándose ahora mismo.', 'inicio_ayuno', 'es'),
('Este ayuno es una inversión en tu longevidad.', 'inicio_ayuno', 'es'),
('Estás construyendo hábitos que transformarán tu vida.', 'inicio_ayuno', 'es'),
('El camino hacia la salud comienza con esta decisión.', 'inicio_ayuno', 'es'),
('Honra tu compromiso contigo mismo. ¡Tú puedes!', 'inicio_ayuno', 'es'),

-- Durante el Ayuno (During Fast)
('Mantén el enfoque. Estás más fuerte de lo que crees.', 'durante_ayuno', 'es'),
('Tu cuerpo está quemando grasa mientras descansas.', 'durante_ayuno', 'es'),
('La autofagia está limpiando tus células ahora mismo.', 'durante_ayuno', 'es'),
('Cada momento de ayuno es sanación profunda.', 'durante_ayuno', 'es'),
('Respira profundo. Esto pasará y te sentirás increíble.', 'durante_ayuno', 'es'),
('Tu mente está más clara cuando tu digestión descansa.', 'durante_ayuno', 'es'),
('Estás entrenando tu metabolismo para ser más eficiente.', 'durante_ayuno', 'es'),
('La sensación de hambre es temporal, tu salud es permanente.', 'durante_ayuno', 'es'),
('Confía en tu cuerpo. Él sabe cómo usar sus reservas.', 'durante_ayuno', 'es'),
('Cada hora es un pequeño triunfo sobre tus impulsos.', 'durante_ayuno', 'es'),
('Tu energía aumentará una vez que pase la adaptación.', 'durante_ayuno', 'es'),
('Estás más cerca de tu meta con cada minuto.', 'durante_ayuno', 'es'),
('El hambre no es emergencia, es solo una señal.', 'durante_ayuno', 'es'),
('Tu sistema inmune se está fortaleciendo ahora.', 'durante_ayuno', 'es'),
('Mantén tu mente ocupada y el tiempo volará.', 'durante_ayuno', 'es'),
('Cada ayuno se vuelve más fácil que el anterior.', 'durante_ayuno', 'es'),
('Tu cuerpo está haciendo una limpieza profunda.', 'durante_ayuno', 'es'),
('La disciplina de hoy es la libertad de mañana.', 'durante_ayuno', 'es'),
('Recuerda por qué comenzaste. Vale la pena.', 'durante_ayuno', 'es'),
('Estás construyendo resistencia mental y física.', 'durante_ayuno', 'es'),
('La incomodidad es temporal, los beneficios son duraderos.', 'durante_ayuno', 'es'),
('Tu nivel de energía se estabilizará pronto.', 'durante_ayuno', 'es'),
('Cada segundo que resistes fortalece tu voluntad.', 'durante_ayuno', 'es'),
('Tu cuerpo está agradecido por este descanso.', 'durante_ayuno', 'es'),
('La claridad mental es uno de los regalos del ayuno.', 'durante_ayuno', 'es'),
('Respeta tu proceso. Cada persona es diferente.', 'durante_ayuno', 'es'),
('Ya has llegado muy lejos. No te rindas ahora.', 'durante_ayuno', 'es'),
('Tu fuerza de voluntad es músculo que estás ejercitando.', 'durante_ayuno', 'es'),
('El ayuno es tu momento de poder personal.', 'durante_ayuno', 'es'),
('Confía en el proceso. Millones lo han logrado.', 'durante_ayuno', 'es'),

-- Finalización de Ayuno (End of Fast)
('¡Lo lograste! Celebra tu disciplina y compromiso.', 'finalizacion_ayuno', 'es'),
('Completaste otro ayuno con éxito. ¡Felicidades!', 'finalizacion_ayuno', 'es'),
('Tu cuerpo te agradece por este tiempo de sanación.', 'finalizacion_ayuno', 'es'),
('Has dado un paso más hacia tus metas de salud.', 'finalizacion_ayuno', 'es'),
('Rompe tu ayuno con gratitud y alimentos nutritivos.', 'finalizacion_ayuno', 'es'),
('Cada ayuno completado es una victoria personal.', 'finalizacion_ayuno', 'es'),
('Siente el orgullo de haber cumplido tu compromiso.', 'finalizacion_ayuno', 'es'),
('Tu disciplina de hoy construye tu futuro saludable.', 'finalizacion_ayuno', 'es'),
('¡Excelente trabajo! Tu cuerpo está renovado.', 'finalizacion_ayuno', 'es'),
('Disfruta tu primera comida con consciencia plena.', 'finalizacion_ayuno', 'es'),
('Has fortalecido tu mente y tu metabolismo.', 'finalizacion_ayuno', 'es'),
('Otro ayuno en tu racha. ¡Sigue así!', 'finalizacion_ayuno', 'es'),
('Tu compromiso con la salud es inspirador.', 'finalizacion_ayuno', 'es'),
('Observa cómo te sientes después de este ayuno.', 'finalizacion_ayuno', 'es'),
('Cada ayuno es más fácil que el anterior.', 'finalizacion_ayuno', 'es'),
('Has demostrado que tienes control sobre tu salud.', 'finalizacion_ayuno', 'es'),
('Celebra con comida real y nutritiva.', 'finalizacion_ayuno', 'es'),
('Tu metabolismo está ahora más eficiente.', 'finalizacion_ayuno', 'es'),
('¡Misión cumplida! Descansa y recupera.', 'finalizacion_ayuno', 'es'),
('Has completado otro ciclo de renovación celular.', 'finalizacion_ayuno', 'es'),

-- General (General Motivation)
('El ayuno intermitente es un estilo de vida, no una dieta.', 'general', 'es'),
('Tu salud es tu mayor riqueza. Invierte en ella.', 'general', 'es'),
('Escucha a tu cuerpo, él es sabio.', 'general', 'es'),
('La consistencia es más importante que la perfección.', 'general', 'es'),
('Cada día es una oportunidad para mejorar.', 'general', 'es'),
('El ayuno te enseña la diferencia entre hambre y aburrimiento.', 'general', 'es'),
('Tu viaje de salud es único. No te compares con otros.', 'general', 'es'),
('Pequeños cambios diarios crean grandes transformaciones.', 'general', 'es'),
('El verdadero cambio comienza desde adentro.', 'general', 'es'),
('Honra tu cuerpo con descanso y nutrición adecuada.', 'general', 'es'),
('La salud metabólica es la base del bienestar.', 'general', 'es'),
('Cada elección saludable suma a tu bienestar total.', 'general', 'es'),
('Tu futuro yo te agradecerá las decisiones de hoy.', 'general', 'es'),
('La paciencia y persistencia traen resultados duraderos.', 'general', 'es'),
('No es solo sobre perder peso, es sobre ganar salud.', 'general', 'es'),
('Tu cuerpo tiene una capacidad increíble de sanarse.', 'general', 'es'),
('Celebra cada pequeño progreso en tu camino.', 'general', 'es'),
('La salud no es un destino, es un viaje continuo.', 'general', 'es'),
('Tu bienestar merece tu tiempo y atención.', 'general', 'es'),
('Confía en el proceso, los resultados llegarán.', 'general', 'es'),

-- Hidratación (Hydration)
('El agua es tu mejor aliada durante el ayuno.', 'hidratacion', 'es'),
('Mantente hidratado. Tu cuerpo necesita agua.', 'hidratacion', 'es'),
('Beber agua ayuda a reducir la sensación de hambre.', 'hidratacion', 'es'),
('La hidratación adecuada optimiza los beneficios del ayuno.', 'hidratacion', 'es'),
('Un vaso de agua puede ser todo lo que necesitas ahora.', 'hidratacion', 'es'),
('El agua purifica y renueva cada célula de tu cuerpo.', 'hidratacion', 'es'),
('Hidratación = Energía. Bebe suficiente agua hoy.', 'hidratacion', 'es'),
('Tu meta de hidratación es importante. ¡Sigue bebiendo!', 'hidratacion', 'es'),
('El té y el café sin azúcar también cuentan.', 'hidratacion', 'es'),
('Mantén una botella de agua siempre contigo.', 'hidratacion', 'es'),
('La sed a veces se confunde con hambre. Hidrátate primero.', 'hidratacion', 'es'),
('El agua ayuda a tu cuerpo a eliminar toxinas.', 'hidratacion', 'es'),
('Bebe agua antes de sentir sed durante el ayuno.', 'hidratacion', 'es'),
('Una buena hidratación mejora tu claridad mental.', 'hidratacion', 'es'),
('El agua es calórica cero y beneficios infinitos.', 'hidratacion', 'es'),
('Tu piel agradece cada vaso de agua que bebes.', 'hidratacion', 'es'),
('Hidrátate consistentemente durante todo el día.', 'hidratacion', 'es'),
('El agua con limón es refrescante y permitida.', 'hidratacion', 'es'),
('La hidratación es clave para un ayuno exitoso.', 'hidratacion', 'es'),
('Agua limpia para un cuerpo limpio.', 'hidratacion', 'es'),

-- Mindfulness (Consciencia Plena)
('Respira profundo y conecta con tu cuerpo.', 'mindfulness', 'es'),
('El presente es todo lo que tienes. Disfrútalo.', 'mindfulness', 'es'),
('Escucha las señales que te envía tu cuerpo.', 'mindfulness', 'es'),
('La meditación complementa perfectamente el ayuno.', 'mindfulness', 'es'),
('Come con consciencia cuando rompas el ayuno.', 'mindfulness', 'es'),
('Observa tus pensamientos sin juzgarlos.', 'mindfulness', 'es'),
('El ayuno es una oportunidad para la introspección.', 'mindfulness', 'es'),
('Agradece a tu cuerpo por todo lo que hace.', 'mindfulness', 'es'),
('Siente gratitud por tu salud y vitalidad.', 'mindfulness', 'es'),
('El momento presente es perfecto tal como es.', 'mindfulness', 'es'),
('Calma tu mente, tu cuerpo te seguirá.', 'mindfulness', 'es'),
('Cada respiración es una oportunidad de renovación.', 'mindfulness', 'es'),
('Conecta con tu propósito más profundo.', 'mindfulness', 'es'),
('La paz interior es tu estado natural.', 'mindfulness', 'es'),
('Observa el hambre sin reaccionar automáticamente.', 'mindfulness', 'es'),
('Tu mente es poderosa. Úsala conscientemente.', 'mindfulness', 'es'),
('El silencio interno nutre tanto como la comida.', 'mindfulness', 'es'),
('Encuentra momentos de quietud en tu día.', 'mindfulness', 'es'),
('La consciencia plena hace cada experiencia más rica.', 'mindfulness', 'es'),
('Honra este momento de cuidado personal.', 'mindfulness', 'es');

-- ========================================
-- SEED: Learning Content (Spanish)
-- ========================================

INSERT INTO public.learning_content (title, content, category, content_type, description, is_premium, author) VALUES
-- Beneficios del Ayuno Intermitente
('¿Qué es el Ayuno Intermitente?',
'El ayuno intermitente (AI) es un patrón alimenticio que alterna entre períodos de ayuno y alimentación. No se trata de qué comer, sino de cuándo comer. Los métodos más populares incluyen:\n\n• 16/8: Ayunar 16 horas, comer en ventana de 8 horas\n• 18/6: Ayunar 18 horas, comer en ventana de 6 horas\n• 20/4: Ayunar 20 horas, comer en ventana de 4 horas\n• 24 horas: Un ayuno completo una o dos veces por semana\n\nEl AI no es una dieta de moda, sino una práctica ancestral que nuestros cuerpos están diseñados para manejar.',
'ayuno_basico', 'article', 'Introducción completa al ayuno intermitente y sus métodos principales', false, 'Dr. Carlos Méndez'),

('Beneficios Científicos del Ayuno Intermitente',
'La investigación ha demostrado múltiples beneficios del ayuno intermitente:\n\n**Salud Metabólica:**\n• Mejora la sensibilidad a la insulina\n• Reduce niveles de azúcar en sangre\n• Ayuda en la pérdida de peso y grasa abdominal\n• Aumenta la hormona del crecimiento humano (HGH)\n\n**Salud Cerebral:**\n• Incrementa el factor neurotrófico derivado del cerebro (BDNF)\n• Mejora la claridad mental y concentración\n• Puede proteger contra enfermedades neurodegenerativas\n\n**Longevidad y Antienvejecimiento:**\n• Activa la autofagia (limpieza celular)\n• Reduce la inflamación crónica\n• Mejora marcadores de longevidad\n• Fortalece el sistema inmunológico',
'beneficios', 'article', 'Evidencia científica de los beneficios del ayuno intermitente', false, 'Dra. María González'),

('La Ciencia de la Autofagia',
'La autofagia, que significa "comerse a sí mismo", es un proceso celular de limpieza que se activa durante el ayuno.\n\n**¿Qué es la Autofagia?**\nEs el proceso mediante el cual las células reciclan componentes dañados o innecesarios. Piensa en ello como el sistema de reciclaje del cuerpo.\n\n**Cuándo se Activa:**\n• Generalmente comienza después de 12-16 horas de ayuno\n• Se intensifica con ayunos más prolongados\n• El ejercicio también puede estimularla\n\n**Beneficios:**\n• Eliminación de proteínas dañadas\n• Renovación celular\n• Protección contra enfermedades\n• Antienvejecimiento a nivel celular\n\nEl científico Yoshinori Ohsumi ganó el Premio Nobel en 2016 por descubrir los mecanismos de la autofagia.',
'ciencia', 'article', 'Comprende el proceso de autofagia y su importancia para la salud', false, 'Dr. Pablo Ramírez'),

('Cómo Comenzar con el Método 16/8',
'El método 16/8 es ideal para principiantes en el ayuno intermitente.\n\n**Paso 1: Elige tu Ventana de Alimentación**\n• Ejemplo: 12:00 PM a 8:00 PM\n• Ajusta según tu horario y preferencias\n\n**Paso 2: Comienza Gradualmente**\n• Semana 1: Ayuno de 12 horas\n• Semana 2: Aumenta a 14 horas\n• Semana 3: Alcanza las 16 horas\n\n**Paso 3: Qué Consumir Durante el Ayuno**\n• Agua (ilimitada)\n• Té negro o verde sin azúcar\n• Café negro (sin leche ni azúcar)\n• Agua con limón\n\n**Paso 4: Rompe el Ayuno Correctamente**\n• Comienza con algo ligero\n• Evita alimentos procesados\n• Hidrátate bien\n\n**Consejos:**\n• Mantén un horario consistente\n• Escucha a tu cuerpo\n• Sé paciente con la adaptación',
'guias_practicas', 'guide', 'Guía paso a paso para comenzar con el ayuno 16/8', false, 'Nutricionista Ana López'),

('Hidratación Durante el Ayuno',
'La hidratación adecuada es crucial para el éxito del ayuno intermitente.\n\n**¿Por Qué es Importante?**\n• Mantiene el metabolismo activo\n• Reduce la sensación de hambre\n• Ayuda a eliminar toxinas\n• Previene dolores de cabeza\n• Mantiene la energía\n\n**Cuánta Agua Necesitas:**\n• Mínimo 2-3 litros al día\n• Más si haces ejercicio\n• Aumenta en clima cálido\n\n**Bebidas Permitidas Durante el Ayuno:**\n✅ Agua pura\n✅ Agua con gas sin sabor\n✅ Té verde, negro, de hierbas\n✅ Café negro\n✅ Agua con limón\n\n**Bebidas que Rompen el Ayuno:**\n❌ Jugos de frutas\n❌ Leche o bebidas lácteas\n❌ Bebidas deportivas\n❌ Refrescos (incluso dietéticos controversiales)\n❌ Cualquier bebida con calorías\n\n**Consejo:** Lleva siempre una botella de agua contigo.',
'hidratacion', 'article', 'Todo sobre la hidratación correcta durante el ayuno', false, 'Dra. Laura Sánchez'),

('Errores Comunes en el Ayuno Intermitente',
'Evita estos errores frecuentes para maximizar tus resultados:\n\n**Error 1: Comer en Exceso Durante la Ventana**\nSolución: Mantén porciones normales y saludables\n\n**Error 2: No Hidratarse Suficientemente**\nSolución: Bebe 2-3 litros de agua diariamente\n\n**Error 3: Consumir Calorías "Ocultas"**\nSolución: Revisa que tu café/té sea realmente sin calorías\n\n**Error 4: No Ser Consistente**\nSolución: Mantén un horario regular\n\n**Error 5: Ignorar la Calidad de los Alimentos**\nSolución: Come alimentos nutritivos y reales\n\n**Error 6: Hacer Demasiado Ejercicio Intenso**\nSolución: Adapta tu ejercicio a tu nivel de energía\n\n**Error 7: No Escuchar al Cuerpo**\nSolución: Si te sientes muy mal, rompe el ayuno\n\n**Error 8: Esperar Resultados Inmediatos**\nSolución: Dale a tu cuerpo 2-4 semanas para adaptarse',
'consejos', 'article', 'Los errores más comunes y cómo evitarlos', false, 'Coach Luis Torres'),

('Ayuno y Ejercicio: La Combinación Perfecta',
'Cómo combinar el ayuno intermitente con tu rutina de ejercicio.\n\n**Ejercicio en Ayunas: Beneficios**\n• Mayor quema de grasa\n• Aumento de la hormona del crecimiento\n• Mejora de la sensibilidad a la insulina\n• Mayor eficiencia metabólica\n\n**Mejores Ejercicios en Ayunas:**\n✅ Cardio ligero a moderado\n✅ Caminata\n✅ Yoga\n✅ Pilates\n✅ Entrenamiento con pesas ligeras\n\n**Ejercicios para Después de Romper el Ayuno:**\n• Entrenamiento de fuerza intenso\n• HIIT (Entrenamiento de Intervalos de Alta Intensidad)\n• Ejercicios de larga duración\n\n**Consejos Importantes:**\n1. Escucha a tu cuerpo\n2. Hidrátate bien antes, durante y después\n3. Empieza con ejercicio ligero\n4. No te fuerces si te sientes débil\n5. Considera electrolitos para ejercicio intenso\n\n**Cuándo Entrenar:**\n• Al final del ayuno (antes de romperlo)\n• O después de tu primera comida',
'ejercicio', 'article', 'Guía para combinar ejercicio y ayuno de manera efectiva', false, 'Entrenador Miguel Herrera'),

('Qué Comer al Romper el Ayuno',
'La primera comida después del ayuno es crucial para tu salud.\n\n**Principios Básicos:**\n1. Comienza con algo ligero\n2. Mastica despacio\n3. Escucha las señales de saciedad\n4. Prioriza nutrientes de calidad\n\n**Mejores Alimentos para Romper el Ayuno:**\n\n**Proteínas:**\n• Huevos\n• Pescado\n• Pollo\n• Legumbres\n• Yogur natural\n\n**Grasas Saludables:**\n• Aguacate\n• Nueces y semillas\n• Aceite de oliva\n• Salmón\n\n**Carbohidratos Complejos:**\n• Quinoa\n• Arroz integral\n• Batata\n• Avena\n\n**Verduras:**\n• Vegetales de hoja verde\n• Brócoli\n• Zanahorias\n• Pimientos\n\n**Alimentos a Evitar:**\n❌ Comida procesada\n❌ Azúcares refinados\n❌ Comida rápida\n❌ Alimentos muy pesados\n\n**Ejemplo de Primera Comida:**\nEnsalada de vegetales + salmón + aguacate + quinoa',
'nutricion', 'article', 'Guía completa sobre qué comer al finalizar el ayuno', false, 'Nutricionista Carmen Ruiz'),

('El Ayuno y tu Ciclo Circadiano',
'Entender cómo el ayuno interactúa con tu ritmo biológico natural.\n\n**¿Qué es el Ritmo Circadiano?**\nEs el reloj interno de 24 horas que regula:\n• Sueño y vigilia\n• Producción de hormonas\n• Metabolismo\n• Temperatura corporal\n\n**Alineación del Ayuno con tu Ritmo:**\n• Ayunar durante la noche es natural\n• Extender el ayuno matinal potencia beneficios\n• Comer temprano en el día mejora metabolismo\n\n**Ventana de Alimentación Óptima:**\n• Idealmente: 8:00 AM - 4:00 PM\n• Alternativa popular: 12:00 PM - 8:00 PM\n• Lo importante: consistencia\n\n**Beneficios de Alineación:**\n• Mejor calidad de sueño\n• Mayor pérdida de peso\n• Mejora en digestión\n• Más energía durante el día\n\n**Melatonina y Digestión:**\n• Evita comer 3 horas antes de dormir\n• La melatonina inhibe la producción de insulina\n• Comer tarde afecta la calidad del sueño',
'ciencia', 'article', 'Cómo optimizar el ayuno según tu reloj biológico', false, 'Dr. Javier Ortiz'),

('Ayuno Intermitente para Mujeres',
'Consideraciones especiales del ayuno para mujeres.\n\n**Diferencias Hormonales:**\nLas mujeres tienen ciclos hormonales que pueden verse afectados por el ayuno.\n\n**Recomendaciones Específicas:**\n• Comienza con ventanas más cortas (14/10)\n• Sé flexible con tu ciclo menstrual\n• No ayunes durante menstruación si te sientes débil\n• Escucha señales de amenorrea\n\n**Beneficios para Mujeres:**\n• Regulación hormonal\n• Mejora del SOP (Síndrome de Ovario Poliquístico)\n• Reducción de inflamación\n• Mejor sensibilidad a la insulina\n\n**Precauciones:**\n❌ No durante embarazo\n❌ No durante lactancia\n❌ Consulta médico si tienes desórdenes hormonales\n❌ Suspende si pierdes el período\n\n**Signos de que Debes Ajustar:**\n• Pérdida del período\n• Extrema fatiga\n• Insomnio severo\n• Pérdida de cabello\n• Ansiedad extrema\n\n**Consejo:** El ayuno más suave (14-16h) suele ser ideal para mujeres.',
'salud_femenina', 'article', 'Guía del ayuno intermitente específica para mujeres', false, 'Dra. Isabel Fernández'),

('Mindfulness y Ayuno',
'Cómo la práctica de mindfulness potencia los beneficios del ayuno.\n\n**Qué es Mindfulness:**\nAtención plena al momento presente sin juicio.\n\n**Beneficios de Combinar Mindfulness con Ayuno:**\n• Reduce la ansiedad por comer\n• Ayuda a distinguir hambre real de emocional\n• Mejora la experiencia del ayuno\n• Aumenta la consciencia corporal\n\n**Prácticas de Mindfulness Durante el Ayuno:**\n\n**1. Respiración Consciente:**\n• 5 minutos, 3 veces al día\n• Inhala 4 segundos, exhala 6 segundos\n• Calma el sistema nervioso\n\n**2. Escaneo Corporal:**\n• Observa sensaciones sin reaccionar\n• Diferencia hambre de incomodidad\n• Conecta con tu cuerpo\n\n**3. Meditación de Gratitud:**\n• Agradece a tu cuerpo\n• Reconoce tu fortaleza\n• Celebra pequeños logros\n\n**4. Alimentación Consciente:**\n• Come despacio al romper el ayuno\n• Saborea cada bocado\n• Nota señales de saciedad\n\n**Ejercicio Práctico:**\nCuando sientas hambre, pausa 5 minutos. Respira profundo. Pregúntate: ¿Es hambre real o emocional?',
'mindfulness', 'article', 'Integra mindfulness en tu práctica de ayuno', false, 'Psicóloga Andrea Vega'),

('Superando las Primeras Semanas',
'Guía para atravesar el período de adaptación inicial.\n\n**Qué Esperar: Semana 1-2**\n• Hambre intensa\n• Irritabilidad\n• Fatiga\n• Dificultad de concentración\n• Dolores de cabeza leves\n\n**Esto es NORMAL - Tu cuerpo se está adaptando**\n\n**Estrategias para la Adaptación:**\n\n**Física:**\n• Bebe mucha agua\n• Duerme suficiente\n• Reduce ejercicio intenso temporalmente\n• Considera electrolitos\n\n**Mental:**\n• Mantén ocupada tu mente\n• Ten un hobby para las horas difíciles\n• Únete a comunidades de apoyo\n• Lleva un diario de progreso\n\n**Semana 3-4: El Punto de Inflexión**\n• El hambre disminuye\n• Aumenta la energía\n• Mejora la claridad mental\n• Se siente más natural\n\n**Después del Mes:**\n• El ayuno se vuelve hábito\n• Beneficios se hacen evidentes\n• Te sientes en control\n\n**Consejo Clave:** La adaptación metabólica toma tiempo. Sé paciente contigo mismo.',
'guias_practicas', 'guide', 'Cómo superar exitosamente las primeras semanas del ayuno', false, 'Coach Roberto Díaz'),

('Ayuno y Salud Intestinal',
'El impacto del ayuno en tu microbioma y digestión.\n\n**Beneficios Digestivos del Ayuno:**\n• Descanso para el sistema digestivo\n• Reducción de inflamación intestinal\n• Mejora de la diversidad del microbioma\n• Regeneración del revestimiento intestinal\n• Reducción de permeabilidad intestinal\n\n**La Autofagia y el Intestino:**\nDurante el ayuno, la autofagia limpia células dañadas del tracto digestivo, promoviendo la regeneración.\n\n**Mejorando la Salud Intestinal:**\n\n**Durante el Ayuno:**\n• Bebe agua abundante\n• Considera té de jengibre para digestión\n• Té de menta para calmar el estómago\n\n**Al Romper el Ayuno:**\n• Incluye probióticos (yogur, kéfir)\n• Come prebióticos (ajo, cebolla, plátano verde)\n• Agrega fibra gradualmente\n• Alimentos fermentados (chucrut, kimchi)\n\n**Alimentos Post-Ayuno para el Intestino:**\n✅ Caldo de huesos\n✅ Yogur natural\n✅ Vegetales cocidos\n✅ Frutas bajas en azúcar\n✅ Granos enteros\n\n**Señales de Mejora:**\n• Menos hinchazón\n• Digestión más regular\n• Menos gases\n• Más energía',
'salud_digestiva', 'article', 'Cómo el ayuno mejora tu salud intestinal', false, 'Dr. Fernando Castro'),

('Electrolitos Durante el Ayuno',
'Mantén el balance de electrolitos para un ayuno exitoso.\n\n**¿Qué son los Electrolitos?**\nMinerales esenciales que conducen impulsos eléctricos en el cuerpo:\n• Sodio\n• Potasio\n• Magnesio\n• Calcio\n\n**Por Qué son Importantes en el Ayuno:**\n• Previenen dolores de cabeza\n• Mantienen energía\n• Evitan calambres musculares\n• Regulan hidratación\n• Mantienen función nerviosa\n\n**Señales de Deficiencia:**\n• Fatiga extrema\n• Calambres musculares\n• Dolores de cabeza\n• Mareos\n• Palpitaciones\n\n**Cómo Obtener Electrolitos (Sin Romper el Ayuno):**\n\n**Sodio:**\n• Sal del Himalaya en agua\n• Caldo de huesos (mínimas calorías)\n• Sal marina\n\n**Potasio:**\n• Sal de potasio (\"sal lite\")\n• Agua de coco (rompe ayuno, usar al finalizar)\n\n**Magnesio:**\n• Suplemento de magnesio\n• Agua mineral rica en magnesio\n\n**Receta de "Agua de Serpiente":**\n• 2L de agua\n• 1/2 cucharadita de sal del Himalaya\n• 1 cucharadita de cloruro de potasio\n• 1/2 cucharadita de bicarbonato de sodio\n• Opcional: jugo de limón',
'nutricion', 'article', 'Guía completa sobre electrolitos durante el ayuno', false, 'Nutricionista Patricia Morales'),

('El Ayuno y tu Metabolismo',
'Desmintiendo mitos sobre el ayuno y el metabolismo.\n\n**Mito: El Ayuno Ralentiza el Metabolismo**\n**Realidad:** El ayuno intermitente puede AUMENTAR el metabolismo en un 3.6-14% en estudios a corto plazo.\n\n**Cómo el Ayuno Afecta el Metabolismo:**\n\n**Fase 1 (0-4 horas):**\n• Digestión de última comida\n• Glucosa como energía principal\n\n**Fase 2 (4-16 horas):**\n• Agotamiento de glucógeno\n• Inicio de quema de grasa\n• Aumento de norepinefrina\n\n**Fase 3 (16-24 horas):**\n• Cetosis leve\n• Máxima quema de grasa\n• Aumento de HGH (hormona crecimiento)\n\n**Fase 4 (24+ horas):**\n• Cetosis profunda\n• Autofagia intensa\n• Máxima eficiencia metabólica\n\n**Adaptaciones Metabólicas Positivas:**\n• Flexibilidad metabólica mejorada\n• Mejor sensibilidad a insulina\n• Mayor capacidad de quemar grasa\n• Preservación de masa muscular\n\n**Cuándo Preocuparse:**\nSolo ayunos prolongados (>72h) repetidos pueden afectar metabolismo.',
'ciencia', 'article', 'La verdad sobre el ayuno y el metabolismo', false, 'Dr. Andrés Silva'),

('Ayuno Intermitente y Sueño',
'La conexión entre el ayuno y la calidad de tu descanso.\n\n**Beneficios del Ayuno para el Sueño:**\n• Mejora la calidad del sueño profundo\n• Aumenta la producción de melatonina\n• Regula el ritmo circadiano\n• Reduce interrupciones nocturnas\n\n**Mejores Prácticas:**\n\n**Timing de la Última Comida:**\n• Come 3-4 horas antes de dormir\n• Evita cenas pesadas\n• Permite digestión completa\n\n**Durante el Ayuno Nocturno:**\n• El cuerpo repara y regenera\n• La autofagia trabaja intensamente\n• La hormona del crecimiento se eleva\n\n**Consejos para Mejor Sueño:**\n1. Mantén horario consistente\n2. Evita cafeína después de 2 PM\n3. Oscurece tu habitación\n4. Temperatura fresca (18-20°C)\n5. Sin pantallas 1 hora antes de dormir\n\n**Si el Ayuno Afecta tu Sueño:**\n• Ajusta tu ventana de alimentación\n• Come más temprano en el día\n• Asegura suficientes calorías\n• Considera magnesio antes de dormir\n\n**Señales de Buen Ajuste:**\n• Despiertas energizado\n• Duermes toda la noche\n• Sueños vívidos\n• No necesitas alarma',
'salud_general', 'article', 'Optimiza tu sueño con el ayuno intermitente', false, 'Dr. Ricardo Navarro'),

('Ayuno y Control de Peso',
'Cómo el ayuno intermitente ayuda en la gestión del peso de forma sostenible.\n\n**Mecanismos de Pérdida de Peso:**\n\n**1. Restricción Calórica Natural:**\n• Menos ventana para comer = menos calorías\n• Sin contar calorías obsesivamente\n\n**2. Cambio Hormonal:**\n• Reducción de insulina → quema de grasa\n• Aumento de norepinefrina → metabolismo\n• Aumento de HGH → preserva músculo\n\n**3. Quema de Grasa Mejorada:**\n• Acceso a reservas de grasa\n• Cetosis leve\n• Flexibilidad metabólica\n\n**Expectativas Realistas:**\n• Semana 1-2: Pérdida de agua (1-3 kg)\n• Semana 3-4: Inicio de pérdida de grasa\n• Mes 2-3: Resultados consistentes\n• Promedio: 0.5-1 kg por semana\n\n**NO es una Solución Rápida:**\nEl ayuno es un estilo de vida, no una dieta temporal.\n\n**Factores que Influyen:**\n• Composición de alimentos\n• Nivel de actividad\n• Estrés y sueño\n• Metabolismo basal\n• Consistencia\n\n**Consejo Importante:**\nNo te obsesiones con la balanza. Mide también:\n• Cómo te queda la ropa\n• Niveles de energía\n• Claridad mental\n• Análisis de sangre\n\n**Mesetas son Normales:**\nTu cuerpo se adapta. Sé paciente.',
'perdida_peso', 'article', 'Guía científica sobre ayuno y control de peso', false, 'Nutricionista Elena Vargas'),

('Rompiendo el Ayuno: Recetas Saludables',
'Recetas nutritivas y deliciosas para romper tu ayuno.\n\n**Receta 1: Bowl de Aguacate y Huevo**\nIngredientes:\n• 2 huevos\n• 1/2 aguacate\n• Espinacas frescas\n• Tomates cherry\n• Aceite de oliva\n• Sal y pimienta\n\nPreparación:\n1. Saltea espinacas ligeramente\n2. Prepara huevos al gusto\n3. Sirve con aguacate en rodajas\n4. Decora con tomates\n\n**Receta 2: Salmón con Quinoa**\nIngredientes:\n• 150g salmón\n• 1/2 taza quinoa cocida\n• Brócoli al vapor\n• Limón\n• Aceite de oliva\n\nPreparación:\n1. Cocina salmón a la plancha\n2. Prepara quinoa\n3. Saltea brócoli\n4. Combina y rocía con limón\n\n**Receta 3: Ensalada Completa**\nIngredientes:\n• Mezcla de lechugas\n• Pechuga de pollo\n• Nueces\n• Arándanos\n• Queso feta\n• Vinagreta casera\n\n**Receta 4: Bowl de Yogur Griego**\nIngredientes:\n• Yogur griego natural\n• Frutos rojos\n• Nueces\n• Semillas de chía\n• Miel (poca cantidad)\n\n**Receta 5: Vegetales Asados con Hummus**\nIngredientes:\n• Pimientos, calabacín, berenjena\n• Hummus casero\n• Aceite de oliva\n• Especias',
'recetas', 'recipe', 'Recetas nutritivas para romper el ayuno correctamente', false, 'Chef Mónica Reyes'),

('Preguntas Frecuentes sobre Ayuno',
'Respuestas a las dudas más comunes sobre el ayuno intermitente.\n\n**¿Puedo tomar café durante el ayuno?**\nSí, café negro sin azúcar ni leche. La cafeína puede ayudar con el hambre.\n\n**¿El ayuno causa pérdida de músculo?**\nNo, si mantienes suficiente proteína y ejercicio. El HGH protege el músculo.\n\n**¿Puedo hacer ejercicio en ayunas?**\nSí, pero empieza con ejercicio ligero y aumenta gradualmente.\n\n**¿Cuánta agua debo beber?**\nMínimo 2-3 litros al día, más si haces ejercicio.\n\n**¿El ayuno es seguro?**\nPara la mayoría de adultos sanos, sí. Consulta médico si tienes condiciones preexistentes.\n\n**¿Cuánto tiempo toma ver resultados?**\n2-4 semanas para adaptación, 2-3 meses para resultados evidentes.\n\n**¿Puedo ayunar todos los días?**\nSí, el ayuno intermitente diario es seguro y sostenible.\n\n**¿Qué hago si me siento mal?**\nRompe el ayuno. Escucha siempre a tu cuerpo.\n\n**¿El ayuno afecta mi metabolismo?**\nNo negativamente. Puede mejorarlo en ayunos de 24-48h.\n\n**¿Necesito suplementos?**\nGeneralmente no, pero electrolitos pueden ayudar.',
'faq', 'article', 'Respuestas a preguntas frecuentes sobre el ayuno', false, 'Dr. Sergio Campos'),

('Ayuno para Principiantes: Plan de 4 Semanas',
'Programa estructurado para comenzar el ayuno intermitente de forma segura.\n\n**SEMANA 1: Adaptación Suave**\n• Ayuno de 12 horas (12/12)\n• Ejemplo: Cena a 8 PM, desayuno a 8 AM\n• Enfoque: Acostumbrar al cuerpo\n• Meta: Completar 5 de 7 días\n\n**SEMANA 2: Incremento Gradual**\n• Ayuno de 14 horas (14/10)\n• Ejemplo: Cena a 8 PM, desayuno a 10 AM\n• Enfoque: Aumentar gradualmente\n• Meta: Completar 6 de 7 días\n\n**SEMANA 3: Alcanzando el Ritmo**\n• Ayuno de 16 horas (16/8)\n• Ejemplo: Cena a 8 PM, almuerzo a 12 PM\n• Enfoque: Establecer rutina\n• Meta: Completar todos los días\n\n**SEMANA 4: Consolidación**\n• Mantener 16/8\n• Experimentar con diferentes ventanas\n• Observar cómo te sientes\n• Ajustar según necesites\n\n**Checklist Diario:**\n□ Beber 2-3L de agua\n□ Dormir 7-8 horas\n□ Ejercicio ligero (caminata)\n□ Registrar cómo te sientes\n□ Planificar comidas saludables\n\n**Señales de Éxito:**\n✓ Mayor energía\n✓ Mejor concentración\n✓ Ropa más holgada\n✓ Mejor digestión\n✓ Más confianza',
'guias_practicas', 'guide', 'Plan estructurado de 4 semanas para principiantes', false, 'Coach Daniela Ríos'),

('Ayuno y Longevidad: La Ciencia del Antienvejecimiento',
'Cómo el ayuno puede extender tu vida saludable.\n\n**Evidencia Científica:**\nEstudios en múltiples organismos muestran que la restricción calórica y el ayuno pueden extender la vida.\n\n**Mecanismos de Longevidad:**\n\n**1. Activación de Sirtuinas:**\n• Proteínas que regulan el envejecimiento\n• Se activan durante el ayuno\n• Protegen el ADN\n\n**2. Reducción de IGF-1:**\n• Factor de crecimiento similar a insulina\n• Niveles altos = envejecimiento acelerado\n• El ayuno reduce IGF-1\n\n**3. Autofagia Intensificada:**\n• Limpieza de células dañadas\n• Regeneración celular\n• Prevención de enfermedades\n\n**4. Reducción de Estrés Oxidativo:**\n• Menos radicales libres\n• Menor daño celular\n• Protección de mitocondrias\n\n**5. Mejora de Marcadores de Salud:**\n• Presión arterial\n• Colesterol\n• Glucosa en sangre\n• Inflamación\n\n**Estudios en Humanos:**\n• Reducción de marcadores de envejecimiento\n• Mejora en longevidad celular\n• Aumento en calidad de vida\n\n**El Concepto de Healthspan:**\nNo solo vivir más, sino vivir mejor por más tiempo.',
'longevidad', 'article', 'La ciencia detrás del ayuno y la longevidad', true, 'Dr. Alberto Mendoza');

-- Add a few premium content examples
UPDATE public.learning_content
SET is_premium = true
WHERE title IN ('Ayuno y Longevidad: La Ciencia del Antienvejecimiento');
