import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/fetch_users/fetch_users_state.dart';
import 'package:cecr_unwomen/features/user/repository/user_api.dart';
import 'package:cecr_unwomen/features/user/repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchUsersCubit extends Cubit<FetchUsersState> {
  FetchUsersCubit() : super(const FetchUsersState());

  Future<void> fetchUsers({required int roleId, bool reload = false}) async {
    emit(state.copyWith(status: FetchStatus.loading));
    try {
      // prevent spam call api
      List<User> users = [];
      if (roleId == 3 && state.scraperUsers.isNotEmpty && !reload) {
        users = state.scraperUsers;
      } else if (roleId == 2 && state.householdUsers.isNotEmpty && !reload) {
        users = state.householdUsers;
      } 
      else {
        await Future.delayed(const Duration(seconds: 1));
        users = await UserRepository.getListContributedUser(
          data: {
            "role_id_filter": roleId
          },
          onError: () {
            emit(state.copyWith(status: FetchStatus.fail));
          }
        );
      }

      switch(roleId) {
        case 2: emit(state.copyWith(status: FetchStatus.success, householdUsers: users,));
        case 3: emit(state.copyWith(status: FetchStatus.success, scraperUsers: users,));
      }
    } catch(e) {
      emit(state.copyWith(status: FetchStatus.fail));
    }
  }

  Future<void> fetchDeletedUsers({required int roleId}) async {
    emit(state.copyWith(status: FetchStatus.loading));
    try {
      // prevent spam call api
      List<User> users = [];
      if (roleId == 3 && state.deletedScraperUsers.isNotEmpty) {
        users = state.deletedScraperUsers;
      } else if (roleId == 2 && state.deletedHouseholdUsers.isNotEmpty) {
        users = state.deletedHouseholdUsers;
      } 
      else {
        await Future.delayed(const Duration(seconds: 1));
        users = await UserRepository.getListContributedUser(
          data: {
            "role_id_filter": roleId,
            "is_deleted": true
          },
          onError: () {
            emit(state.copyWith(status: FetchStatus.fail));
          }
        );
      }

      switch(roleId) {
        case 2: emit(state.copyWith(status: FetchStatus.success, deletedHouseholdUsers: users,));
        case 3: emit(state.copyWith(status: FetchStatus.success, deletedScraperUsers: users,));
      }
    } catch(e) {
      emit(state.copyWith(status: FetchStatus.fail));
    }
  }

  Future<void> loadMoreUsers({required int roleId}) async {
    final bool isHousehold = roleId == 2;
    final List<User> users = isHousehold ? state.householdUsers : state.scraperUsers;
    // loading
    if (isHousehold) {
      emit(state.copyWith(isLoadingMoreHousehold: true));
    } else {
      emit(state.copyWith(isLoadingMoreScraper: true));
    }
    try {
      await Future.delayed(const Duration(seconds: 1));
      final List<User> data = await UserRepository.getListContributedUser(
        data: {
          "role_id_filter": roleId,
          "last_inserted_at": users.last.insertedAt?.toIso8601String(),
      });


      switch(roleId) {
        case 2: 
          bool hasMore = data.isNotEmpty;
          if (hasMore) {
            emit(state.copyWith(status: FetchStatus.success, householdUsers:  [...users, ...data], hasMoreHousehold: true, isLoadingMoreHousehold: false));
          } else {
            emit(state.copyWith(hasMoreHousehold: false, isLoadingMoreHousehold: false));
          }
          break;
        case 3:          
          bool hasMore = data.isNotEmpty;
          if (hasMore) {
            emit(state.copyWith(status: FetchStatus.success, scraperUsers:  [...users, ...data], hasMoreScraper: true, isLoadingMoreScraper: false));

          } else {
            emit(state.copyWith(hasMoreScraper: false, isLoadingMoreScraper: false));
          }
      }
    } catch(e) {
      emit(state.copyWith(isLoadingMoreHousehold: false, isLoadingMoreScraper: false));
    }
  }

  Future<void> deleteUser({required String userId, required int roleId, Function()? onError, bool needCallApi = true}) async {
    emit(state.copyWith(status: FetchStatus.loading));
    try {
      await UserApi.deleteUser(
        data: {
          "user_id": userId,
        }, 
        onError: onError
      );

      switch (roleId) {
        case 2:
          final List<User> users = state.householdUsers;
          users.removeWhere((user) => user.id == userId);
          emit(state.copyWith(status: FetchStatus.success, householdUsers: users));
          break;
        case 3:
          final List<User> users = state.scraperUsers;
          users.removeWhere((user) => user.id == userId);
          emit(state.copyWith(status: FetchStatus.success, scraperUsers: users));
          break;
      }
    } catch(e) {
      emit(state.copyWith(status: FetchStatus.success));
    }
  }
}