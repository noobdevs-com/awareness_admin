class Event {
  String? title;
  String? description;
  String? status;
  String? did;
  DateTime? createdAt;
  DateTime? startTime;
  List images = [];

  Event({
    this.description,
    this.title,
    this.status,
    this.startTime,
    this.did,
    this.images = const [],
  });
}
