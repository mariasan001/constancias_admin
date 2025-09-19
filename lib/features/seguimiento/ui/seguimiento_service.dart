// lib/features/seguimiento/services/seguimiento_service.dart
import 'package:constancias_admin/features/seguimiento/ui/tramite_full.dart';
import 'package:constancias_admin/services/api_client.dart';
import 'package:dio/dio.dart';

class SeguimientoService {
  static Future<TramiteFull?> getTramiteByFolio(String folio) async {
    try {
      final resp = await ApiService.dio.get("/api/tramites/$folio/full");
      if (resp.statusCode == 200) {
        return TramiteFull.fromJson(resp.data);
      }
      return null;
    } on DioException catch (e) {
      throw Exception("Error consultando trámite: ${e.response?.data ?? e.message}");
    }
  }
}
