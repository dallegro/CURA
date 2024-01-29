//auth_service.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

// 공통 에러 핸들링 함수
void _handleError(String message, dynamic error) {
  print('$message: $error');
  throw error;
}

class AuthService {
  final FirebaseAuth _authenticationService = FirebaseAuth.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  final picker = ImagePicker();

  // 사용자 정보 가져오기
  User? getCurrentUser() {
    return _authenticationService.currentUser;
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

  // 이메일과 비밀번호로 회원 가입
  Future<User?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required File photo,
  }) async {
    try {
      if (!isEmailValid(email)) {
        throw FormatException('올바른 이메일 형식이 아닙니다.');
      }

      // 비밀번호는 최소 8자 이상, 특수문자, 숫자, 대문자 포함하여야 함
      if (!isStrongPassword(password)) {
        throw FormatException('비밀번호는 최소 8자 이상이어야 하며, 특수문자, 숫자, 대문자를 포함해야 합니다.');
      }

      final existingUser =
          await _authenticationService.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: '이미 사용 중인 이메일 주소입니다. 다른 이메일을 입력해주세요.',
        );
      }

      UserCredential userCredential =
          await _authenticationService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // signUpWithEmailAndPassword 함수 내에서 imageFile을 전달하여 업로드
      String? photoURL = await _imageUploadService.uploadImage(photo);

      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(photoURL);

      if (user == null) {
        throw Exception('회원가입 중 오류가 발생했습니다.');
      }
      // Firestore에 사용자 정보 저장
      await saveUserData(user!.uid, name, email, photoURL!);
      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(photoURL);

      return user;
    } on FirebaseAuthException catch (e) {
      _handleError('FirebaseAuthException 발생', e);
    } on FormatException catch (e) {
      _handleError('잘못된 형식의 데이터 입력', e);
    } catch (e) {
      _handleError('회원가입 중 오류 발생', e);
    }
  }

  Future<void> saveUserData(
      String uid, String name, String email, String photoURL) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'photoURL': photoURL,
        'joinDate': FieldValue.serverTimestamp(), // 현재 서버 시간으로 가입일 추가
      });
    } catch (e) {
      throw 'Firestore에 사용자 정보 저장 중 오류 발생: ${e.toString()}';
    }
  }

  // 이메일과 비밀번호로 로그인
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _authenticationService.signInWithEmailAndPassword(
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

  // 익명으로 로그인
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential userCredential =
          await _authenticationService.signInAnonymously();
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
      User? user = _authenticationService.currentUser;
      if (user != null) {
        String? photoURL = await _imageUploadService.uploadImage(imageFile);
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        return null; // 프로필 업데이트 성공
      } else {
        return '사용자를 찾을 수 없습니다.';
      }
    } on FirebaseAuthException catch (e) {
      return '프로필 업데이트에 실패했습니다: ${e.message}';
    } catch (e) {
      return '프로필 업데이트에 실패했습니다: $e';
    }
  }

  // 이메일 확인 링크 보내기
  Future<void> sendEmailVerification() async {
    User? user = _authenticationService.currentUser;
    try {
      await user?.sendEmailVerification();
    } catch (e) {
      throw '이메일 확인 링크를 보내는데 실패했습니다: ${e.toString()}';
    }
  }

  // 비밀번호 재설정 링크 보내기
  Future<void> resetPassword(String email) async {
    try {
      await _authenticationService.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw '비밀번호 재설정 링크를 보내는데 실패했습니다: ${e.toString()}';
    }
  }

  // 회원 탈퇴 함수
  Future<void> deleteAccount() async {
    try {
      await _authenticationService.currentUser?.delete();
    } catch (e) {
      throw '회원 탈퇴에 실패했습니다: ${e.toString()}';
    }
  }

  // 로그아웃 함수
  Future<void> logout() async {
    try {
      await _authenticationService.signOut();
    } catch (e) {
      throw '로그아웃에 실패했습니다: ${e.toString()}';
    }
  }
}

class ImageUploadService {
  final _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile) async {
    try {
      // 확장자 추출
      String extension = imageFile.path.split('.').last;
      String uid =
          FirebaseAuth.instance.currentUser?.uid ?? 'unknown'; // 사용자 UID 가져오기
      String fileName = 'profile_$uid.$extension'; // 프로필 사진임을 나타내는 접두사 추가

      TaskSnapshot snapshot =
          await _storage.ref().child('images/$fileName').putFile(
                imageFile,
                SettableMetadata(
                  contentType: 'image/jpeg',
                ),
              );
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      _handleError('Firebase Storage 이미지 업로드 중 오류 발생', e);
      return null;
    }
  }
}
