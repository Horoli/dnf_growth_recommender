part of '../dnf_growth_recommender.dart';

class ServiceDnf {
  static ServiceDnf? _instance;

  factory ServiceDnf.getInstance() => _instance ??= ServiceDnf._internal();

  ServiceDnf._internal();

  CustomSubject<MRecommended> subject = CustomSubject<MRecommended>();

  /// 추천 결과를 타입 세이프한 모델로 반환
  Future<HResponse<MRecommended>> getRecommendation({
    String server = 'casillas',
    String id = 'horoli',
    required String gold,
  }) async {
    try {
      final Uri url = Uri.parse(
        '${PATH.URL_BASE}/${PATH.URL_RECOMMEND}?server=$server&name=$id&gold=$gold&limit=5',
      );

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final MRecommended result = MRecommended.fromJson(data);

        print('[DNF] character=${result.character.characterName} '
            'slots=${result.summary.totalSlots}');

        subject.sink(result);
        return HResponse.success(result);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');

        // 상태 코드별 에러 메시지
        String errorMessage = switch (response.statusCode) {
          404 => '캐릭터를 찾을 수 없습니다.${response.body}',
          500 => '서버 오류가 발생했습니다.',
          _ => '요청 실패 (${response.statusCode})',
        };

        return HResponse.error(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      return HResponse.networkError('네트워크 오류: $e');
    }
  }
}
