import '../data/models.dart';
import 'dart:math';

class ApiClient {
  Future<ServidorPublico?> buscarServidorPorNumero(String numero) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (numero.trim().isEmpty || numero.trim().length < 4) return null;
    // demo: regresamos uno falso
    return ServidorPublico(
      numero: numero.trim(),
      nombre: 'María Guadalupe Sandoval',
      dependencia: 'Dirección General de Personal',
    );
  }

  Future<String> enviarSolicitud(Solicitud s) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // demo: folio aleatorio
    final n = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'CON-${DateTime.now().year}-$n';
  }
}
