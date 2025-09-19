// lib/features/buscar_servidor/services/user_service.dart
import 'package:constancias_admin/data/model_buscar_user/models.dart';
import 'package:constancias_admin/services/api_client.dart';


class UserService {
  static Future<UserModel?> getUserById(String userId) async {
    final resp = await ApiService.dio.get('/api/users/$userId');
    return UserModel.fromJson(resp.data);
  }

  static Future<UserModel?> updateUser(String userId, Map<String, dynamic> data) async {
    final resp = await ApiService.dio.put('/api/users/$userId', data: data);
    return UserModel.fromJson(resp.data);
  }
}
