import 'package:isar/isar.dart';

part 'user_consent.g.dart';

/// Types of consent that users can grant or revoke
/// Aligned with GDPR and CCPA requirements
enum ConsentType {
  analyticsTracking,      // Google Analytics, Firebase, etc.
  marketingCommunications, // Email marketing, push notifications for promotions
  dataProcessing,         // Third-party data processing
  nonEssentialCookies,    // Optional cookies/local storage
  doNotSellData,          // CCPA "Do Not Sell My Personal Information" right
  privacyPolicy,          // Acceptance of Privacy Policy (required)
  termsOfService,         // Acceptance of Terms of Service (required)
}

/// Represents a user's consent preference for GDPR/CCPA compliance
/// Tracks what the user has agreed to and when
@collection
class UserConsent {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// User identifier - indexed for user-specific queries
  @Index()
  late String userId;

  /// Type of consent - indexed for filtering
  @Enumerated(EnumType.name)
  @Index()
  late ConsentType consentType;

  /// Whether the user has granted this consent
  late bool consentGiven;

  /// Version number of the consent (for tracking changes over time)
  late int consentVersion;

  /// When the consent was first created
  late DateTime createdAt;

  /// When the consent was last updated
  late DateTime updatedAt;

  /// Constructor
  UserConsent({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.consentType,
    this.consentGiven = false, // GDPR compliant: default to false (opt-in required)
    this.consentVersion = 1,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Helper method to update the consent timestamp
  void markUpdated() {
    updatedAt = DateTime.now();
  }

  /// Convert consent type to string for Supabase (snake_case)
  String get consentTypeString {
    switch (consentType) {
      case ConsentType.analyticsTracking:
        return 'analytics_tracking';
      case ConsentType.marketingCommunications:
        return 'marketing_communications';
      case ConsentType.dataProcessing:
        return 'data_processing';
      case ConsentType.nonEssentialCookies:
        return 'non_essential_cookies';
      case ConsentType.doNotSellData:
        return 'do_not_sell_data';
      case ConsentType.privacyPolicy:
        return 'privacy_policy';
      case ConsentType.termsOfService:
        return 'terms_of_service';
    }
  }

  /// Convert to JSON for Supabase synchronization (snake_case keys)
  Map<String, dynamic> toJson() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'user_id': userId,
      'consent_type': consentTypeString,
      'consent_given': consentGiven,
      'consent_version': consentVersion,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (Supabase synchronization with snake_case keys)
  factory UserConsent.fromJson(Map<String, dynamic> json) {
    // Convert string consent type back to enum
    ConsentType type;
    switch (json['consent_type'] as String) {
      case 'analytics_tracking':
        type = ConsentType.analyticsTracking;
        break;
      case 'marketing_communications':
        type = ConsentType.marketingCommunications;
        break;
      case 'data_processing':
        type = ConsentType.dataProcessing;
        break;
      case 'non_essential_cookies':
        type = ConsentType.nonEssentialCookies;
        break;
      case 'do_not_sell_data':
        type = ConsentType.doNotSellData;
        break;
      case 'privacy_policy':
        type = ConsentType.privacyPolicy;
        break;
      case 'terms_of_service':
        type = ConsentType.termsOfService;
        break;
      default:
        throw ArgumentError('Unknown consent type: ${json['consent_type']}');
    }

    final consent = UserConsent(
      userId: json['user_id'] as String,
      consentType: type,
      consentGiven: json['consent_given'] as bool? ?? false,
      consentVersion: json['consent_version'] as int? ?? 1,
    );

    // Set timestamps if provided (otherwise constructor sets them)
    if (json['created_at'] != null) {
      consent.createdAt = DateTime.parse(json['created_at'] as String);
    }
    if (json['updated_at'] != null) {
      consent.updatedAt = DateTime.parse(json['updated_at'] as String);
    }

    return consent;
  }

  /// Get user-friendly display name for consent type
  String get displayName {
    switch (consentType) {
      case ConsentType.analyticsTracking:
        return 'Seguimiento de Analytics';
      case ConsentType.marketingCommunications:
        return 'Comunicaciones de Marketing';
      case ConsentType.dataProcessing:
        return 'Procesamiento de Datos';
      case ConsentType.nonEssentialCookies:
        return 'Cookies No Esenciales';
      case ConsentType.doNotSellData:
        return 'No Vender Mis Datos (CCPA)';
      case ConsentType.privacyPolicy:
        return 'Política de Privacidad';
      case ConsentType.termsOfService:
        return 'Términos y Condiciones';
    }
  }

  /// Get description for consent type
  String get description {
    switch (consentType) {
      case ConsentType.analyticsTracking:
        return 'Permitir el seguimiento de tu uso de la app para mejorar nuestros servicios.';
      case ConsentType.marketingCommunications:
        return 'Recibir emails de marketing, notificaciones promocionales y actualizaciones.';
      case ConsentType.dataProcessing:
        return 'Permitir el procesamiento de tus datos por servicios de terceros confiables.';
      case ConsentType.nonEssentialCookies:
        return 'Almacenar cookies y datos locales opcionales para mejorar tu experiencia.';
      case ConsentType.doNotSellData:
        return 'Ejercer tu derecho bajo CCPA para que no vendamos tu información personal.';
      case ConsentType.privacyPolicy:
        return 'He leído y acepto la Política de Privacidad de Zendfast.';
      case ConsentType.termsOfService:
        return 'He leído y acepto los Términos y Condiciones de uso de Zendfast.';
    }
  }
}
