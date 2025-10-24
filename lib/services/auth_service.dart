import 'package:firebase_auth/firebase_auth.dart'; // استيراد مكتبة Firebase Authentication

class AuthService {
  // الحصول على instance (نسخة) من FirebaseAuth للتعامل مع عمليات المصادقة
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Getters and Streams ---

  // Getter للحصول على معلومات المستخدم الحالي المسجل دخوله (User object أو null)
  User? get currentUser => _auth.currentUser;

  // Stream للاستماع لتغيرات حالة المصادقة (تسجيل الدخول / تسجيل الخروج)
  // هذا الـ Stream سيُرسل قيمة User عند تسجيل الدخول، و null عند تسجيل الخروج
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Authentication Methods ---

  // دالة تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // استدعاء دالة signInWithEmailAndPassword من FirebaseAuth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),       // إزالة المسافات الزائدة من الإيميل
        password: password.trim(),   // إزالة المسافات الزائدة من كلمة المرور
      );
      print("AuthService: User signed in: ${userCredential.user?.uid}");
      return userCredential; // إرجاع بيانات الاعتماد عند النجاح
    } on FirebaseAuthException catch (e) {
      // التعامل مع أخطاء Firebase المعروفة (مثل كلمة مرور خاطئة، مستخدم غير موجود)
      print("AuthService: Error signing in - ${e.code}: ${e.message}");
      // إرسال الخطأ مع رسالة واضحة للـ ViewModel
      throw Exception(e.message ?? "An unknown error occurred during sign in.");
    } catch (e) {
      // التعامل مع أي أخطاء أخرى غير متوقعة
      print("AuthService: Unexpected error signing in: ${e.toString()}");
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // دالة إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential> signUp(String email, String password) async {
    try {
      // استدعاء دالة createUserWithEmailAndPassword من FirebaseAuth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      print("AuthService: User signed up: ${userCredential.user?.uid}");
      // (بعد هذه الخطوة، عادةً ما يتم استدعاء DbService لحفظ بيانات المستخدم الإضافية)
      return userCredential; // إرجاع بيانات الاعتماد عند النجاح
    } on FirebaseAuthException catch (e) {
      // التعامل مع أخطاء Firebase (مثل إيميل مستخدم بالفعل، كلمة مرور ضعيفة)
      print("AuthService: Error signing up - ${e.code}: ${e.message}");
      throw Exception(e.message ?? "An unknown error occurred during sign up.");
    } catch (e) {
      print("AuthService: Unexpected error signing up: ${e.toString()}");
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // دالة إرسال بريد إلكتروني لإعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // استدعاء دالة sendPasswordResetEmail من FirebaseAuth
      await _auth.sendPasswordResetEmail(email: email.trim());
      print("AuthService: Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      // التعامل مع أخطاء Firebase (مثل إيميل غير موجود)
      print("AuthService: Error sending reset email - ${e.code}: ${e.message}");
      throw Exception(e.message ?? "An unknown error occurred sending reset email.");
    } catch (e) {
      print("AuthService: Unexpected error sending reset email: ${e.toString()}");
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // دالة تسجيل الخروج
  Future<void> signOut() async {
    try {
      // استدعاء دالة signOut من FirebaseAuth
      await _auth.signOut();
      print("AuthService: User signed out successfully.");
    } catch (e) {
      // معالجة أي أخطاء قد تحدث أثناء تسجيل الخروج
      print("Error signing out: $e");
      // يمكنك إرسال الخطأ إذا أردت التعامل معه في الـ ViewModel
      // throw Exception("Could not sign out.");
    }
  }
}