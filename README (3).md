# Mini Shop — Flutter Grocery E-Commerce App

Mini Shop is a grocery e-commerce mobile application built with Flutter for a Flutter Developer Internship take-home test. The app follows a mobile-first design, uses GetX for state management and navigation, integrates Firebase Authentication, consumes the DummyJSON REST API for product and cart operations, and includes a branded launcher icon and splash screen.

## Features

### Authentication

* Email/password signup with Firebase Authentication
* Email/password login with validation and clear error messages
* Forgot-password flow
* Logout
* Persistent authenticated session

### Products

* API-driven grocery product catalogue
* More than 20 products
* Product search
* Category filtering:

  * All
  * Fruits
  * Vegetables
  * Beverages
  * Meat & Chicken
  * Dairy & Eggs
  * Pantry
* Product detail screen
* Product image loading and fallback states
* Loading, empty, error, and retry states

### Cart

* Add products to cart
* Increase/decrease quantity
* Remove products
* Item subtotal and order total
* Cart API integration using PUT and DELETE requests
* Empty and error states

### Checkout

* Delivery name, phone number, and address
* Cash on Delivery
* Items amount, discount, delivery fee, and final total
* Order success screen
* Order number generation

### Account and Orders

* Profile details
* Editable delivery address
* Wallet display
* Logout confirmation
* Firestore-backed order history
* Same-session fallback if Firestore synchronization temporarily fails

### Branding

* Custom launcher icon using `flutter_launcher_icons`
* Branded native splash using `flutter_native_splash`
* Plus Jakarta Sans typography
* Mobile responsive UI

## Tech Stack

* Flutter
* Dart
* GetX
* Firebase Core
* Firebase Authentication
* Cloud Firestore
* DummyJSON REST API
* HTTP
* Cached Network Image
* Google Fonts
* Flutter Launcher Icons
* Flutter Native Splash

## API

Base URL:

```text
https://dummyjson.com
```

Main endpoints used:

```text
GET    /products/category/groceries
GET    /products/{id}
PUT    /carts/1
DELETE /carts/1
GET    /carts/user/1
```

DummyJSON cart mutations are simulated by the remote service. The app still calls the required cart endpoints and keeps the active cart in GetX state for a reliable user experience.

## Project Structure

```text
lib/
├── app/
│   ├── routes/
│   └── theme/
├── core/
│   ├── network/
│   ├── widgets/
│   └── constants/
├── features/
│   ├── auth/
│   ├── splash/
│   ├── home/
│   ├── products/
│   ├── cart/
│   ├── checkout/
│   ├── success/
│   ├── account/
│   └── orders/
├── firebase_options.dart
└── main.dart
```

## Requirements

* Flutter stable
* Android Studio or Android SDK
* Firebase project with Email/Password Authentication enabled
* Firestore database with the included rules deployed

## Setup

Clone the repository:

```bash
git clone https://github.com/Mahnoor-Nm/mini-shop-flutter.git
cd mini-shop-flutter
```

Install dependencies:

```bash
flutter pub get
```

Generate launcher icons:

```bash
dart run flutter_launcher_icons
```

Generate native splash resources:

```bash
dart run flutter_native_splash:create
```

Run code analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run on an Android device or emulator:

```bash
flutter run
```

## Firebase Setup

The project expects a generated Firebase configuration file:

```text
lib/firebase_options.dart
```

Email/password authentication must be enabled in Firebase Console.

Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules --project mini-shop-grocery
```

The Firestore rules allow authenticated users to access only their own profile and order-history documents.

## Build APK

Build a release APK:

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For smaller architecture-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

Generated files are located in:

```text
build/app/outputs/flutter-apk/
```

## Quality Checks

Before submission, run:

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --release
```

Expected analyzer result:

```text
No issues found!
```

## Test Flow

```text
Splash
→ Signup/Login
→ Home
→ Search and categories
→ Product details
→ Add to cart
→ Quantity update/remove
→ Checkout
→ Cash on Delivery
→ Order success
→ Account
→ Order history
→ Logout
```

## Notes

* Product and cart data are API-driven.
* Authentication is handled separately through Firebase.
* Order history is stored in Cloud Firestore.
* The app contains no final hardcoded product catalogue.
* Account, checkout details, forgot password, product details, and order history are additional features beyond the required test screens.
