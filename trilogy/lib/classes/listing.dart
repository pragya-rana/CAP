// This class represents a listing that is offered by the partner.
class Listing {
  String applicationRef;
  String refName;
  String logo_url;
  String name;
  String title;
  String description;
  String type;
  String location;
  String gradeLevel;
  DateTime deadline;

  Listing(
      this.applicationRef,
      this.refName,
      this.logo_url,
      this.name,
      this.title,
      this.description,
      this.location,
      this.type,
      this.gradeLevel,
      this.deadline);
}
