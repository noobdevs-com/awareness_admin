import 'package:awareness_admin/constants/constants.dart';

class Event {
  String title;
  EventStatus eventStatus;
  DateTime eventCreatedAt;
  DateTime eventAssignedAt;

  Event(
      {required this.eventStatus,
      required this.title,
      required this.eventAssignedAt,
      required this.eventCreatedAt});
}
