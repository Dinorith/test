import 'package:dio/dio.dart';
import '../models/category.dart';

class ApiService {
  final Dio dio;

  ApiService(String guid)
      : dio = Dio(BaseOptions(
          baseUrl: 'https://meal-db-sandy.vercel.app',
          headers: {
            'X-DB-NAME': guid,
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status! < 500,
        )) {
    dio.interceptors.add(LoggingInterceptor());
  }

  Future<Response> getMeals() => dio.get('/meals');

  Future<Response> getCategories() => dio.get('/categories');

  Future<List<Category>> getCategoriesList() async {
    try {
      final response = await dio.get('/categories');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMealsByCategory(String category) =>
      dio.get('/meals', queryParameters: {'category': category});

  Future<Response> getMealById(int id) =>
      dio.get('/meals/$id');
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST: ${options.method} ${options.path}');
    print('Headers: ${options.headers}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE: ${response.statusCode}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR: ${err.message}');
    print('Error type: ${err.type}');
    super.onError(err, handler);
  }
}
