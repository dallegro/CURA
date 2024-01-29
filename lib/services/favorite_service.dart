//favorite_service.dart

import 'package:flutter/material.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();

  factory FavoriteService() {
    return _instance;
  }

  FavoriteService._internal();

  // 사용자가 찜한 병원 목록을 저장하는 리스트
  List<String> _favoriteHospitals = [];

  List<String> get favoriteHospitals => _favoriteHospitals;

  // 병원을 찜하거나 찜을 해제하는 메서드
  void toggleFavorite(String hospitalCode) {
    if (_favoriteHospitals.contains(hospitalCode)) {
      _favoriteHospitals.remove(hospitalCode);
    } else {
      _favoriteHospitals.add(hospitalCode);
    }
  }
}
