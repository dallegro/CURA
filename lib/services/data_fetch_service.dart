// data_fetch_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';

class DataFetchService {
  Future<Map<String, dynamic>?> fetchHospitalInfo() async {
    try {
      final hospitalInfoJson =
          await rootBundle.loadString('assets/korean_hospital_Info.json');
      return jsonDecode(hospitalInfoJson);
    } catch (error) {
      print('병원 정보 가져오기 에러: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchSidoData() async {
    try {
      final sidoString =
          await rootBundle.loadString('assets/korean_regions.json');
      return jsonDecode(sidoString);
    } catch (error) {
      print('지역 정보 가져오기 에러: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchHealthcareData() async {
    try {
      final healthcareDataJson =
          await rootBundle.loadString('assets/healthcare_data_structure.json');
      return jsonDecode(healthcareDataJson);
    } catch (error) {
      print('건강 관련 데이터 가져오기 에러: $error');
      return null;
    }
  }
}
