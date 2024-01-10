// api_service.dart

// 필요한 패키지 및 모듈 import
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://apis.data.go.kr/B551182/hospInfoServicev2/',
          queryParameters: {
            'ServiceKey':
                'vb5RGCB4/miY9MgndaA0MBC/ltwXWvXKUuPXpnH/Tltya6A33lo5DkNZyfBNOQu+weTfNF156KwbUTnysEDIvw==',
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
    } on DioError catch (e) {
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
