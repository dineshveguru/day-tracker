# Day Tracker (Flutter Android App)

Day Tracker helps you plan and review every hour of your day.

You can:
- Create your own activity categories (Work, Study, Fitness, etc.)
- Plan each hour of the day
- Update actual activity at end of day
- View GitHub-style heatmaps by category
- Track category streaks

The app uses a **dark neon visual style** with smooth animations.

---

## 1) What you need

If you are a non-technical user, ask a developer friend for first-time setup once.

You need:
- A Windows / Mac / Linux computer
- Android phone + USB cable
- Internet connection

---

## 2) Install required software (one time)

1. Install **Git**  
   - https://git-scm.com/downloads
2. Install **Flutter SDK**  
   - https://docs.flutter.dev/get-started/install
3. Install **Android Studio** (includes Android SDK)  
   - https://developer.android.com/studio
4. Enable **Developer options + USB debugging** on your Android phone  
   - Phone Settings → About phone → tap Build number 7 times  
   - Then Settings → Developer options → USB debugging ON

After installation, open terminal/command prompt and run:

```bash
flutter doctor
```

Fix anything marked in red before continuing.

---

## 3) Get this project

```bash
git clone https://github.com/dineshveguru/day-tracker.git
cd day-tracker
```

If you are using your own fork, replace `dineshveguru` with your GitHub username.

---

## 4) Generate Android project files

Run this inside the project folder:

```bash
flutter create .
```

This creates Android platform files if they are missing.

---

## 5) Install app dependencies

```bash
flutter pub get
```

---

## 6) Run the app on your Android phone

1. Connect phone with USB
2. Accept debugging popup on phone
3. Run:

```bash
flutter devices
flutter run
```

If multiple devices appear, select your phone when prompted.

---

## 7) How to use the app

### Journal tab
1. Tap **Category** button to create your categories
2. Select date from top calendar icon
3. In **Planned** mode, assign categories for each hour
4. At end of day, switch to **Actual (end of day)** and update real activity

### Heatmap tab
- Shows GitHub-style heatmap for each category
- Brighter neon color = more hours logged on that day

### Streaks tab
- Shows current streak and best streak for each category

---

## 8) Data and privacy

- Your data is stored locally on your phone
- No account required
- No cloud upload in this version

---

## 9) Build APK (optional, for direct install)

```bash
flutter build apk --release
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

Copy this APK to your phone and install it.

---

## 10) Troubleshooting

- `flutter doctor` has issues → fix all warnings/errors first
- Phone not detected → reconnect USB, enable USB debugging again
- Build fails → run:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Feature summary

- Hour-by-hour day tracking
- Planned vs Actual daily journaling
- Custom categories
- Neon dark theme with animated UI
- Category-based heatmaps
- Category streak insights
