import 'package:equatable/equatable.dart';
import '../../models/models.dart';

// -- Events --
abstract class PassportEvent extends Equatable {
  const PassportEvent();
  @override
  List<Object?> get props => [];
}

class LoadPassport extends PassportEvent {}
class RefreshPassport extends PassportEvent {}

// -- States --
abstract class PassportState extends Equatable {
  const PassportState();
  @override
  List<Object?> get props => [];
}

class PassportLoading extends PassportState {}

class PassportLoaded extends PassportState {
  final PassportModel passport;
  const PassportLoaded(this.passport);
  @override
  List<Object?> get props => [passport];
}

class PassportError extends PassportState {
  final String error;
  const PassportError(this.error);
  @override
  List<Object?> get props => [error];
}
