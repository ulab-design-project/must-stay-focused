// File: lib/services/backup_service.dart
// TODO: Implement Encrypted Cloud Sync
// Architecture: Dependency injectable service `BackupService`. Uses `encrypt` package.
// Requirements:
// 1. Define `AESEncryptionUtil`:
//    - Method: `String encryptData(String rawJson, String localSecret)`
//    - Method: `String decryptData(String encryptedPayload, String localSecret)` (NFR-08). Ensure localSecret never leaves device.
// 2. Class methods:
//    - `exportToJson()`: aggregates all Isar db contents to string (FR-46).
//    - `importFromJson(String data)`.
//    - `syncToGoogleDrive()` / `syncToICloud()` leveraging file_picker or direct platform APIs to push the encrypted payload (FR-44, FR-45).
