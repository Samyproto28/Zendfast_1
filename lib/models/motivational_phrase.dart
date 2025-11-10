import 'package:isar/isar.dart';

part 'motivational_phrase.g.dart';

/// Represents a motivational phrase used in the panic modal
/// to provide emotional support during difficult fasting moments.
///
/// Phrases are categorized by type (motivation, anti_binge, calm)
/// and can be fetched from Supabase or loaded from local cache.
@collection
class MotivationalPhrase {
  /// Unique identifier (auto-increment for local Isar storage)
  Id id = Isar.autoIncrement;

  /// Main text of the motivational phrase
  @Index(caseSensitive: false)
  late String text;

  /// Optional subtitle or additional context
  String? subtitle;

  /// Icon name to display with the phrase (Material Icons name)
  late String iconName;

  /// Category for filtering: motivation, anti_binge, calm
  String? category;

  /// Order index for sorting phrases
  late int orderIndex;

  /// Whether the phrase is active and should be shown
  @Index()
  bool isActive;

  /// Timestamp when the phrase was created
  DateTime createdAt;

  /// Timestamp when the phrase was last updated
  DateTime updatedAt;

  /// Default constructor
  MotivationalPhrase({
    this.id = Isar.autoIncrement,
    required this.text,
    this.subtitle,
    required this.iconName,
    this.category,
    required this.orderIndex,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a MotivationalPhrase from JSON (Supabase response)
  factory MotivationalPhrase.fromJson(Map<String, dynamic> json) {
    return MotivationalPhrase(
      id: json['id'] as int? ?? Isar.autoIncrement,
      text: json['text'] as String,
      subtitle: json['subtitle'] as String?,
      iconName: json['icon_name'] as String,
      category: json['category'] as String?,
      orderIndex: json['order_index'] as int,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Supabase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'text': text,
      'subtitle': subtitle,
      'icon_name': iconName,
      'category': category,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this phrase with modified fields
  MotivationalPhrase copyWith({
    int? id,
    String? text,
    String? subtitle,
    String? iconName,
    String? category,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MotivationalPhrase(
      id: id ?? this.id,
      text: text ?? this.text,
      subtitle: subtitle ?? this.subtitle,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MotivationalPhrase(id: $id, text: $text, category: $category, orderIndex: $orderIndex, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MotivationalPhrase &&
        other.id == id &&
        other.text == text &&
        other.subtitle == subtitle &&
        other.iconName == iconName &&
        other.category == category &&
        other.orderIndex == orderIndex &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      text,
      subtitle,
      iconName,
      category,
      orderIndex,
      isActive,
    );
  }
}
