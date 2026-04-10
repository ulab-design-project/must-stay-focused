# must_stay_focused


## Table of Contents

## Getting Started

## Java/Gradle setup (important for all developers)

Use JDK 17 for Flutter Android builds.

Do not commit machine-specific `org.gradle.java.home` in [android/gradle.properties](android/gradle.properties).
Set it per developer in user-level Gradle config instead:

- Linux/macOS: `~/.gradle/gradle.properties`
- Windows: `%USERPROFILE%\\.gradle\\gradle.properties`

Add this line there:

`org.gradle.java.home=<your-local-jdk-17-path>`

Example Linux path:

`org.gradle.java.home=/usr/lib/jvm/java-17-openjdk`

Create emulator
flutter emulators --create test_device

Launch emulator
flutter emulators --launch test_device

Check device id:
flutter devices

IMPORTANT NOTE : Install OpenJDK 17 for building properly and set JAVA_HOME to the path of the JDK 17
Build and run on the emulator: eg id - emulator-5554
flutter run -d emulator-5554
