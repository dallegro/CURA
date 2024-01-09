// hospital_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:cura_health/services/api_service.dart';

class HospitalSearchDelegate extends SearchDelegate<void> {
  final List<Map<String, dynamic>> hospitalList; // 병원 목록
  final Function(String) onSearch; // 검색 함수
  final ApiService _apiService = ApiService(); // API 서비스 인스턴스

  HospitalSearchDelegate(this.hospitalList, this.onSearch);

  // 검색 입력창 오른쪽에 'Clear' 버튼 표시
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // 검색어 초기화
          showSuggestions(context); // 제안 목록 표시
        },
      ),
    ];
  }

  // 검색 입력창 왼쪽에 'Back' 버튼 표시
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // 검색 창 닫기
      },
    );
  }

  // 검색 결과 표시
  @override
  Widget buildResults(BuildContext context) {
    // 검색어가 비어있으면 안내 메시지 표시
    if (query.isEmpty) {
      return const Center(
        child: Text('검색어를 입력하세요.'),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _apiService.fetchHospitalList(yadmNm: query),
      builder: (context, snapshot) {
        // 데이터 로딩 중인 경우 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // 에러 발생 시 에러 메시지 표시
          return Center(
            child: Text('에러: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 검색 결과 없을 경우 안내 메시지 표시
          return const Center(
            child: Text('검색 결과 없음.'),
          );
        } else {
          // 검색 결과가 있는 경우 리스트로 표시
          List<Map<String, dynamic>> searchResults = snapshot.data!;
          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final hospital = searchResults[index];
              return ListTile(
                title: Text(hospital['yadmNm']),
                subtitle: Text(hospital['addr']),
                onTap: () {
                  onSearch(query);
                  close(context, null);
                },
              );
            },
          );
        }
      },
    );
  }

  // 검색어 제안 목록 표시
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = hospitalList.where((hospital) =>
        hospital['yadmNm'].toLowerCase().contains(query.toLowerCase()) ||
        hospital['addr'].toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final hospital = suggestionList.elementAt(index);
        return ListTile(
          title: Text(hospital['yadmNm']),
          subtitle: Text(hospital['addr']),
          onTap: () {
            onSearch(hospital['yadmNm']);
            close(context, null);
          },
        );
      },
    );
  }
}
