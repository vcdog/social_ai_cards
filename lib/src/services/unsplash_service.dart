import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _accessKey =
      '6BCnUd8uOQVNOSK6A2qubfjOJ2zmw07OSNbPKiVNXgU';
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<List<String>> getImagesByCategory(String category,
      {String size = 'regular'}) async {
    // 将中文分类转换为英文关键词
    final String searchTerm = _convertCategoryToSearchTerm(category);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/photos?query=$searchTerm&per_page=10'),
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1', // 添加 API 版本
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        // 使用指定尺寸的图片 URL
        return results
            .map<String>((photo) => photo['urls'][size] as String)
            .toList();
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  String _convertCategoryToSearchTerm(String category) {
    // 中文分类映射到英文搜索关键词
    final Map<String, String> categoryMapping = {
      '热门': 'trending social media',
      '节日': 'festival celebration',
      '商务': 'business professional',
      '社交': 'social media lifestyle',
      '生活': 'daily life moments',
      '创意': 'creative design',
      '其他': 'miscellaneous social',
      // 添加作品展示相关的搜索词
      'creative portfolio': 'creative portfolio work showcase',
    };

    return categoryMapping[category] ?? category;
  }
}
