import '../models/models.dart';

abstract class PackageState {}

class PackageInitial extends PackageState {}

class PackageLoading extends PackageState {}

class PackageLoaded extends PackageState {
  final AdventurePackageModel package;
  PackageLoaded(this.package);
}

class PackageNotFound extends PackageState {
  final String message;
  PackageNotFound({this.message = 'This site has no adventure package yet.'});
}

class PackageError extends PackageState {
  final String message;
  PackageError({required this.message});
}
