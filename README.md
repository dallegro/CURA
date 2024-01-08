# CURA Health Mobile App

CURA Health는 Flutter를 사용하여 개발된 모바일 의료 서비스 애플리케이션입니다. 이 애플리케이션은 Firebase를 이용한 인증과 의료기관 목록을 가져오는 API 서비스를 포함하고 있습니다.

## 프로젝트 구조

cura_health/
├── android/
├── assets/
│   ├── fonts/
│   │   ├── NotoSans-Bold.ttf
│   │   └── NotoSans-Regular.ttf
│   ├── korean_hospital_info.json
│   ├── korean_regions.json
│   └── healthcare_data_structure.json
├── ios/
├── lib/
│   ├── models/
│   │   └── hospital_model.dart
│   ├── components/
│   │   ├── custom_button.dart
│   │   └── ...
│   ├── screens/
│   │   ├── hospital_list_screen.dart
│   │   ├── hospital_detail_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── profile_screen.dart
│   │   └── ...
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── api_service.dart
│   ├── utils/ 
│   │   └── snackbar_helper.dart 
│   └── main.dart
├── test/
└── pubspec.yaml


## 사용법

### Firebase 초기화

`lib/firebase_options.dart` 파일에서 Firebase 구성을 확인하세요. Firebase는 `lib/main.dart` 파일에서 `Firebase.initializeApp()`을 통해 초기화됩니다.

### 화면 이동 및 라우팅

`lib/main.dart` 파일에서 각각의 화면과 라우트를 설정하세요. 기본 홈 화면은 `LoginScreen()`으로 설정되어 있습니다.

### 인증(Authentication)

`AuthService` 클래스(`lib/services/auth_service.dart`)를 사용하여 회원가입, 로그인 등의 인증 기능을 수행할 수 있습니다.

### 의료기관 목록 API

`ApiService` 클래스(`lib/services/api_service.dart`)를 사용하여 의료기관 목록을 가져올 수 있습니다. 병원 정보는 XML 형식으로 제공되며, Dio를 사용하여 API 호출 및 XML 파싱을 수행합니다.

### 예시

- Firebase 초기화 코드: `lib/main.dart`
- 로그인 및 회원가입 기능: `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`
- 의료기관 목록 가져오기: `lib/services/api_service.dart`의 `fetchHospitalList()` 메서드를 사용할 수 있습니다.

## 환경 설정

### 프로젝트 초기화

이 앱을 실행하려면 Flutter 개발 환경이 필요합니다. Flutter가 설치되어 있지 않은 경우 [Flutter 설치 가이드](https://flutter.dev/docs/get-started/install)를 참고하여 설치하세요.

### Firebase 설정

Firebase를 사용하기 위해서는 Firebase 프로젝트가 필요합니다. 프로젝트에 Firebase를 추가하고 Firebase 설정 파일을 프로젝트에 연결하세요.

### 외부 데이터 파일

앱에서 사용되는 외부 데이터 파일은 `assets/` 폴더에 위치합니다. 병원 정보와 관련된 JSON 및 기타 데이터 파일은 해당 폴더에 저장되어 있습니다.

## 기능

### 로그인 및 회원가입

로그인 화면(`lib/screens/login_screen.dart`)에서 이메일과 비밀번호를 사용하여 로그인하거나, 회원가입할 수 있습니다. `AuthService`를 통해 인증을 처리합니다.

### 의료기관 검색

병원 목록 화면(`lib/screens/hospital_list_screen.dart`)에서 API를 사용하여 의료기관 목록을 가져옵니다. `ApiService`를 통해 API 호출 및 데이터를 파싱하여 표시합니다.

### 프로필 관리

프로필 화면(`lib/screens/profile_screen.dart`)에서 사용자의 프로필 정보를 업데이트하거나, 로그아웃하거나, 계정을 삭제할 수 있습니다. `AuthService`를 이용하여 프로필을 관리합니다.


