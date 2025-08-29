part of '../dnf_growth_recommender.dart';

class ServiceDnf {
  static ServiceDnf? _instance;

  factory ServiceDnf.getInstance() => _instance ??= ServiceDnf._internal();

  ServiceDnf._internal();

  CustomSubject<MRecommended> subject = CustomSubject<MRecommended>();

  /// 추천 결과를 타입 세이프한 모델로 반환
  Future<MRecommended?> getRecommendation({
    String server = 'casillas',
    String id = 'horoli',
    String? gold,
  }) async {
    try {
      final Uri url = gold == null
          ? Uri.parse(
              '${PATH.URL_BASE}/${PATH.URL_RECOMMEND}?server=$server&name=$id&limit=5',
            )
          : Uri.parse(
              '${PATH.URL_BASE}/${PATH.URL_RECOMMEND}?server=$server&name=$id&gold=$gold&limit=5',
            );

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        // ✅ JSON → Model 파싱
        final Map<String, dynamic> data = json.decode(response.body);
        final MRecommended result = MRecommended.fromJson(data);
        // 디버깅용 출력
        print('[DNF] character=${result.character.characterName} '
            'slots=${result.summary.totalSlots}');

        subject.sink(result);
        return result;
      } else {
        // 에러 응답 로그
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      // 네트워크/파싱 예외 처리
      print('Error occurred: $e');
      return null;
    }
  }
}
