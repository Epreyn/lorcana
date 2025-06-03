import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

class ApiProvider {
  static const String baseUrl = 'https://api.lorcana-comparator.com/v1';
  late Dio _dio;

  ApiProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Ajouter le token d'authentification si nécessaire
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Gérer la déconnexion
            getx.Get.offAllNamed('/login');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, dynamic data) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, dynamic data) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
