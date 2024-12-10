import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await user.getIdToken();
  } else {
    return "";
  }
}

String? getCurrentUserId() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
