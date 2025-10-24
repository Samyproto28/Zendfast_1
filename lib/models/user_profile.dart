import 'package:isar/isar.dart';

part 'user_profile.g.dart';

/// Represents a user's profile with health-related information
/// Supports calculated fields like daily hydration goal and BMI
@collection
class UserProfile {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// User identifier - unique index (one profile per user)
  @Index(unique: true)
  late String userId;

  /// User's weight in kilograms
  double? weightKg;

  /// User's height in centimeters
  double? heightCm;

  /// User's age
  int? age;

  /// User's gender (optional, for health calculations)
  String? gender;

  /// When this profile was created
  late DateTime createdAt;

  /// When this profile was last updated
  late DateTime updatedAt;

  /// Constructor
  UserProfile({
    this.id = Isar.autoIncrement,
    required this.userId,
    this.weightKg,
    this.heightCm,
    this.age,
    this.gender,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Calculate daily hydration goal in liters
  /// Formula: weight (kg) × 0.033 = liters per day
  /// Returns null if weight is not set
  @ignore
  double? get dailyHydrationGoal {
    if (weightKg == null) return null;
    return weightKg! * 0.033;
  }

  /// Calculate daily hydration goal in milliliters
  @ignore
  double? get dailyHydrationGoalMl {
    final goalLiters = dailyHydrationGoal;
    if (goalLiters == null) return null;
    return goalLiters * 1000;
  }

  /// Calculate Body Mass Index (BMI)
  /// Formula: weight (kg) / (height (m))²
  /// Returns null if weight or height is not set
  @ignore
  double? get bmi {
    if (weightKg == null || heightCm == null) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }

  /// Get BMI category based on WHO classification
  @ignore
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Helper method to update the profile timestamp
  void markUpdated() {
    updatedAt = DateTime.now();
  }
}
