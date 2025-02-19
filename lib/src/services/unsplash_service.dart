import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _accessKey =
      '6BCnUd8uOQVNOSK6A2qubfjOJ2zmw07OSNbPKiVNXgU';
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<List<String>> getImagesByCategory(
    String query, {
    String size = 'regular',
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/photos?query=$query&page=$page&per_page=$perPage',
        ),
        headers: {
          'Authorization': 'Client-ID $_accessKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        return results.map<String>((photo) {
          return photo['urls'][size] as String;
        }).toList();
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  String convertCategoryToSearchTerm(String category) {
    // 中文分类映射到英文搜索关键词
    final Map<String, String> categoryMapping = {
      '照片': 'photos',
      '插画': 'illustrations',
      '壁纸': 'wallpapers',
      '自然': 'nature',
      '3D': '3d renders',
      '纹理': 'textures',
      '建筑': 'architecture & interiors',
      '旅行': 'travel',
      '电影': 'film',
      '街拍': 'street photography',
      '人物': 'people',
      '动物': 'animals',
      '实验': 'experimental',
      '时尚': 'fashion & beauty',
      '美食': 'food & drink',
      '运动': 'sports',
      '健康': 'health & wellness',
    };

    return categoryMapping[category] ?? category;
  }
}
