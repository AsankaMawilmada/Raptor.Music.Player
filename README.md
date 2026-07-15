# raptor_player

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building the production APK

Release builds are signed with a real upload keystore (`android/upload-keystore.jks`),
configured via `android/key.properties`. Both files are gitignored and must exist
locally before a release build will succeed.

```
flutter build apk --release
```

The signed APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

If `android/key.properties` or `android/upload-keystore.jks` are missing (e.g. on a
fresh clone), the release build will fail with a "Keystore file not found" error.
Restore them from your backup, or generate a new keystore with `keytool`:

```
keytool -genkeypair -v -keystore android/upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

then create `android/key.properties`:

```
storePassword=<your store password>
keyPassword=<your key password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

**Note:** generating a new keystore changes the app's signature. Android will treat
it as a different app for update purposes, so keep the original keystore backed up
somewhere safe outside this repo.
