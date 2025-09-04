enum Tramite {
  constanciaLaboral,
  constanciaSueldo,
  constanciaAntiguedad,
  constanciaNoInhabilitacion,
}

extension TramiteX on Tramite {
  String get titulo => switch (this) {
        Tramite.constanciaLaboral => 'No adeudo ',
        Tramite.constanciaSueldo => 'Historico Laboral',
        Tramite.constanciaAntiguedad => 'Percepciones y deducciones ',
        Tramite.constanciaNoInhabilitacion => 'Finiquito',
      };
  String get descripcion => switch (this) {
        Tramite.constanciaLaboral => '¿Para qué sirve? Acredita que no registras adeudos administrativos ante tu dependencia.',
        Tramite.constanciaSueldo => '¿Qué es? Reporte de puestos, adscripciones y movimientos laborales por fecha.',
        Tramite.constanciaAntiguedad => '¿Qué obtienes? Desglose de pagos (percepciones) y descuentos (deducciones) por periodo.',
        Tramite.constanciaNoInhabilitacion => '¿Qué es? Documento de cierre de la relación laboral (cálculo y constancia).',
      };
  String get icon => switch (this) {
        Tramite.constanciaLaboral => 'work',
        Tramite.constanciaSueldo => 'payments',
        Tramite.constanciaAntiguedad => 'timer',
        Tramite.constanciaNoInhabilitacion => 'verified_user',
      };
}

enum DocumentoTipo { ine, alta, baja }

extension DocumentoTipoX on DocumentoTipo {
  String get titulo => switch (this) {
        DocumentoTipo.ine => 'INE',
        DocumentoTipo.alta => 'Formato de ALTA',
        DocumentoTipo.baja => 'Formato de BAJA',
      };
}

class DocumentoAdjunto {
  final DocumentoTipo tipo;
  final String uri; // file:// o content://
  DocumentoAdjunto({required this.tipo, required this.uri});
}

class ServidorPublico {
  final String numero;
  final String nombre;
  final String dependencia;
  ServidorPublico({required this.numero, required this.nombre, required this.dependencia});
}

class Contacto {
  String? telefono;
  String? email;
  Contacto({this.telefono, this.email});
}

class Solicitud {
  Tramite? tramite;
  ServidorPublico? servidor;
  final List<DocumentoAdjunto> documentos;
  final Contacto contacto;
  bool consentimiento;
  String? folio;

  Solicitud({
    this.tramite,
    this.servidor,
    List<DocumentoAdjunto>? documentos,
    Contacto? contacto,
    this.consentimiento = false,
    this.folio,
  })  : documentos = documentos ?? <DocumentoAdjunto>[],
        contacto = contacto ?? Contacto();
}
