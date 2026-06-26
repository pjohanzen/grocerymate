// App-wide constants for GroceryMate

class AppConstants {
  AppConstants._();

  // Currency
  static const String currencySymbol = '₱';
  static const String currencyCode = 'PHP';
  static const String locale = 'en_PH';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing (8px grid system)
  static const double spacingUnit = 8.0;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Corner Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;

  // Button / Touch Targets
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 48.0;

  // Input
  static const int maxListNameLength = 50;
  static const int maxItemNameLength = 100;
  static const int maxNotesLength = 200;

  // Item Units
  static const List<String> units = [
    'pcs',
    'kg',
    'g',
    'L',
    'ml',
    'bundle',
    'box',
    'pack',
    'bottle',
    'can',
    'jar',
    'dozen',
    'bag',
  ];

  // Priority Levels
  static const int priorityLow = 0;
  static const int priorityNormal = 1;
  static const int priorityHigh = 2;
  static const int priorityUrgent = 3;

  // Budget Thresholds
  static const double budgetWarningThreshold = 0.5;
  static const double budgetDangerThreshold = 0.9;

  // List Colors
  static const List<String> listColors = [
    '#2D5016',
    '#1565C0',
    '#6A1B9A',
    '#E65100',
    '#00695C',
    '#C62828',
    '#37474F',
    '#F9A825',
  ];

  // Hive Box Names
  static const String listsBox = 'grocery_lists';
  static const String itemsBox = 'list_items';
  static const String categoriesBox = 'categories';
  static const String templatesBox = 'templates';
  static const String settingsBox = 'app_settings';
  static const String historyBox = 'item_history';
}
