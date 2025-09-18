import 'package:flutter/foundation.dart';
import 'models.dart';

class FlowState extends ChangeNotifier {
  final Solicitud _s = Solicitud();

  // ==== Lecturas ====
  Solicitud get solicitud => _s;

  Tramite? get tramite => _s.tramite;
  int? get tramiteTypeId => _s.tramite?.id;

  // ==== Mutadores ====
  void setTramite(Tramite t) {
    _s.tramite = t;
    notifyListeners();
  }

  /// Útil si recibes el ID (1..4) desde BD/deeplink.
  /// Devuelve true si encontró y seteo el trámite.
  bool setTramiteById(int id) {
    final t = TramiteParse.fromId(id);
    if (t == null) return false;
    _s.tramite = t;
    notifyListeners();
    return true;
  }

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

  // Regla actual: INE obligatorio + (ALTA o BAJA)
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
    // Aceptamos que el usuario dé teléfono O correo (al menos uno).
    return hasTel || hasMail;
  }

  bool get consentimientoValido => _s.consentimiento == true;

  /// ¿Tenemos lo mínimo para poder enviar el payload principal?
  bool get listoParaEnviar {
    return tramiteTypeId != null &&
        _s.servidor != null &&
        documentosValidos &&
        contactoValido &&
        consentimientoValido;
  }

  // ==== Payload para API ====

  /// Construye el payload base para POST /solicitudes (sin documentos).
  Map<String, dynamic> buildPayload() {
    return _s.toPayload();
  }

  // ==== Reset ====

  /// Resetea el estado. Si [keepTramite] es true, conserva el tipo de trámite.
  void reset({bool keepTramite = false}) {
    final t = keepTramite ? _s.tramite : null;
    _s.tramite = t;
    _s.servidor = null;
    _s.documentos.clear();
    _s.contacto.telefono = null;
    _s.contacto.email = null;
    _s.consentimiento = false;
    _s.folio = null;
    notifyListeners();
  }
}
