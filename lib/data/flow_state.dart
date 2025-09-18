import 'package:flutter/foundation.dart';
import 'models.dart'; // Solicitud, DocumentoAdjunto, Tramite...
import 'model_buscar_user/models.dart' hide Solicitud; // UserModel y Role

class FlowState extends ChangeNotifier {
  final Solicitud _s = Solicitud();

  // === Usuario logueado o buscado (UserModel de la API) ===
  UserModel? _usuario;
  UserModel? get usuario => _usuario;

  void setUsuario(UserModel u) {
    _usuario = u;
    notifyListeners();
  }

  // ==== Lecturas ====
  Solicitud get solicitud => _s;

  Tramite? get tramite => _s.tramite;
  int? get tramiteTypeId => _s.tramite?.id;

  // ==== Mutadores ====
  void setTramite(Tramite t) {
    _s.tramite = t;
    notifyListeners();
  }

  bool setTramiteById(int id) {
    final t = TramiteParse.fromId(id);
    if (t == null) return false;
    _s.tramite = t;
    notifyListeners();
    return true;
  }

  // 👇 Solo mantenlo si aún usas ServidorPublico para compatibilidad
  void setServidor(ServidorPublico sp) {
    _s.servidor = sp;
    notifyListeners();
  }

  void setContacto({String? tel, String? email}) {
    _s.contacto.telefono = tel;
    _s.contacto.email = email;
    notifyListeners();
  }

  void setConsentimiento(bool v) {
    _s.consentimiento = v;
    notifyListeners();
  }

  void setFolio(String folio) {
    _s.folio = folio;
    notifyListeners();
  }

  void addDocumento(DocumentoAdjunto d) {
    _s.documentos.removeWhere((x) => x.tipo == d.tipo);
    _s.documentos.add(d);
    notifyListeners();
  }

  void removeDocumento(DocumentoTipo tipo) {
    _s.documentos.removeWhere((x) => x.tipo == tipo);
    notifyListeners();
  }

  DocumentoAdjunto? getDoc(DocumentoTipo tipo) {
    for (final d in _s.documentos) {
      if (d.tipo == tipo) return d;
    }
    return null;
  }

  // ==== Validaciones ====
  bool get documentosValidos {
    final tieneINE = _s.documentos.any((d) => d.tipo == DocumentoTipo.ine);
    final altaOBaja = _s.documentos.any((d) => d.tipo == DocumentoTipo.alta) ||
        _s.documentos.any((d) => d.tipo == DocumentoTipo.baja);
    return tieneINE && altaOBaja;
  }

  bool get contactoValido {
    final tel = (_s.contacto.telefono ?? '').replaceAll(RegExp(r'\D'), '');
    final hasTel = tel.length >= 10;
    final mail = (_s.contacto.email ?? '').trim();
    final hasMail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail);
    return hasTel || hasMail;
  }

  bool get consentimientoValido => _s.consentimiento == true;

  bool get listoParaEnviar {
    return tramiteTypeId != null &&
        _usuario != null && // 👈 aquí en vez de _s.servidor
        documentosValidos &&
        contactoValido &&
        consentimientoValido;
  }

  Map<String, dynamic> buildPayload() {
    return {
      ..._s.toPayload(),
      if (_usuario != null) 'userId': _usuario!.userId,
    };
  }

  void reset({bool keepTramite = false}) {
    final t = keepTramite ? _s.tramite : null;
    _s.tramite = t;
    _s.servidor = null;
    _s.documentos.clear();
    _s.contacto.telefono = null;
    _s.contacto.email = null;
    _s.consentimiento = false;
    _s.folio = null;
    _usuario = null;
    notifyListeners();
  }
}
