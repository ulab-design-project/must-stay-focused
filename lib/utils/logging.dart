import 'dart:io';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';

/// Log levels supported by the logger
enum LogLevel {
  debug,
  info,
  design,
  warning,
  error,
}

/// Extension to get string representation of LogLevel
extension LogLevelExtension on LogLevel {
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.design:
        return 'DESIGN';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}

/// Logs a message to a file in /logs directory and optionally to terminal.
///
/// [level] - The log level (debug, info, design, warning, error)
/// [text] - The message to log
/// [source] - Optional originating dart file name
/// [inTerminal] - If true, also prints to terminal (default: false)
Future<void> logger(
  LogLevel level,
  String text, {
  String? source,
  bool inTerminal = false,
}) async {
  final timestamp = DateTime.now().toIso8601String();
  final levelName = level.name;
  
  // Build the log message
  final logMessage = source != null
      ? '[$timestamp] [$levelName] ($source): $text\n'
      : '[$timestamp] [$levelName]: $text\n';

  // Log to console if requested
  if (inTerminal) {
    developer.log(text, name: source ?? 'App', level: _getDeveloperLevel(level));
  }

  // Write to log file
  await _writeToFile(level, logMessage);
}

/// Writes the log message to the appropriate file based on log level
Future<void> _writeToFile(LogLevel level, String message) async {
  final directory = await _getLogsDirectory();
  final fileName = _getFileName(level);
  final file = File('$directory/$fileName');

  // Ensure file exists with markdown header if new
  if (!await file.exists()) {
    await file.create(recursive: true);
    final header = '# ${level.name.toUpperCase()} Log\n\n';
    await file.writeAsString(header);
  }

  // Append the log message
  await file.writeAsString(message, mode: FileMode.append);
}

/// Gets the logs directory path
/// First tries project directory logs/, falls back to application documents directory
Future<String> _getLogsDirectory() async {
  try {
    // First try project directory
    final logsDir = Directory('logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir.path;
  } catch (e) {
    // Fallback to application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${appDir.path}/logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir.path;
  }
}

/// Returns the filename for the given log level
String _getFileName(LogLevel level) {
  switch (level) {
    case LogLevel.debug:
      return 'debug.md';
    case LogLevel.info:
      return 'info.md';
    case LogLevel.design:
      return 'design.md';
    case LogLevel.warning:
      return 'warning.md';
    case LogLevel.error:
      return 'error.md';
  }
}

/// Maps LogLevel to dart:developer log level
int _getDeveloperLevel(LogLevel level) {
  switch (level) {
    case LogLevel.debug:
      return 500; // FINE
    case LogLevel.info:
      return 800; // INFO
    case LogLevel.design:
      return 800; // INFO
    case LogLevel.warning:
      return 900; // WARNING
    case LogLevel.error:
      return 1000; // SEVERE
  }
}
