import 'package:flutter/material.dart';

/// Tipos de planes de ayuno disponibles
enum FastingPlanType {
  plan12_12,
  plan14_10,
  plan16_8,
  plan18_6,
  plan24h,
  plan48h,
}

/// Niveles de dificultad para planes de ayuno
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

/// Para qué está recomendado el plan
enum RecommendedFor {
  fatLoss,
  autophagy,
  both,
}

/// Modelo para representar un plan de ayuno con toda su información
class FastingPlan {
  final FastingPlanType type;
  final String title;
  final String description;
  final int fastingHours;
  final int eatingHours;
  final DifficultyLevel difficultyLevel;
  final RecommendedFor recommendedFor;
  final List<String> benefits;
  final IconData icon;

  const FastingPlan({
    required this.type,
    required this.title,
    required this.description,
    required this.fastingHours,
    required this.eatingHours,
    required this.difficultyLevel,
    required this.recommendedFor,
    required this.benefits,
    required this.icon,
  });

  /// Plan 12/12 - Principiante
  static FastingPlan plan12_12() => const FastingPlan(
        type: FastingPlanType.plan12_12,
        title: '12/12',
        description: 'Plan equilibrado para principiantes',
        fastingHours: 12,
        eatingHours: 12,
        difficultyLevel: DifficultyLevel.beginner,
        recommendedFor: RecommendedFor.fatLoss,
        benefits: [
          'Mejora la digestión',
          'Aumenta la energía',
          'Introduce el hábito del ayuno de forma suave',
          'Facilita la pérdida de grasa gradual',
        ],
        icon: Icons.brightness_4,
      );

  /// Plan 14/10 - Principiante
  static FastingPlan plan14_10() => const FastingPlan(
        type: FastingPlanType.plan14_10,
        title: '14/10',
        description: 'Siguiente paso para principiantes',
        fastingHours: 14,
        eatingHours: 10,
        difficultyLevel: DifficultyLevel.beginner,
        recommendedFor: RecommendedFor.fatLoss,
        benefits: [
          'Acelera el metabolismo',
          'Promueve la pérdida de grasa',
          'Mejora la sensibilidad a la insulina',
          'Reduce la inflamación',
        ],
        icon: Icons.nightlight_round,
      );

  /// Plan 16/8 - Intermedio (más popular)
  static FastingPlan plan16_8() => const FastingPlan(
        type: FastingPlanType.plan16_8,
        title: '16/8',
        description: 'El plan más popular para resultados visibles',
        fastingHours: 16,
        eatingHours: 8,
        difficultyLevel: DifficultyLevel.intermediate,
        recommendedFor: RecommendedFor.both,
        benefits: [
          'Pérdida de grasa eficiente',
          'Activa la autofagia celular',
          'Mejora la claridad mental',
          'Optimiza la producción de hormona de crecimiento',
          'Reduce significativamente la inflamación',
        ],
        icon: Icons.schedule,
      );

  /// Plan 18/6 - Intermedio/Avanzado
  static FastingPlan plan18_6() => const FastingPlan(
        type: FastingPlanType.plan18_6,
        title: '18/6',
        description: 'Para resultados acelerados',
        fastingHours: 18,
        eatingHours: 6,
        difficultyLevel: DifficultyLevel.intermediate,
        recommendedFor: RecommendedFor.autophagy,
        benefits: [
          'Autofagia profunda',
          'Pérdida de grasa acelerada',
          'Mejora la función cognitiva',
          'Reduce el riesgo de enfermedades crónicas',
          'Aumenta la longevidad celular',
        ],
        icon: Icons.timer,
      );

  /// Plan 24h - Avanzado (OMAD - Una comida al día)
  static FastingPlan plan24h() => const FastingPlan(
        type: FastingPlanType.plan24h,
        title: '24h',
        description: 'Una comida al día (OMAD)',
        fastingHours: 24,
        eatingHours: 0,
        difficultyLevel: DifficultyLevel.advanced,
        recommendedFor: RecommendedFor.autophagy,
        benefits: [
          'Máxima autofagia celular',
          'Regeneración celular profunda',
          'Optimiza la producción de cetonas',
          'Mejora significativa en biomarcadores de salud',
          'Control total del apetito',
        ],
        icon: Icons.local_dining,
      );

  /// Plan 48h - Avanzado (Ayuno extendido)
  static FastingPlan plan48h() => const FastingPlan(
        type: FastingPlanType.plan48h,
        title: '48h',
        description: 'Ayuno extendido para expertos',
        fastingHours: 48,
        eatingHours: 0,
        difficultyLevel: DifficultyLevel.advanced,
        recommendedFor: RecommendedFor.autophagy,
        benefits: [
          'Autofagia máxima',
          'Renovación celular completa',
          'Reset metabólico profundo',
          'Producción óptima de células madre',
          'Máxima regeneración del sistema inmune',
        ],
        icon: Icons.self_improvement,
      );

  /// Obtener todos los planes predefinidos
  static List<FastingPlan> getAllPlans() => [
        plan12_12(),
        plan14_10(),
        plan16_8(),
        plan18_6(),
        plan24h(),
        plan48h(),
      ];

  /// Obtener el nombre legible del nivel de dificultad
  String get difficultyLevelName {
    switch (difficultyLevel) {
      case DifficultyLevel.beginner:
        return 'Principiante';
      case DifficultyLevel.intermediate:
        return 'Intermedio';
      case DifficultyLevel.advanced:
        return 'Avanzado';
    }
  }

  /// Obtener el color asociado al nivel de dificultad
  Color getDifficultyColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (difficultyLevel) {
      case DifficultyLevel.beginner:
        return colorScheme.secondary; // Verde
      case DifficultyLevel.intermediate:
        return colorScheme.tertiary; // Naranja
      case DifficultyLevel.advanced:
        return colorScheme.error; // Rojo
    }
  }

  /// Obtener el texto de "Recomendado para"
  String get recommendedForText {
    switch (recommendedFor) {
      case RecommendedFor.fatLoss:
        return 'Pérdida de grasa';
      case RecommendedFor.autophagy:
        return 'Autofagia';
      case RecommendedFor.both:
        return 'Pérdida de grasa y autofagia';
    }
  }

  /// Obtener la descripción de duración (e.g., "16h ayuno / 8h comida")
  String get durationText {
    if (eatingHours == 0) {
      return '$fastingHours horas de ayuno';
    }
    return '$fastingHours horas ayuno / $eatingHours horas comida';
  }

  /// Serializar a JSON
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'description': description,
        'fastingHours': fastingHours,
        'eatingHours': eatingHours,
        'difficultyLevel': difficultyLevel.name,
        'recommendedFor': recommendedFor.name,
        'benefits': benefits,
      };

  /// Deserializar desde JSON
  static FastingPlan fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = FastingPlanType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => FastingPlanType.plan16_8,
    );

    // Retornar el plan predefinido basado en el tipo
    return getAllPlans().firstWhere(
      (plan) => plan.type == type,
      orElse: () => plan16_8(),
    );
  }

  /// Obtener un plan por su tipo
  static FastingPlan getByType(FastingPlanType type) {
    return getAllPlans().firstWhere(
      (plan) => plan.type == type,
      orElse: () => plan16_8(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingPlan &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}
