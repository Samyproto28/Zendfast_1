  
Documento 4: Frontend Guidelines Document \- Zendfast

1\. Información General de Frontend

> **Resumen:** Esta sección introduce los principios generales del frontend de Zendfast, incluyendo framework, orientación, accesibilidad y filosofía de diseño. Es la base conceptual para el resto de las guías.

Aplicación: Zendfast    
Framework: Flutter    
Paradigma de Diseño: Material 3 \+ Custom Design System    
Orientación: Portrait Only    
Accesibilidad: WCAG 2.1 AA Compliance  

2\. Sistema de Colores

> **Resumen:** Define la paleta de colores principal, temas claro/oscuro y su uso semántico en la app. Garantiza coherencia visual y accesibilidad cromática.

2.1 Paleta Principal  
\`\`\`dart  
// Colores Principales  
class ZendfastColors {  
  // Colores Primarios  
  static const Color primary \= Color(0xFF069494);        // Teal Equilibrado  
  static const Color secondary \= Color(0xFF7fb069);      // Verde Natural    
  static const Color accent \= Color(0xFFffb366);         // Naranja Cálido  
    
  // Modo Claro  
  static const Color lightBackground \= Color(0xFFf8f9fa);     // Blanco Cálido  
  static const Color lightTextPrimary \= Color(0xFF495057);    // Gris Profesional  
  static const Color lightTextSecondary \= Color(0xFF6c757d);  // Gris Suave  
    
  // Modo Oscuro  
  static const Color darkBackground \= Color(0xFF121212);      // Negro Absoluto  
  static const Color darkSurface \= Color(0xFF2a2a2a);       // Gris Profundo  
  static const Color darkTextPrimary \= Color(0xFFffffff);    // Blanco Puro  
  static const Color darkTextSecondary \= Color(0xFFb3b3b3);  // Gris Claro  
    
  // Estados Semánticos  
  static const Color success \= Color(0xFF7fb069);        // Verde Natural  
  static const Color error \= Color(0xFFE57373);          // Rojo Suave  
  static const Color warning \= Color(0xFFFFC107);        // Ámbar  
}  
\`\`\`

2.2 Sistema de Temas  
\`\`\`dart  
// ThemeData Configuration  
class ZendfastTheme {  
  static ThemeData lightTheme \= ThemeData(  
    brightness: Brightness.light,  
    primaryColor: ZendfastColors.primary,  
    backgroundColor: ZendfastColors.lightBackground,  
    // Configuración completa del tema...  
  );  
    
  static ThemeData darkTheme \= ThemeData(  
    brightness: Brightness.dark,  
    primaryColor: ZendfastColors.primary,  
    backgroundColor: ZendfastColors.darkBackground,  
    // Configuración completa del tema...  
  );  
}  
\`\`\`

3\. Sistema Tipográfico

> **Resumen:** Especifica las fuentes, jerarquía y estilos tipográficos para mantener la identidad visual y la legibilidad en toda la app.

3.1 Fuentes Principales  
\`\`\`dart  
class ZendfastTypography {  
  // Fuentes Base  
  static const String uiFont \= 'Inter';           // UI y Cabeceras  
  static const String bodyFont \= 'Source Sans Pro'; // Cuerpo de texto  
  static const String emphasisFont \= 'Nunito Sans'; // Énfasis emocional  
    
  // Jerarquía Tipográfica  
  static const TextStyle heading1 \= TextStyle(  
    fontFamily: uiFont,  
    fontSize: 32,  
    fontWeight: FontWeight.bold,  
    height: 1.2,  
  );  
    
  static const TextStyle heading2 \= TextStyle(  
    fontFamily: uiFont,  
    fontSize: 24,  
    fontWeight: FontWeight.bold,  
    height: 1.3,  
  );  
    
  static const TextStyle bodyLarge \= TextStyle(  
    fontFamily: bodyFont,  
    fontSize: 16,  
    fontWeight: FontWeight.normal,  
    height: 1.5,  
  );  
    
  static const TextStyle bodyMedium \= TextStyle(  
    fontFamily: bodyFont,  
    fontSize: 14,  
    fontWeight: FontWeight.normal,  
    height: 1.4,  
  );  
    
  static const TextStyle emphasis \= TextStyle(  
    fontFamily: emphasisFont,  
    fontSize: 16,  
    fontWeight: FontWeight.w600,  
    height: 1.3,  
  );  
}  
\`\`\`

4\. Sistema de Espaciado

> **Resumen:** Establece el sistema de espaciado y márgenes basado en una cuadrícula de 8px, asegurando consistencia y armonía visual.

4.1 Espaciado Base  
\`\`\`dart  
class ZendfastSpacing {  
  // Sistema de cuadrícula 8px  
  static const double xs \= 4.0;  
  static const double sm \= 8.0;  
  static const double md \= 16.0;  
  static const double lg \= 24.0;  
  static const double xl \= 32.0;  
  static const double xxl \= 40.0;  
    
  // Espaciado Específico  
  static const double screenMargin \= 16.0;    // Márgenes de pantalla  
  static const double screenMarginLarge \= 24.0;  
  static const double componentSpacing \= 16.0; // Entre componentes  
  static const double cardPadding \= 16.0;     // Padding interno tarjetas  
  static const double buttonPaddingH \= 16.0;  // Padding horizontal botones  
  static const double buttonPaddingV \= 12.0;  // Padding vertical botones  
}  
\`\`\`

5\. Sistema de Superficies

> **Resumen:** Define radios de borde, elevaciones y sombras para superficies, tarjetas y botones, aportando profundidad y jerarquía visual.

5.1 Radios de Borde  
\`\`\`dart  
class ZendfastRadius {  
  static const double small \= 8.0;     // Campos de entrada  
  static const double medium \= 12.0;   // Chips/Tags  
  static const double large \= 16.0;    // Botones y tarjetas principales  
  static const double xlarge \= 24.0;   // Modales y overlays  
}  
\`\`\`

5.2 Elevaciones y Sombras  
\`\`\`dart  
class ZendfastElevation {  
  // Elevaciones Material 3  
  static const double low \= 2.0;       // Tarjetas de información  
  static const double medium \= 4.0;    // Botón de pánico, modales  
  static const double high \= 8.0;      // Elementos flotantes  
    
  // BoxShadow personalizadas  
  static List\<BoxShadow\> cardShadow \= \[  
    BoxShadow(  
      color: Colors.black.withOpacity(0.1),  
      blurRadius: 4,  
      offset: Offset(0, 2),  
    ),  
  \];  
    
  static List\<BoxShadow\> buttonShadow \= \[  
    BoxShadow(  
      color: Colors.black.withOpacity(0.15),  
      blurRadius: 6,  
      offset: Offset(0, 3),  
    ),  
  \];  
}  
\`\`\`

6\. Componentes Reutilizables

> **Resumen:** Incluye patrones y ejemplos de componentes clave (botones, cards, timer) para promover la reutilización y coherencia en la UI.

6.1 Sistema de Botones  
\`\`\`dart  
// Primary Button  
/// Botón principal reutilizable. Usa null safety y required.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ZendfastColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: ZendfastSpacing.buttonPaddingH,
          vertical: ZendfastSpacing.buttonPaddingV,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZendfastRadius.large),
        ),
        elevation: ZendfastElevation.medium,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text, style: ZendfastTypography.emphasis),
    );
  }
}

// Panic Button  
/// Botón de pánico destacado. Usa null safety y required.
class PanicButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PanicButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: ZendfastColors.accent,
      foregroundColor: Colors.white,
      elevation: ZendfastElevation.high,
      label: Text('PÁNICO', style: ZendfastTypography.emphasis),
      icon: Icon(Icons.warning_rounded, size: 24),
    );
  }
}  
\`\`\`

6.2 Cards y Containers  
\`\`\`dart  
/// Card de información reutilizable. Usa null safety y required.
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const InfoCard({Key? key, required this.child, this.padding, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(ZendfastSpacing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ZendfastRadius.large),
        boxShadow: ZendfastElevation.cardShadow,
      ),
      child: child,
    );
  }
}  
\`\`\`

6.3 Timer Display  
\`\`\`dart  
/// Widget para mostrar el temporizador de ayuno. Usa null safety y required.
class TimerDisplay extends StatelessWidget {
  final Duration timeRemaining;
  final bool isActive;
  final Color? color;

  const TimerDisplay({Key? key, required this.timeRemaining, required this.isActive, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hours = timeRemaining.inHours;
    final minutes = (timeRemaining.inMinutes % 60);
    final seconds = (timeRemaining.inSeconds % 60);

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      child: Column(
        children: [
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: ZendfastTypography.heading1.copyWith(
              color: isActive ? (color ?? ZendfastColors.accent) : ZendfastColors.lightTextSecondary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isActive ? 'Tiempo restante' : 'Inactivo',
            style: ZendfastTypography.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.caption?.color,
            ),
          ),
        ],
      ),
    );
  }
}  
\`\`\`

7\. Sistema de Estados

> **Resumen:** Define los estados visuales y de interacción de los componentes (pressed, disabled, loading) y los patrones de feedback visual (snackbars, errores, éxito).

7.1 Estados de Componentes  
\`\`\`dart  
class ComponentStates {  
  // Press State (Overlay al tocar)  
  static Color getPressOverlay() \=\> Colors.black.withOpacity(0.1);  
    
  // Disabled State  
  static Color getDisabledBackground() \=\> ZendfastColors.lightTextPrimary.withOpacity(0.2);  
  static Color getDisabledText() \=\> ZendfastColors.lightTextPrimary.withOpacity(0.5);  
    
  // Loading State  
  static Widget getLoadingIndicator({Color color}) {  
    return CircularProgressIndicator(  
      strokeWidth: 2,  
      valueColor: AlwaysStoppedAnimation\<Color\>(color ?? ZendfastColors.primary),  
    );  
  }  
}  
\`\`\`

7.2 Feedback Visual  
\`\`\`dart  
class FeedbackSystem {  
  // SnackBar de éxito  
  static void showSuccess(BuildContext context, String message) {  
    ScaffoldMessenger.of(context).showSnackBar(  
      SnackBar(  
        content: Text(message),  
        backgroundColor: ZendfastColors.success,  
        behavior: SnackBarBehavior.floating,  
        shape: RoundedRectangleBorder(  
          borderRadius: BorderRadius.circular(ZendfastRadius.medium),  
        ),  
        duration: Duration(seconds: 3),  
      ),  
    );  
  }  
    
  // SnackBar de error  
  static void showError(BuildContext context, String message) {  
    ScaffoldMessenger.of(context).showSnackBar(  
      SnackBar(  
        content: Text(message),  
        backgroundColor: ZendfastColors.error,  
        behavior: SnackBarBehavior.floating,  
        shape: RoundedRectangleBorder(  
          borderRadius: BorderRadius.circular(ZendfastRadius.medium),  
        ),  
        duration: Duration(seconds: 4),  
      ),  
    );  
  }  
}  
\`\`\`

8\. Sistema de Animaciones

> **Resumen:** Establece las duraciones, curvas y patrones de animación estándar, así como micro-interacciones. Incluye recomendaciones sobre cuándo evitar animaciones para no sobrecargar la experiencia o afectar la accesibilidad.

> **Guía:** Evita animaciones largas, repetitivas o que puedan dificultar la comprensión de la UI. No uses animaciones para información crítica o feedback de error. Permite a los usuarios desactivar animaciones si lo requieren por accesibilidad.

8.1 Duraciones Estándar  
\`\`\`dart  
class ZendfastAnimations {  
  // Duraciones base  
  static const Duration fast \= Duration(milliseconds: 150);  
  static const Duration standard \= Duration(milliseconds: 250);  
  static const Duration slow \= Duration(milliseconds: 300);  
  static const Duration themeTransition \= Duration(milliseconds: 200);  
    
  // Curvas de animación  
  static const Curve defaultCurve \= Curves.easeInOut;  
  static const Curve bounceIn \= Curves.bounceIn;  
  static const Curve elastic \= Curves.elasticOut;  
}  
\`\`\`

8.2 Micro-interacciones  
\`\`\`dart  
/// Micro-interacciones para mejorar la experiencia de usuario.
/// Usa InkWell para ripple y animaciones de entrada para listas.
class MicroInteractions {
  /// Ripple effect accesible para botón de hidratación.
  static Widget hydrationRipple({required Widget child, required VoidCallback onTap}) {
    // InkWell provee feedback táctil y visual accesible.
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      splashColor: ZendfastColors.primary.withOpacity(0.3),
      highlightColor: ZendfastColors.primary.withOpacity(0.1),
      child: child,
    );
  }

  /// Fade-in animado para elementos de lista.
  /// NOTA: Para animaciones complejas, usar AnimatedList o paquetes como implicitly_animated_reorderable_list.
  static Widget fadeInListItem({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}  
\`\`\`

9\. Navegación y Transiciones

> **Resumen:** Define los patrones de navegación, transiciones de página y modales, asegurando una experiencia fluida y predecible.

9.1 Transiciones de Página  
\`\`\`dart  
class ZendfastPageTransitions {  
  // Fade transition para tabs  
  static Widget fadeTransition(  
    BuildContext context,  
    Animation\<double\> animation,  
    Animation\<double\> secondaryAnimation,  
    Widget child,  
  ) {  
    return FadeTransition(  
      opacity: animation,  
      child: child,  
    );  
  }  
    
  // Slide transition para navegación jerárquica  
  static Route\<T\> slideRoute\<T\>(Widget page) {  
    return PageRouteBuilder\<T\>(  
      pageBuilder: (context, animation, secondaryAnimation) \=\> page,  
      transitionDuration: ZendfastAnimations.standard,  
      transitionsBuilder: (context, animation, secondaryAnimation, child) {  
        return SlideTransition(  
          position: Tween\<Offset\>(  
            begin: Offset(1.0, 0.0),  
            end: Offset.zero,  
          ).animate(CurvedAnimation(  
            parent: animation,  
            curve: ZendfastAnimations.defaultCurve,  
          )),  
          child: child,  
        );  
      },  
    );  
  }  
}  
\`\`\`

9.2 Modales y Overlays  
\`\`\`dart  
class ZendfastModals {  
  // Modal desde abajo  
  static Future\<T\> showBottomModal\<T\>(  
    BuildContext context,  
    Widget child, {  
    bool isDismissible \= true,  
  }) {  
    return showModalBottomSheet\<T\>(  
      context: context,  
      isDismissible: isDismissible,  
      backgroundColor: Colors.transparent,  
      barrierColor: Colors.black.withOpacity(0.5),  
      transitionAnimationController: AnimationController(  
        duration: ZendfastAnimations.slow,  
        vsync: Navigator.of(context),  
      ),  
      builder: (context) \=\> Container(  
        decoration: BoxDecoration(  
          color: Theme.of(context).scaffoldBackgroundColor,  
          borderRadius: BorderRadius.only(  
            topLeft: Radius.circular(ZendfastRadius.xlarge),  
            topRight: Radius.circular(ZendfastRadius.xlarge),  
          ),  
        ),  
        child: child,  
      ),  
    );  
  }  
}  
\`\`\`

10\. Formularios y Validación

> **Resumen:** Establece patrones para inputs, validación y feedback de errores, promoviendo formularios accesibles y consistentes.

10.1 Custom Input Field  
\`\`\`dart  
/// Campo de input personalizado con validación y null safety.
class CustomInputField extends StatelessWidget {
  final String label;
  final String? errorText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool obscureText;

  const CustomInputField({
    Key? key,
    required this.label,
    this.errorText,
    required this.controller,
    required this.onChanged,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          style: ZendfastTypography.bodyLarge,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: ZendfastTypography.bodyMedium.copyWith(
              color: hasError ? ZendfastColors.error : null,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ZendfastRadius.small),
              borderSide: BorderSide(
                color: hasError ? ZendfastColors.error : Colors.grey,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ZendfastRadius.small),
              borderSide: BorderSide(
                color: hasError ? ZendfastColors.error : ZendfastColors.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: ZendfastSpacing.xs),
          Text(
            errorText!,
            style: ZendfastTypography.bodyMedium.copyWith(
              color: ZendfastColors.error,
            ),
          ),
        ],
      ],
    );
  }
}  
\`\`\`

11\. Estados Vacíos y de Error

> **Resumen:** Patrones para mostrar estados vacíos, errores y mensajes amigables, mejorando la experiencia en casos donde no hay datos o hay fallos.

11.1 Empty States  
\`\`\`dart  
/// Widget para mostrar estados vacíos o de error. Usa null safety y required.
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? mascot;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    this.mascot,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ZendfastSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (mascot != null) ...[
              mascot!,
              SizedBox(height: ZendfastSpacing.lg),
            ],
            Text(
              title,
              style: ZendfastTypography.heading2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ZendfastSpacing.md),
            Text(
              subtitle,
              style: ZendfastTypography.bodyLarge.copyWith(
                color: Theme.of(context).textTheme.caption?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: ZendfastSpacing.xl),
              PrimaryButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}  
\`\`\`

12\. Accesibilidad

> **Resumen:** Lineamientos y utilidades para asegurar accesibilidad (contraste, touch targets, Semantics). Incluye recomendaciones para testeo y cumplimiento WCAG.

> **Guía de testing:**
> - Usa el inspector de accesibilidad de Flutter y TalkBack/VoiceOver en dispositivos reales.
> - Verifica ratios de contraste con herramientas automáticas y manuales.
> - Asegura que todos los elementos interactivos tengan labels y hints semánticos.
> - Prueba la app con diferentes tamaños de fuente y escalas de sistema.

12.1 Configuración de Accesibilidad  
\`\`\`dart  
class ZendfastAccessibility {  
  // Ratios de contraste mínimos (WCAG AA)  
  static const double minimumContrastRatio \= 4.5;  
    
  // Tamaños mínimos de toque  
  static const double minimumTouchTarget \= 44.0;  
    
  // Configuración de Semantics  
  static Widget accessibleButton({  
    required Widget child,  
    required String semanticLabel,  
    String semanticHint,  
    VoidCallback onTap,  
  }) {  
    return Semantics(  
      label: semanticLabel,  
      hint: semanticHint,  
      button: true,  
      enabled: onTap \!= null,  
      child: InkWell(  
        onTap: onTap,  
        child: child,  
      ),  
    );  
  }  
    
  // Verificación de contraste  
  static bool hasValidContrast(Color foreground, Color background) {  
    // Implementación del cálculo de contraste WCAG  
    final contrastRatio \= \_calculateContrastRatio(foreground, background);  
    return contrastRatio \>= minimumContrastRatio;  
  }  
}  
\`\`\`

13\. Responsive Design

> **Resumen:** Estrategias y utilidades para adaptar la UI a diferentes tamaños de pantalla y orientación. Incluye recomendaciones para testing en dispositivos físicos y emuladores.

> **Guía de testing:**
> - Prueba la app en dispositivos pequeños, medianos y grandes (físicos y emuladores).
> - Verifica que los elementos no se solapen ni desborden en landscape y portrait.
> - Usa MediaQuery y breakpoints definidos para adaptar paddings y tamaños.

13.1 Breakpoints y Adaptación  
\`\`\`dart  
class ZendfastResponsive {  
  // Breakpoints para diferentes tamaños  
  static const double smallPhone \= 360.0;  
  static const double mediumPhone \= 375.0;  
  static const double largePhone \= 414.0;  
    
  // Utility para obtener padding adaptivo  
  static EdgeInsets getAdaptivePadding(BuildContext context) {  
    final screenWidth \= MediaQuery.of(context).size.width;  
      
    if (screenWidth \< smallPhone) {  
      return EdgeInsets.all(ZendfastSpacing.md);  
    } else if (screenWidth \< largePhone) {  
      return EdgeInsets.all(ZendfastSpacing.lg);  
    } else {  
      return EdgeInsets.all(ZendfastSpacing.xl);  
    }  
  }  
    
  // Utility para escalado de texto  
  static double getScaledFontSize(BuildContext context, double baseSize) {  
    final textScaleFactor \= MediaQuery.of(context).textScaleFactor;  
    return baseSize \* textScaleFactor.clamp(0.8, 1.4);  
  }  
}  
\`\`\`

14\. Organización de Código Frontend

> **Resumen:** Convenciones para la estructura de widgets, nomenclatura y organización de archivos, promoviendo mantenibilidad y escalabilidad.

14.1 Estructura de Widgets  
\`\`\`dart  
// Convención para widgets complejos  
// Ejemplo: FastingTimerScreen  
class FastingTimerScreen extends ConsumerWidget {  
  @override  
  Widget build(BuildContext context, WidgetRef ref) {  
    return Scaffold(  
      body: Column(  
        children: \[  
          \_buildHeader(context, ref),  
          \_buildTimerSection(context, ref),  
          \_buildActionButtons(context, ref),  
        \],  
      ),  
    );  
  }  
    
  Widget \_buildHeader(BuildContext context, WidgetRef ref) {  
    // Implementación del header  
  }  
    
  Widget \_buildTimerSection(BuildContext context, WidgetRef ref) {  
    // Implementación del timer  
  }  
    
  Widget \_buildActionButtons(BuildContext context, WidgetRef ref) {  
    // Implementación de botones  
  }  
}  
\`\`\`

14.2 Convenciones de Nomenclatura  
\`\`\`dart  
// Naming Conventions para Zendfast  
class NamingConventions {  
  // Widgets: PascalCase  
  // FastingTimerScreen, PanicButton, HydrationTracker  
    
  // Variables y funciones: camelCase  
  // fastingDuration, isTimerActive, onPanicPressed  
    
  // Archivos: snake\_case  
  // fasting\_timer\_screen.dart, panic\_button.dart  
    
  // Constantes: SCREAMING\_SNAKE\_CASE  
  // MAX\_FASTING\_HOURS, DEFAULT\_HYDRATION\_GOAL  
}  
\`\`\`

15\. Configuración de Cursor AI

15.1 Reglas Específicas Frontend  
\`\`\`  
 .cursorrules for Frontend  
\- Utilizar el sistema de colores ZendfastColors para todos los elementos UI  
\- Seguir las duraciones de animación definidas en ZendfastAnimations  
\- Aplicar el sistema de espaciado ZendfastSpacing consistentemente  
\- Usar componentes reutilizables antes de crear nuevos widgets  
\- Implementar estados de accesibilidad para todos los elementos interactivos  
\- Mantener ratios de contraste WCAG AA en todas las combinaciones de colores  
\- Aplicar micro-interacciones definidas en MicroInteractions  
\- Usar transiciones estándar de ZendfastPageTransitions para navegación  
\- Implementar loading states para todas las acciones asíncronas  
\- Seguir la estructura de widgets con métodos privados \_build\*  
\`\`\`

