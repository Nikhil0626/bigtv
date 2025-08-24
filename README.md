# 📱 ChotaNews

**ChotaNews** is a lightweight and fast news aggregator app that delivers bite-sized news in a
swipeable, visually engaging format.

---

## 🚀 Features

* 📰 Vertical swipe-based news cards
* 🔍 AI-generated tags for better discovery
* 💬 Like, Comment, and Share functionality
* 🌐 Web & Native content integration
* 📢 Custom native ads support
* 📷 News screenshot and share
* 📡 Real-time API-powered content
* 📲 App Links / Universal Links Support
* 📊 Custom events for better analytics and business improvement

---

## ✅ Prerequisites

* Flutter SDK (>= 3.29.3)
* Android Studio / Vs code (with Dart and Flutter plugins)
* Android device or emulator

---

## 🚀 Installation

```bash
git clone https://github.com/bigtvsignitives/chotanews_application.git
cd chotanews_application
flutter pub get
flutter run
```

---

## 📆 Build Instructions (Flutter Android)

### 🩹 Clean the project and get dependencies

```bash
flutter clean
flutter pub get
```

### 📲 Build APK (Release)

```bash
flutter build apk --release
```

📁 Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

### 📆 Build AAB (Release for Play Store)

```bash
flutter build appbundle --release
```

📁 Output:

```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🍎 Build Instructions (Flutter iOS)

### 🩹 Clean, install pods, and open project in Xcode

```bash
flutter clean
flutter pub get
cd ios
pod install
flutter build ios --release --config-only
open Runner.xcworkspace
```
```bash
open Runner.xcworkspace
```
### 📲 Build iOS (Release)

```bash
flutter build ios --release
```

📁 Output:

```
build/ios/iphoneos/Runner.app
```

### 🚀 Archive and Upload to TestFlight or App Store

> Open the project in Xcode
> Go to: `Product > Clean Build folder`
> Go to: `Product > Archive`
> Follow the flow to upload to App Store Connect

---

Feel free to add screenshots, contributors, or license sections below this!
