# GroceryMate 🛒

A premium, offline-first grocery planner and budget tracker application built with **Flutter 3.24+**, **Riverpod state management**, and **Hive local storage**. Specifically customized for the Philippine market with native support for the Philippine Peso (₱/PHP).

---

## Key Features

* 📱 **Modern & Rich Aesthetics**: Hand-tailored dark and light themes utilizing Material 3, custom typography (Inter and JetBrains Mono), and micro-animations.
* 📦 **Offline-First Storage**: Built with Hive local database; all data resides locally on the device for fast loading times and absolute privacy.
* 💳 **Smart Budget Tracking**: Define limits per grocery list. Watch dynamic circular budget rings and category expense charts update in real-time.
* 🏷️ **Smart Categorization**: 10 default, pre-seeded categories (Produce, Dairy, Meat, Beverages, Pantry, etc.) with custom color palettes and icons.
* 🏁 **Swipe-through Checkout Mode**: Focus on one item at a time while shopping with simple swipe interactions and a completed summary page showing savings.
* 🗂️ **Staple List Templates**: Seed lists immediately using five presets: *Weekly Staples*, *Meal Prep*, *Party*, *Baby Essentials*, and *Cleaning Day*.
* 🔍 **Smart Autocomplete**: Quick predictions based on item history to speed up item additions.

---

## Tech Stack & Architecture

* **Core Framework**: Flutter (Dart)
* **State Management**: Riverpod (for clean, decoupled data-flows)
* **Local Database**: Hive & Hive Flutter (Manual type adapters implemented for optimal performance without code generation lag)
* **Charts Engine**: FL Chart (Custom pie and ring charts)
* **Typography**: Google Fonts (Inter, JetBrains Mono)
* **Icons**: Cupertino Icons & Material Icons

```
lib/
├── config/             # Styling theme, spacing guidelines, constants
├── models/             # Data structure models (lists, items, categories, templates)
├── providers/          # Riverpod state management and business logic
├── screens/            # Application views (home, list details, budget, checkout, settings)
├── services/           # Local storage services and Hive configurations
├── utils/              # PHP currency formatting and form validation helpers
└── widgets/            # Reusable components (custom progress rings, list cards, item tiles)
```

---

## Getting Started

### Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel, version 3.24+).
2. Install [Android SDK](https://developer.android.com/studio) and configure target SDK 34.
3. Configure JDK 17.

### Running in Development

1. Clone this repository to your local workspace:
   ```bash
   git clone <your-repo-url>
   cd grocery_mate
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

### Building for Release

* **Build signed Release APK (Direct Install)**:
   ```bash
   flutter build apk --release
   ```
   *Output Path*: `build/app/outputs/flutter-apk/app-release.apk`

* **Build signed Release App Bundle (Google Play Upload)**:
   ```bash
   flutter build appbundle
   ```
   *Output Path*: `build/app/outputs/bundle/release/app-release.aab`

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
