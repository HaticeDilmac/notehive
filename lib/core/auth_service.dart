import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Check current user session
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if email is verified
      if (result.user != null && !result.user!.emailVerified) {
        throw Exception('Lütfen giriş yapmadan önce email adresinizi doğrulayın. Gelen kutunuzu kontrol edin.');
      }
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Bu email adresi kayıtlı değil. Önce kayıt olmanız gerekmektedir.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Şifre yanlış. Lütfen şifrenizi kontrol edin.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz email adresi.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Bu hesap devre dışı bırakılmış.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.');
      } else {
        throw Exception('Giriş yapılırken bir hata oluştu: ${e.message}');
      }
    }
  }

  //Register new user, update display name and send verification email
  Future<User?> register(String email, String password, String name) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(name);
      
      // Send email verification
      await result.user?.sendEmailVerification();
      
      // Sign out user until email is verified
      await _firebaseAuth.signOut();
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu email adresi zaten kayıtlı. Giriş yapmayı deneyin.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz email adresi.');
      } else {
        throw Exception('Kayıt olurken bir hata oluştu: ${e.message}');
      }
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  // Reload user to get latest email verification status
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  //password reset function
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Bu email adresi kayıtlı değil.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz email adresi.');
      } else {
        throw Exception('Şifre sıfırlama emaili gönderilirken bir hata oluştu: ${e.message}');
      }
    }
  }

  //sign out function
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Delete user account
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  User? get currentUser => _firebaseAuth.currentUser; //get current user
}
