import 'package:flutter/material.dart';

/// Zendfast spacing system based on 8dp grid
/// Provides consistent spacing throughout the application
class ZendfastSpacing {
  // Private constructor to prevent instantiation
  ZendfastSpacing._();

  // Base spacing values following 8dp grid
  static const double xs = 4.0;   // Extra small - 4dp
  static const double s = 8.0;    // Small - 8dp
  static const double m = 16.0;   // Medium - 16dp (base)
  static const double l = 24.0;   // Large - 24dp
  static const double xl = 32.0;  // Extra large - 32dp
  static const double xxl = 40.0; // Extra extra large - 40dp

  // Commonly used EdgeInsets
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allS = EdgeInsets.all(s);
  static const EdgeInsets allM = EdgeInsets.all(m);
  static const EdgeInsets allL = EdgeInsets.all(l);
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  // Horizontal spacing
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalS = EdgeInsets.symmetric(horizontal: s);
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets horizontalL = EdgeInsets.symmetric(horizontal: l);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical spacing
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalS = EdgeInsets.symmetric(vertical: s);
  static const EdgeInsets verticalM = EdgeInsets.symmetric(vertical: m);
  static const EdgeInsets verticalL = EdgeInsets.symmetric(vertical: l);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  // SizedBox for vertical spacing
  static const Widget verticalSpaceXs = SizedBox(height: xs);
  static const Widget verticalSpaceS = SizedBox(height: s);
  static const Widget verticalSpaceM = SizedBox(height: m);
  static const Widget verticalSpaceL = SizedBox(height: l);
  static const Widget verticalSpaceXl = SizedBox(height: xl);
  static const Widget verticalSpaceXxl = SizedBox(height: xxl);

  // SizedBox for horizontal spacing
  static const Widget horizontalSpaceXs = SizedBox(width: xs);
  static const Widget horizontalSpaceS = SizedBox(width: s);
  static const Widget horizontalSpaceM = SizedBox(width: m);
  static const Widget horizontalSpaceL = SizedBox(width: l);
  static const Widget horizontalSpaceXl = SizedBox(width: xl);
  static const Widget horizontalSpaceXxl = SizedBox(width: xxl);
}

/// Zendfast border radius system
/// Provides consistent rounded corners throughout the application
class ZendfastRadius {
  // Private constructor to prevent instantiation
  ZendfastRadius._();

  // Border radius values
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double extraLarge = 16.0;
  static const double round = 999.0; // Fully rounded

  // BorderRadius objects
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(extraLarge));
  static const BorderRadius roundRadius = BorderRadius.all(Radius.circular(round));

  // RoundedRectangleBorder for buttons and cards
  static const RoundedRectangleBorder smallShape = RoundedRectangleBorder(
    borderRadius: smallRadius,
  );
  static const RoundedRectangleBorder mediumShape = RoundedRectangleBorder(
    borderRadius: mediumRadius,
  );
  static const RoundedRectangleBorder largeShape = RoundedRectangleBorder(
    borderRadius: largeRadius,
  );
  static const RoundedRectangleBorder extraLargeShape = RoundedRectangleBorder(
    borderRadius: extraLargeRadius,
  );
}

/// Material 3 elevation levels
class ZendfastElevation {
  // Private constructor to prevent instantiation
  ZendfastElevation._();

  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;
}
