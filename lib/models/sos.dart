class SOS {
  String? description;
  List? coordinates;
  String? did;
  DateTime? createdAt;
  List images = [];
  String? uid;

  SOS(
      {this.description,
      this.coordinates,
      this.createdAt,
      this.did,
      this.images = const [],
      this.uid});
}
