# Sahayak — Cooperative Home Services Platform

Sahayak is a community-first, cooperative public home services platform built with Flutter. It connects verified guild workers (electricians, plumbers, carpenters, appliance technicians, painters, and cleaners) directly with households, eliminating predatory middleman commissions while ensuring dignified livelihood, civic safety guarantees, and fair compensation.

---

## ✨ Key Features

- **🌐 Dynamic Multi-Language Localization**:
  - Full native support for **English**, **தமிழ் (Tamil)**, **हिंदी (Hindi)**, and **മലയാളം (Malayalam)**.
  - Reactive in-app language switching across all screens, dialogs, notifications, and navigation items.

- **🛠 Multi-Trade & Single-Domain Service Booking**:
  - 2-Step interactive booking wizard with trade domain selection (Plumbing, Electrical, Carpentry, Appliances, etc.).
  - Problem description, file attachments (photos & video notes), emergency vs. scheduled dispatch modes.
  - Transparent pricing set directly by workers and guilds (no forced artificial price caps or broker markups).

- **⚡ Transparent Worker Matching & Competitive Bids**:
  - Live broadcast to nearest society/ward workers.
  - Compare worker proposals by rating, proximity/ETA, certifications, and customer reviews.

- **🔒 Secure Doorstep OTP Work Authorization**:
  - Dynamic 4-digit doorstep PIN required before job start, protecting citizens and authenticating worker presence.

- **⏱ Fair-Work 1-Hour Cancellation & Delay Protection**:
  - 1-Hour Pre-Service worker status update simulation (`On Time`, `+15m Delay`, `Worker Cancel`).
  - Zero-penalty customer cancellation window prior to 1 hour before scheduled time.

- **📋 Booking Management & History**:
  - Real-time tracking of active jobs, technician route status, and booking history (`Upcoming`, `Completed`, `Cancelled`).
  - Emergency SOS dispatch and civic guarantee protection.

---

## 📱 Tech Stack & Architecture

- **Framework**: Flutter (Dart 3+)
- **Architecture**: MVVM with Repository Pattern (`AppRepository`, `AppViewModel`, `ChangeNotifier`)
- **Design System**: Vanilla Flutter Material 3, tailored custom `SahayakColors` and `SahayakTypography`
- **Testing**: Comprehensive automated test coverage (`test/app_repository_test.dart`, `test/my_bookings_screen_test.dart`, `test/widget_test.dart`)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0 or newer)
- Android Studio / VS Code with Dart & Flutter extensions
- Android Device or Emulator (API 24+)

### Run Locally
```bash
# Clone the repository
git clone https://github.com/SiddharthNishkalan/Sahayak.git
cd Sahayak

# Fetch dependencies
flutter pub get

# Run static analysis
dart analyze

# Run unit and widget tests
flutter test

# Run on connected device
flutter run
```

---

## 📄 License
This project is developed for public good and cooperative workforce empowerment.
