abstract class FirebaseEvent{}

class SetupFirebaseToken extends FirebaseEvent{}
// class SetupInteractedMessage extends FirebaseEvent{}
class TokenRefresh extends FirebaseEvent{}
// class ReceiveMessageBackground extends FirebaseEvent{}
class ReceiveMessageForeground extends FirebaseEvent{}
class OpenMessageBackground extends FirebaseEvent{}
class OpenMessageTerminated extends FirebaseEvent{}