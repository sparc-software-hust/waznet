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
    final List<User> users = roleId == 2 ? state.householdUsers : state.scraperUsers;
    emit(state.copyWith(status: FetchStatus.loadMore));
    try {
      final List<User> data = await UserRepository.getListContributedUser(
        data: {
          "role_id_filter": roleId,
          "last_inserted_at": users.last.insertedAt,
      });


      switch(roleId) {
        case 2: emit(state.copyWith(status: FetchStatus.success, householdUsers:  [...users, ...data],));
        case 3: emit(state.copyWith(status: FetchStatus.success, scraperUsers: [...users, ...data]));
      }
    } catch(e) {
      emit(state.copyWith(status: FetchStatus.fail));
    }
  }
}