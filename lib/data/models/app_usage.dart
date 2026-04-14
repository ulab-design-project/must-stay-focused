import 'package:isar/isar.dart';
import 'user_settings.dart';

part 'app_usage.g.dart';

@collection
class AppUsage {
  Id id = Isar.autoIncrement;

  late String name;
  
  @Index(unique: true, replace: true)
  late String appId;
  
  int totalUsedTime = 0;
  int maxDailyTimeLimit = 0;
  int overTimeLimitToday = 0;

  String challengeType = 'Math';
  
  bool isTracked = false;
  bool isLimitedToday = false;

  final user = IsarLink<UserSettings>();
}
