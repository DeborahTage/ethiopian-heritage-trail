abstract class PackageEvent {}

class LoadPackage extends PackageEvent {
  final String landmarkId;
  LoadPackage(this.landmarkId);
}
