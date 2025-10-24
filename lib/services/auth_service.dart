import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // (يمكننا إضافة دوال أخرى هنا مثل getUser, signOut)

  // دالة تسجيل الدخول
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // إرجاع الخطأ للـ ViewModel ليعرضه
      throw Exception(e.message);
    }
  }

  // دالة إنشاء حساب
  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // TODO: يمكنك هنا حفظ اسم المستخدم في Firestore
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // دالة إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}