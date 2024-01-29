// api_service.dart

// 필요한 패키지 및 모듈 import
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';

const serviceKey =
    'vb5RGCB4/miY9MgndaA0MBC/ltwXWvXKUuPXpnH/Tltya6A33lo5DkNZyfBNOQu+weTfNF156KwbUTnysEDIvw==';

class ApiService {
  final Dio _dio;
  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://apis.data.go.kr/B551182/hospInfoServicev2/',
          queryParameters: {
            'ServiceKey': serviceKey,
          },
        ));

  Future<List<Map<String, dynamic>>> fetchHospitalList({
    int page = 1,
    int itemsPerPage = 20,
    String clCd = '',
    String yadmNm = '',
    String sidoCd = '',
    String sgguCd = '',
  }) async {
    try {
      var response = await _dio.get(
        'getHospBasisList',
        queryParameters: {
          'numOfRows': '$itemsPerPage',
          'pageNo': '$page',
          'clCd': clCd,
          'sidoCd': sidoCd,
          'sgguCd': sgguCd,
          'yadmNm': yadmNm,
        },
      );

      if (response.statusCode == 200) {
        // XML 데이터 파싱
        var parsedXml = xml.XmlDocument.parse(response.data.toString());

        List<Map<String, dynamic>> nextPageItems = [];
        // XML 데이터에서 'item' 태그 찾기
        var items = parsedXml.findAllElements('item');
        items.forEach((item) {
          Map<String, dynamic> hospitalInfo = {};

          // 태그 내의 데이터를 파싱하여 Map에 추가
          item.children.whereType<xml.XmlElement>().forEach((element) {
            hospitalInfo[element.name.local] = element.innerText;
          });

          nextPageItems.add(hospitalInfo);
        });

        return nextPageItems;
      } else {
        // 상태 코드가 200이 아닌 경우 에러 처리
        print('상태 코드 오류: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      // Dio 오류 처리
      print('Dio 오류: $e');
      return [];
    } on xml.XmlParserException catch (e) {
      // XML 파싱 오류 처리
      print('XML 파싱 오류: $e');
      return [];
    } catch (e) {
      // 기타 예외 상황 처리
      print('오류: $e');
      return [];
    }
  }
}

class DrugInfo {
  final Dio _dio;
  DrugInfo()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/',
          queryParameters: {
            'ServiceKey': serviceKey,
          },
        ));

// 의약품개요정보 조회
// 업체명,
// 제품명,
// 품목기준코드,
// 효능,
// 사용법,
// 주의사항,
// 상호작용,
// 부작용,
// 보관법
// 등 정보를 목록으로 조회

  Future<List<Map<String, dynamic>>> fetchDrugList({
    int page = 1,
    int itemsPerPage = 20,
    String entpName = '',
    String itemName = '',
    String itemSeq = '',
    String efcyQesitm = '',
    String useMethodQesitm = '',
    String atpnWarnQesitm = '',
    String atpnQesitm = '',
    String intrcQesitm = '',
    String seQesitm = '',
    String depositMethodQesitm = '',
    String openDe = '',
    String updateDe = '',
    String type = 'xml',
  }) async {
    try {
      var response = await _dio.get(
        'getHospBasisList',
        queryParameters: {
          'pageNo': '$page', //페이지번호
          'numOfRows': '$itemsPerPage', //한 페이지 결과 수
          'entpName': entpName, //업체명
          'itemName': itemName, //제품명
          'itemSeq': itemSeq, //품목기준코드
          'efcyQesitm': efcyQesitm, //이 약의 효능은 무엇입니까?
          'useMethodQesitm': useMethodQesitm, //이 약은 어떻게 사용합니까?
          'atpnWarnQesitm': atpnWarnQesitm, //이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?
          'atpnQesitm': atpnQesitm, //이 약의 사용상 주의사항은 무엇입니까?
          'intrcQesitm': intrcQesitm, //이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?
          'seQesitm': seQesitm, //이 약은 어떤 이상반응이 나타날 수 있습니까?
          'depositMethodQesitm': depositMethodQesitm, //이 약은 어떻게 보관해야 합니까?
          'openDe': openDe, //공개일자
          'updateDe': updateDe, //수정일자
          'type': type, //응답데이터 형식(xml/json) Default:xml
        },
      );

      if (response.statusCode == 200) {
        // XML 데이터 파싱
        var parsedXml = xml.XmlDocument.parse(response.data.toString());

        List<Map<String, dynamic>> nextPageItems = [];
        // XML 데이터에서 'item' 태그 찾기
        var items = parsedXml.findAllElements('item');
        items.forEach((item) {
          Map<String, dynamic> drugInfo = {};

          // 태그 내의 데이터를 파싱하여 Map에 추가
          item.children.whereType<xml.XmlElement>().forEach((element) {
            drugInfo[element.name.local] = element.innerText;
          });

          nextPageItems.add(drugInfo);
        });

        return nextPageItems;
      } else {
        // 상태 코드가 200이 아닌 경우 에러 처리
        print('상태 코드 오류: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      // Dio 오류 처리
      print('Dio 오류: $e');
      return [];
    } on xml.XmlParserException catch (e) {
      // XML 파싱 오류 처리
      print('XML 파싱 오류: $e');
      return [];
    } catch (e) {
      // 기타 예외 상황 처리
      print('오류: $e');
      return [];
    }
  }
}
