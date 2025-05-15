import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:equatable/equatable.dart';

enum FetchStatus {init, loading, fail, success}


final class FetchUsersState extends Equatable {
  final FetchStatus status;
  final List<User> householdUsers;
  final List<User> deletedHouseholdUsers;
  final List<User> scraperUsers;
  final List<User> deletedScraperUsers;
  final bool hasMoreHousehold;
  final bool isLoadingMoreHousehold;
  final bool hasMoreScraper;
  final bool isLoadingMoreScraper;
  final bool isDeletedUser;

  const FetchUsersState({
    this.status = FetchStatus.init,
    this.householdUsers = const [],
    this.deletedHouseholdUsers = const [],
    this.scraperUsers = const [],
    this.deletedScraperUsers = const [],
    this.hasMoreHousehold = true,
    this.hasMoreScraper = true,
    this.isLoadingMoreHousehold = false,
    this.isLoadingMoreScraper = false,
    this.isDeletedUser = false,
  });

  @override
  List<Object?> get props => [status, householdUsers, deletedHouseholdUsers, scraperUsers, deletedScraperUsers, hasMoreHousehold, hasMoreScraper, isLoadingMoreHousehold, isLoadingMoreScraper, isDeletedUser];

  FetchUsersState copyWith({
    FetchStatus? status,
    List<User>? householdUsers,
    List<User>? deletedHouseholdUsers,
    List<User>? scraperUsers,
    List<User>? deletedScraperUsers,
    bool? hasMoreHousehold,
    bool? hasMoreScraper,
    bool? isLoadingMoreHousehold,
    bool? isLoadingMoreScraper, 
    bool? isDeletedUser,
  }) {
    return FetchUsersState(
      status: status ?? this.status,
      householdUsers: householdUsers ?? this.householdUsers,
      deletedHouseholdUsers: deletedHouseholdUsers ?? this.deletedHouseholdUsers,
      scraperUsers: scraperUsers ?? this.scraperUsers,
      deletedScraperUsers: deletedScraperUsers ?? this.deletedScraperUsers,
      hasMoreHousehold: hasMoreHousehold ?? this.hasMoreHousehold,
      hasMoreScraper: hasMoreScraper ?? this.hasMoreScraper,
      isLoadingMoreHousehold: isLoadingMoreHousehold ?? this.isLoadingMoreHousehold,
      isLoadingMoreScraper: isLoadingMoreScraper ?? this.isLoadingMoreScraper,
      isDeletedUser: isDeletedUser ?? this.isDeletedUser,
    );
  }
}