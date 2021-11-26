class Event {
  String? title;
  String? description;
  String? status;
  String? did;
  DateTime? createdAt;
  DateTime? startTime;
  List images = [];
  String? uid;
  String? venue;

  Event(
      {this.description,
      this.title,
      this.status,
      this.startTime,
      this.did,
      this.images = const [],
      this.uid,
      this.venue});
}
