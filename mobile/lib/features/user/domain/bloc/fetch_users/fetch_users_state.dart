import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:equatable/equatable.dart';

enum FetchStatus {init, loading, loadMore, fail, success, loadMoreFail}


final class FetchUsersState extends Equatable {
  final FetchStatus status;
  final List<User> householdUsers;
  final List<User> scraperUsers;

  const FetchUsersState({
    this.status = FetchStatus.init,
    this.householdUsers = const [],
    this.scraperUsers = const []
  });

  @override
  List<Object?> get props => [status, householdUsers, scraperUsers];

  FetchUsersState copyWith({
    FetchStatus? status,
    List<User>? householdUsers,
    List<User>? scraperUsers,
  }) {
    return FetchUsersState(
      status: status ?? this.status,
      householdUsers: householdUsers ?? this.householdUsers,
      scraperUsers: scraperUsers ?? this.scraperUsers,
    );
  }
}