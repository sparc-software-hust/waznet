import 'package:equatable/equatable.dart';

enum FirebaseStatus { noToken, haveToken }

class FirebaseState extends Equatable {
  const FirebaseState({
    this.status = FirebaseStatus.noToken
  });

  final FirebaseStatus status;

  FirebaseState copyWith(FirebaseStatus? firebaseStatus) {
    return FirebaseState(status: firebaseStatus ?? status);
  }


  @override
  List<Object?> get props => [];

}