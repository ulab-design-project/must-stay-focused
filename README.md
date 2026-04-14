# <p align="center"><img src="assets\msf.png" alt="Must Stay Focused" width="220" /></p>

<h1 align="center">Must Stay Focused</h1>

<p align="center">
  Focus productivity app to block distractions and maintain concentration.
</p>

---

## ⬇️ Download

<p align="center">
  <a href="RELEASE DOWNLOAD LINK HERE">
    <img src="https://img.shields.io/badge/Download-GitHub-2ea44f?style=for-the-badge&logo=github" alt="Download Release" />
  </a>
</p>

> Replace `RELEASE DOWNLOAD LINK HERE` with the actual GitHub release asset URL when publishing new versions.

---

## 📸 Screenshots

SCREENSHOTS HERE

---

## ✨ Features

- distraction blocking
- focus session timer
- productivity tracking
- minimal clean interface
- cross platform support

---

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK
- OpenJDK 17 **(required for Android builds)**

### Java/Gradle Configuration
Do **NOT** commit machine-specific paths in `android/gradle.properties`. Configure this on your local developer machine only:

1.  Create/edit your user gradle properties file:
    - Linux/macOS: `~/.gradle/gradle.properties`
    - Windows: `%USERPROFILE%\.gradle\gradle.properties`

2.  Add this line with your local JDK 17 path:
    ```properties
    org.gradle.java.home=<your-local-jdk-17-path>
    ```

    Example Linux path:
    ```properties
    org.gradle.java.home=/usr/lib/jvm/java-17-openjdk
    ```

### Running the App

```bash
# Create test emulator
flutter emulators --create test_device

# Launch emulator
flutter emulators --launch test_device

# Verify connected devices
flutter devices

# Run on emulator (use correct device id from previous command)
flutter run -d emulator-5554
```

---

## 📝 License

This project is open source. 
GPL 3 License
