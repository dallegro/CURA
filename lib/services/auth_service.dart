//auth_service.dart

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  final picker = ImagePicker();
  // 사용자 정보 가져오기
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    // 최소 8자 이상, 대소문자, 숫자, 특수문자 포함 여부 확인
    final passwordRegExp = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }
//개선한 회원가입 함수

  Future<User?> signup({
    required String name,
    required String email,
    required String password,
    required File photo,
  }) async {
    if (!isEmailValid(email)) {
      throw FormatException('올바른 이메일 형식이 아닙니다.');
    }

    // 비밀번호는 최소 8자 이상, 특수문자, 숫자, 대문자 포함하여야 함
    if (!isStrongPassword(password)) {
      throw FormatException('비밀번호는 최소 8자 이상이어야 하며, 특수문자, 숫자, 대문자를 포함해야 합니다.');
    }

    try {
      final existingUser = await _auth.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: '이미 사용 중인 이메일 주소입니다. 다른 이메일을 입력해주세요.',
        );
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // signup 함수 내에서 imageFile을 전달하여 업로드
      String? photoURL = await _imageUploadService.uploadImage(photo);

      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(photoURL);

      if (user == null) {
        throw Exception('회원가입 중 오류가 발생했습니다.');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const FormatException('이미 사용 중인 이메일 주소입니다. 다른 이메일을 입력해주세요.');
      } else if (e.code == 'weak-password') {
        throw const FormatException(
            '비밀번호는 최소 8자 이상이어야 하며, 특수문자, 숫자, 대문자를 포함해야 합니다.');
      } else if (e.code == 'invalid-email') {
        throw const FormatException('올바른 이메일 형식이 아닙니다.');
      } else {
        // 예외 처리되지 않은 다른 FirebaseAuthException들을 여기서 처리
        print('FirebaseAuthException 발생: ${e.code}, ${e.message}');
        throw e;
      }
    } on FormatException catch (e) {
      print('잘못된 형식의 데이터 입력: $e');
      throw e;
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
      throw e;
    }
  }

  // 기존 회원가입 함수
/*   Future<String?> register(String email, String password) async {
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
 */
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
  Future<String?> updateUserProfile(String displayName, File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? photoURL = await _imageUploadService.uploadImage(imageFile);
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
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

class ImageUploadService {
  final _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile) async {
    try {
      TaskSnapshot snapshot = await _storage
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(imageFile);
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Firebase Storage 이미지 업로드 중 오류 발생: $e');
      print('내부 예외: ${e.toString()}');

      return null;
    }
  }
}
