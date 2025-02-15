import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _accessKey =
      '6BCnUd8uOQVNOSK6A2qubfjOJ2zmw07OSNbPKiVNXgU';
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<List<String>> getImagesByCategory(String category) async {
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

        // 使用 small 尺寸的图片 URL，这些 URL 支持 CORS
        return results
            .map<String>((photo) => photo['urls']['small'] as String)
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
    };

    return categoryMapping[category] ?? category;
  }
}
