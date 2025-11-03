# portal_ux

Before adding new widgets, pages, you might want to look through lib/utils files.

---
## Install firebase cli

[https://firebase.google.com/docs/cli#install-cli-mac-linux](https://firebase.google.com/docs/cli#install-cli-mac-linux)

## Activate FLutterFire CLI

```sh
    dart pub global activate flutterfire_cli
```

## Install Dependencies

```sh
    flutter pub add firebase_core
    flutter pub add firebase_auth
    # required for email link sign in and email verification
    flutter pub add firebase_dynamic_links
```

## Configuration

```sh
    firebase login
    flutterfire configure
```

## Initialize Firebase App

```dart
    Future<void> main() async {
        WidgetsFlutterBinding.ensureInitialized();

        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
```