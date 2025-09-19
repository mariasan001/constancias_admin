import 'dart:convert';
import 'package:constancias_admin/services/api_client.dart';
import 'package:dio/dio.dart';
import '../data/flow_state.dart';
import '../data/models.dart';
import 'dio.dart';

class TramiteService {
  /// Crea un trámite y sube documentos en una sola llamada
  static Future<Response> createWithDocs(Solicitud solicitud) async {
    // Payload mínimo que pide la API
    final payload = {
      "tramiteTypeId": solicitud.tramite?.id,
      "userId": solicitud.servidor?.numero, // o usuario.userId según tu flujo
    };

    // Archivos adjuntos
    final files = <MultipartFile>[];
    final docTypeIds = <int>[];

    for (final doc in solicitud.documentos) {
      files.add(
        await MultipartFile.fromFile(
          doc.uri,
          filename: doc.uri.split('/').last,
        ),
      );

      // 🔹 Mapear DocumentoTipo -> ID entero que espera la API
      final typeId = switch (doc.tipo) {
        DocumentoTipo.ine => 1,
        DocumentoTipo.alta => 2,
        DocumentoTipo.baja => 3,
      };
      docTypeIds.add(typeId);
    }

    // Construcción del multipart/form-data
    final formData = FormData.fromMap({
      "payload": MultipartFile.fromString(
        jsonEncode(payload),
       
      ),
      "files": files,
      "docTypeIds": docTypeIds,
    });

    // Llamada HTTP
    final response = await ApiService.dio.post(
      "/api/tramites/create-with-docs",
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );

    return response;
  }
}
