// api_service.dart

// 필요한 패키지 및 모듈 import
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
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
        var parsedXml = xml.XmlDocument.parse(response.data.toString());

        List<Map<String, dynamic>> nextPageItems = [];

        var items = parsedXml.findAllElements('item');
        items.forEach((item) {
          Map<String, dynamic> hospitalInfo = {};

          item.children.whereType<xml.XmlElement>().forEach((element) {
            hospitalInfo[element.name.local] = element.innerText;
          });

          nextPageItems.add(hospitalInfo);
        });

        return nextPageItems;
      } else {
        print('상태 코드 오류: ${response.statusCode}');
        return [];
      }
    } on DioError catch (e) {
      print('Dio 오류: $e');
      return [];
    } on xml.XmlParserException catch (e) {
      print('XML 파싱 오류: $e');
      return [];
    } catch (e) {
      print('오류: $e');
      return [];
    }
  }
}
