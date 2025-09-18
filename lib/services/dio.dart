import 'package:constancias_admin/data/model_buscar_user/models.dart';
import 'package:constancias_admin/services/api_client.dart';
import 'package:dio/dio.dart';

class UserService {
  /// Obtener usuario por ID
  static Future<UserModel> getUserById(String userId) async {
    try {
      final response = await ApiService.dio.get('/api/users/$userId');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception("DioException: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }
}
