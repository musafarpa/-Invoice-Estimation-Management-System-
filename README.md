# Invoice & Estimation Management System

A comprehensive Flutter application for managing invoices and estimations, designed for businesses in Saudi Arabia.

## Features

- **Invoice Management**: Create, edit, and track invoices with status tracking (Paid, Unpaid, Overdue)
- **Estimation/Quotation Management**: Create and manage quotations with approval workflow
- **PDF Export**: Generate professional PDF documents for both invoices and estimations
- **Multi-language Support**: English and Arabic (RTL) language support
- **User Authentication**: Login system with role-based access (Super Admin, User)
- **Saudi Arabia Localization**: SAR currency, VAT @15%, Arabic language support

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **PDF Generation**: pdf, printing packages
- **Fonts**: Montserrat (UI), Noto Sans Arabic (PDF)

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/musafarpa/-Invoice-Estimation-Management-System-.git
```

2. Navigate to the project directory:
```bash
cd invoiceapp
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

### Build

**Web:**
```bash
flutter build web --release
```

**Android APK:**
```bash
flutter build apk --release
```

**Windows:**
```bash
flutter build windows --release
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── estimation_model.dart
│   ├── invoice_model.dart
│   └── user_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── estimation_provider.dart
│   ├── invoice_provider.dart
│   └── language_provider.dart
├── screens/
│   ├── auth/
│   ├── home/
│   ├── estimation/
│   ├── invoice/
│   └── profile/
└── services/
    ├── pdf_service.dart
    ├── pdf_service_web.dart
    └── pdf_service_stub.dart
```

## License

This project is licensed under the MIT License.

## Author

Developed by [musafarpa](https://github.com/musafarpa)
