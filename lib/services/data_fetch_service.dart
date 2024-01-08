import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cura_health/models/hospital_model.dart'; // hospital_model.dart 파일을 import합니다.

class DataFetchService {
  static Future<Map<String, Map<String, String>>> fetchSidoData() async {
    try {
      final sidoString =
          await rootBundle.loadString('assets/korean_regions.json');
      final List<dynamic> regions = jsonDecode(sidoString)['regions'];

      final Map<String, Map<String, String>> processedSidoData = {};

      for (var region in regions) {
        final Map<String, String> districtMap = {};
        final districts = region['districts'];
        districts.forEach((district) {
          districtMap[district['name']] = district['code'].toString();
        });
        processedSidoData[region['name']] = districtMap;
      }

      return processedSidoData;
    } catch (error) {
      print('에러: $error');
      return {};
    }
  }

  static Future<Map<String, HospitalInfo>> fetchHospitalInfo() async {
    try {
      final hospitalInfo =
          await rootBundle.loadString('assets/korean_hospital_info.json');
      final Map<String, dynamic> hospitalInfoData = jsonDecode(hospitalInfo);
      final Map<String, dynamic> hospitalInfoMap =
          hospitalInfoData['HospitalInfo'];

      return hospitalInfoMap.map((key, value) {
        return MapEntry(
          key,
          HospitalInfo.fromJson(value),
        );
      });
    } catch (error) {
      print('에러: $error');
      return {};
    }
  }
}
