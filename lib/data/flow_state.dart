import 'package:flutter/foundation.dart';
import 'models.dart';

class FlowState extends ChangeNotifier {
  final Solicitud _s = Solicitud();

  // Lecturas
  Solicitud get solicitud => _s;

  // Mutadores
  void setTramite(Tramite t) {
    _s.tramite = t;
    notifyListeners();
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

  void addDocumento(DocumentoAdjunto d) {
    _s.documentos.removeWhere((x) => x.tipo == d.tipo);
    _s.documentos.add(d);
    notifyListeners();
  }

  void removeDocumento(DocumentoTipo tipo) {
    _s.documentos.removeWhere((x) => x.tipo == tipo);
    notifyListeners();
  }

  DocumentoAdjunto? getDoc(DocumentoTipo tipo) =>
      _s.documentos.where((d) => d.tipo == tipo).cast<DocumentoAdjunto?>().firstWhere((_) => true, orElse: () => null);

  // Reglas: INE obligatorio + (ALTA o BAJA) => mínimo 2
  bool get documentosValidos {
    final tieneINE = _s.documentos.any((d) => d.tipo == DocumentoTipo.ine);
    final altaOBaja = _s.documentos.any((d) => d.tipo == DocumentoTipo.alta) ||
        _s.documentos.any((d) => d.tipo == DocumentoTipo.baja);
    return tieneINE && altaOBaja;
  }

  bool get contactoValido {
    final telVal = (_s.contacto.telefono ?? '').replaceAll(RegExp(r'\D'), '').length >= 10;
    final mail = _s.contacto.email ?? '';
    final mailVal = mail.isEmpty ? false : mail.contains('@');
    return telVal || mailVal;
  }

  void reset() {
    _s.tramite = null;
    _s.servidor = null;
    _s.documentos.clear();
    _s.contacto.telefono = null;
    _s.contacto.email = null;
    _s.consentimiento = false;
    _s.folio = null;
    notifyListeners();
  }
}
