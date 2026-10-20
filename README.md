# فلل للوقود

Flutter application for company 133, with Arabic and English interfaces, station maps, services, account management, rewards, evaluations and service requests.

## Run

Install Flutter and the Android SDK, then run:

```sh
flutter pub get
flutter run
```

## Check

```sh
flutter test
```

Widget tests save local previews under `design-audit/screenshots/`. Generated captures are excluded from Git.

## Android release

Copy `android/key.properties.example` to `android/key.properties` and set your keystore path, alias and passwords. The path is resolved relative to `android/app`. Keep the original signing key for future updates. Signing keys and passwords are excluded from this repository.

```sh
flutter build apk --release
```

The Android package is `com.raitotec.fall`. Google Maps uses `Maps SDK for Android`; configure the API key in `android/app/src/main/AndroidManifest.xml` and authorize the package name and signing certificate SHA-1 in Google Cloud. Billing and SDK activation are configured in Google Cloud.

## Backend

The active company code is configured in `lib/Constans/Base_Url.dart`. Company configuration supplies the API base URL. Email OTP delivery and SMTP sender settings belong to the backend; SMTP credentials must not be added to the mobile app.

The internal Dart package name remains `babco` for compatibility with existing imports. The user-visible application name is `فلل للوقود`.
