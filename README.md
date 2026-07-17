# Mini Shop — Flutter Intern Test

A native Flutter grocery shopping application using GetX, Firebase Authentication,
Cloud Firestore profile data, and the DummyJSON grocery/cart APIs.

## Implemented

- Firebase email/password signup and login
- Firebase password reset and logout
- GetX routing, dependency injection, and reactive state
- Grocery products API with loading, empty, error, retry, search, tags, and pagination
- Product detail API
- Cart PUT/DELETE API integration with optimistic UI and rollback on failure
- Cart totals, quantity controls, remove confirmation, checkout, and success screen
- Account screen with phone, address, wallet display, address editing, and logout
- Launcher icon and native splash configuration
- Mobile-first Flutter UI based on the supplied Stitch design system

## API

- `GET /products/category/groceries?limit=30&skip=0`
- `GET /products/{id}`
- `PUT /carts/1`
- `DELETE /carts/1`
- Optional service support for `GET /carts/user/1`

DummyJSON cart writes are simulated. The app still calls the required endpoints while
keeping the active cart in GetX state for a reliable demo.

## Run

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

## Generate branding

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
