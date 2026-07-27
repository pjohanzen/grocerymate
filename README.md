# GroceryMate 🛒

A premium, offline-first grocery planner and budget tracker application built with **Flutter 3.24+**, **Riverpod state management**, and **Hive local storage**. Specifically customized for the Philippine market with native support for the Philippine Peso (₱/PHP).

---

## Key Features

### 🎨 Material 3 Premium UI/UX Redesign ( v1.3+ )
* **Organic Branding Palette**: Forest Green primary (`#2D6A4F`), Sage Green accent (`#52B788`), Warm Muted Carrot secondary (`#D07A3E`), and Warm Beetroot Red tertiary (`#8B263E`) color schemes mapping to both Light and Dark mode variations.
* **Premium Typographypairing**: Outfit font for headings and app bar titles, Inter font for readable body/labels, and JetBrains Mono for monetary figures.
* **Micro-Animations & Tactile Feedback**: Physics-based `ScaleTransition` on card/button touch inputs for tactile feel.
* **Bento Grid & Outline Styling**: Rounded cards (`16dp` radius) using thin borders instead of heavy drop shadows, aligning with Apple Reminders, Notion Mobile, and Todoist styles.
* **Staggered Animations**: Cascading entrance fade/offsets on Home Screen lists.
* **Unified Category Chips**: Reusable scrollable filter row with smooth bouncing physics for dynamic multi-selection.

### 🛒 Checkout & Shopping Mode ( v1.1+ )
* **Distraction-free Checkout**: Swipe through items one-by-one with full-screen item cards.
* **Vertical Swipe Gestures**: Swipe **up** to mark complete, swipe **down** to skip, with bouncy scale animation overlays.
* **Live Budget Indicator**: Running totals showing item count, completion percentage, and remaining budget (₱X left / over budget).
* **Completion Summary**: Interactive celebration summary displaying total spent, items purchased, session stats, and exact savings relative to your budget ("You saved ₱X vs. budget!").

### 🔍 Search & Filter ( v1.1+ )
* **Live Search**: Animated slide-out search bar filters list items dynamically.
* **Status Filter Chips**: Toggle between *All*, *To Buy*, and *Completed* items via ChoiceChips.
* **Category Filter Chips**: Horizontal scrolling multi-select chips to filter items by pre-seeded categories.
* **Smart Empty States**: Clear prompts and filters indicator with a quick "Clear Filters" action.

### 📝 Item Autocomplete from History ( v1.2+ )
* **Smart Autocomplete**: Quick predictions based on item history to speed up item additions.
* **Price Restoration**: Automatically remembers and suggests the item's last known price.
* **Smart Matching**: Ignores case and matches prefixes or partial text, prioritizing exact/prefix matches first.
* **Backward Compatible**: Uses a dynamic schema check to safely load older search history formats.

### 👥 Duplicate Shopping List ( v1.2+ )
* **Dual Entry Points**: Long press a list card on the Home Screen, or select "Duplicate List" from the Details page three-dot menu.
* **Smart Cloning**: Copies budget, shopping day, items, and prices, while resetting completion status and progress.
* **Seamless Flow**: Direct navigation to the duplicated list with a success toast.

### ⏰ Shopping Reminders ( v1.2+ )
* **Local Notifications**: Timezone-aware local notifications that survive app restarts.
* **Settings Panel**: Dedicated toggles, date pickers, and time pickers inside the list editor.
* **Snooze Actions**: Quick action buttons (`Snooze 15m`, `Snooze 1h`, `Snooze Tomorrow`) directly from the system notification tray.

### 📤 Export & Share ( v1.2+ )
* **PDF Export & Print**: Generates high-quality print-friendly PDF tables showing status, quantity, price, and budget details.
* **CSV Export**: Spreadsheet-compatible format (`Name,Quantity,Price,Purchased,Budget`).
* **Plain Text Export**: Generates copy-paste friendly lists with checkmark emojis.
* **Native Sharing**: Share files/text directly to WhatsApp, Email, SMS, or connected printers.

### ✨ UX Polish ( v1.1+ )
* **Long-press Edit**: Long press any item tile to edit details immediately.
* **Delete Confirmation**: Left-swipe to delete items with a popup safety check dialog.
* **Extended Undo Window**: Extended deletion undo snackbar duration to 5s.
* **Display Settings**: Toggle between Light Mode, Dark Mode, and System Theme with a unified `ThemeService` and settings screen.

---

## Tech Stack & Architecture

* **Core Framework**: Flutter (Dart)
* **State Management**: Riverpod (for clean, decoupled data-flows)
* **Local Database**: Hive & Hive Flutter (Manual type adapters implemented for optimal performance without code generation lag)
* **Charts Engine**: FL Chart (Custom pie and ring charts)
* **Typography**: Google Fonts (Outfit, Inter, JetBrains Mono)
* **Icons**: Cupertino Icons & Material Icons

```
lib/
├── config/             # Styling theme, spacing guidelines, constants
├── models/             # Data structure models (lists, items, categories, templates)
├── providers/          # Riverpod state management and business logic
├── screens/            # Application views (home, list details, budget, checkout, settings)
├── services/           # Local storage services and Hive configurations
├── utils/              # PHP currency formatting and form validation helpers
├── widgets/            # Reusable components (custom progress rings, list cards, item tiles)
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
   git pub get
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
