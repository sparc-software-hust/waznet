import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/user/domain/bloc/fetch_users/fetch_users_state.dart';
import 'package:cecr_unwomen/features/user/repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchUsersCubit extends Cubit<FetchUsersState> {
  FetchUsersCubit() : super(const FetchUsersState());

  Future<void> fetchUsers({required int roleId}) async {
    emit(state.copyWith(status: FetchStatus.loading));
    try {
      // prevent spam
      List<User> users = [];
      if (roleId == 3 && state.scraperUsers.isNotEmpty) {
        users = state.scraperUsers;
      } else if (roleId == 2 && state.householdUsers.isNotEmpty) {
        users = state.householdUsers;
      } 
      else {
        await Future.delayed(const Duration(seconds: 1));
        users = await UserRepository.getListContributedUser(data: {
          "role_id_filter": roleId
        });
      }

      switch(roleId) {
        case 2: emit(state.copyWith(status: FetchStatus.success, householdUsers:  users,));
        case 3: emit(state.copyWith(status: FetchStatus.success, scraperUsers:  users,));
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
}