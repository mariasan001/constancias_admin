
import 'package:dio/dio.dart';
enum Environment { casa, oficina, prod }
class ApiService {
  static const Environment currentEnv = Environment.oficina;
  static String _getBaseUrl() {
    switch (currentEnv) {
      case Environment.casa:
        return 'http://192.168.100.183:4040';   
      case Environment.oficina:
        return 'http://10.0.32.7:4040';      
      case Environment.prod:
        return '';
    }
  }
  static late Dio _dio;
  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
        extra: {'withCredentials': true},
      ),
    );

  }
  static Dio get dio => _dio;
  static set dio(Dio client) => _dio = client;

}
