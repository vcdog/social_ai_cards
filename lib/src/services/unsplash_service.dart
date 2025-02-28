import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _accessKey =
      '6BCnUd8uOQVNOSK6A2qubfjOJ2zmw07OSNbPKiVNXgU';
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<List<String>> getImagesByCategory(
    String query, {
    String size = 'small',
    int page = 1,
    int perPage = 30,
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
      '全部': 'creative templates',
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
      '其他': 'miscellaneous',
    };

    return categoryMapping[category] ?? category;
  }

  Future<String> getHdImageUrl(String originalUrl) async {
    try {
      // 从原始URL中提取图片ID
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments;
      final imageId = pathSegments.last;

      // 构建高清图片URL
      final hdUrl = originalUrl.replaceAll('&w=400', '&w=1080');
      return hdUrl;
    } catch (e) {
      print('Error getting HD image URL: $e');
      return originalUrl; // 如果转换失败，返回原始URL
    }
  }
}
