import 'package:schedule_management/database/drift_database.dart';

// schedule의 schedules가 아닌 .g의 schedule임
class ScheduleWithCategory {
  final Schedule schedule;
  final CategoryColor categoryColor;

  ScheduleWithCategory({
    required this.schedule,
    required this.categoryColor,
  });
}