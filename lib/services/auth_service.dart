//auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 사용자 정보 가져오기
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    // TODO: 강력한 비밀번호 조건 추가 (예: 최소 길이, 특수문자, 숫자, 대문자 등)
    return password.length >= 8; // 길이만으로 검증하는 예시
  }

  // 회원가입 함수
  Future<String?> register(String email, String password) async {
    if (!isEmailValid(email)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    if (!isStrongPassword(password)) {
      return '보안을 위해 강력한 비밀번호를 설정해주세요.';
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // 회원가입 성공
    } on FirebaseAuthException catch (e) {
      return '회원가입에 실패했습니다: ${e.message}';
    } catch (e) {
      return '회원가입에 실패했습니다: ${e.toString()}';
    }
  }

  // 로그인 함수
  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw '로그인에 실패했습니다: ${e.message}';
    } catch (e) {
      throw '로그인에 실패했습니다: ${e.toString()}';
    }
  }

  // 게스트 로그인 함수
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw '게스트 로그인에 실패했습니다: ${e.message}';
    } catch (e) {
      throw '게스트 로그인에 실패했습니다: ${e.toString()}';
    }
  }

  // 사용자 프로필 업데이트 함수
  Future<String?> updateUserProfile(String displayName, String photoURL) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        return null; // 프로필 업데이트 성공
      } else {
        return '사용자를 찾을 수 없습니다.';
      }
    } on FirebaseAuthException catch (e) {
      return '프로필 업데이트에 실패했습니다: ${e.message}';
    } catch (e) {
      return '프로필 업데이트에 실패했습니다: ${e.toString()}';
    }
  }

  // 이메일 확인 링크 보내기
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    try {
      await user?.sendEmailVerification();
    } catch (e) {
      throw '이메일 확인 링크를 보내는데 실패했습니다: ${e.toString()}';
    }
  }

  // 비밀번호 재설정 링크 보내기
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw '비밀번호 재설정 링크를 보내는데 실패했습니다: ${e.toString()}';
    }
  }

  // 회원 탈퇴 함수
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw '회원 탈퇴에 실패했습니다: ${e.toString()}';
    }
  }

  // 로그아웃 함수
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw '로그아웃에 실패했습니다: ${e.toString()}';
    }
  }
}
