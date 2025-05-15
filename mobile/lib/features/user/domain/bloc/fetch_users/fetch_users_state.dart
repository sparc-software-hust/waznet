import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:equatable/equatable.dart';

enum FetchStatus {init, loading, fail, success}


final class FetchUsersState extends Equatable {
  final FetchStatus status;
  final List<User> householdUsers;
  final List<User> scraperUsers;
  // null -> loading, true -> has more, false -> no more
  final bool hasMoreHousehold;
  final bool isLoadingMoreHousehold;
  final bool hasMoreScraper;
  final bool isLoadingMoreScraper;

  const FetchUsersState({
    this.status = FetchStatus.init,
    this.householdUsers = const [],
    this.scraperUsers = const [],
    this.hasMoreHousehold = true,
    this.hasMoreScraper = true,
    this.isLoadingMoreHousehold = false,
    this.isLoadingMoreScraper = false,
  });

  @override
  List<Object?> get props => [status, householdUsers, scraperUsers, hasMoreHousehold, hasMoreScraper, isLoadingMoreHousehold, isLoadingMoreScraper];

  FetchUsersState copyWith({
    FetchStatus? status,
    List<User>? householdUsers,
    List<User>? scraperUsers,
    bool? hasMoreHousehold,
    bool? hasMoreScraper,
    bool? isLoadingMoreHousehold,
    bool? isLoadingMoreScraper, 
  }) {
    return FetchUsersState(
      status: status ?? this.status,
      householdUsers: householdUsers ?? this.householdUsers,
      scraperUsers: scraperUsers ?? this.scraperUsers,
      hasMoreHousehold: hasMoreHousehold ?? this.hasMoreHousehold,
      hasMoreScraper: hasMoreScraper ?? this.hasMoreScraper,
      isLoadingMoreHousehold: isLoadingMoreHousehold ?? this.isLoadingMoreHousehold,
      isLoadingMoreScraper: isLoadingMoreScraper ?? this.isLoadingMoreScraper,
    );
  }
}