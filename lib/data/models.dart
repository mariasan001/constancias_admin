import 'package:flutter/material.dart';

/// =======================
/// TRÁMITES (con ID 1–4)
/// =======================
/// Mantenemos tus nombres originales del enum para no romper imports,
/// pero el *contenido* (título/descr./icono) corresponde a:
/// 1 Finiquito
/// 2 No adeudo
/// 3 Histórico Laboral
/// 4 Percepciones y Deducciones
enum Tramite {
  constanciaLaboral,          // -> No adeudo   (ID = 2)
  constanciaSueldo,           // -> Histórico Laboral (ID = 3)
  constanciaAntiguedad,       // -> Percepciones y Deducciones (ID = 4)
  constanciaNoInhabilitacion, // -> Finiquito  (ID = 1)
}

extension TramiteX on Tramite {
  int get id => switch (this) {
        Tramite.constanciaNoInhabilitacion => 1, // Finiquito
        Tramite.constanciaLaboral          => 2, // No adeudo
        Tramite.constanciaSueldo           => 3, // Histórico Laboral
        Tramite.constanciaAntiguedad       => 4, // Percepciones y Deducciones
      };

  String get titulo => switch (this) {
        Tramite.constanciaNoInhabilitacion => 'Finiquito',
        Tramite.constanciaLaboral          => 'No adeudo',
        Tramite.constanciaSueldo           => 'Histórico Laboral',
        Tramite.constanciaAntiguedad       => 'Percepciones y deducciones',
      };

  String get descripcion => switch (this) {
        Tramite.constanciaNoInhabilitacion =>
          '¿Qué es? Documento de cierre de la relación laboral (cálculo y constancia).',
        Tramite.constanciaLaboral =>
          '¿Para qué sirve? Acredita que no registras adeudos administrativos ante tu dependencia.',
        Tramite.constanciaSueldo =>
          '¿Qué es? Reporte de puestos, adscripciones y movimientos laborales por fecha.',
        Tramite.constanciaAntiguedad =>
          '¿Qué obtienes? Desglose de pagos (percepciones) y descuentos (deducciones) por periodo.',
      };

  IconData get icon => switch (this) {
        Tramite.constanciaNoInhabilitacion => Icons.assignment_turned_in_outlined,
        Tramite.constanciaLaboral          => Icons.verified_user_outlined,
        Tramite.constanciaSueldo           => Icons.history_edu_outlined,
        Tramite.constanciaAntiguedad       => Icons.receipt_long_outlined,
      };
}

extension TramiteParse on Tramite {
  static Tramite? fromId(int id) {
    return switch (id) {
      1 => Tramite.constanciaNoInhabilitacion,
      2 => Tramite.constanciaLaboral,
      3 => Tramite.constanciaSueldo,
      4 => Tramite.constanciaAntiguedad,
      _ => null,
    };
  }
}

/// =======================
/// DOCUMENTOS / ADJUNTOS
/// =======================
enum DocumentoTipo { ine, alta, baja }

extension DocumentoTipoX on DocumentoTipo {
  String get titulo => switch (this) {
        DocumentoTipo.ine  => 'INE',
        DocumentoTipo.alta => 'Formato de ALTA',
        DocumentoTipo.baja => 'Formato de BAJA',
      };
}

class DocumentoAdjunto {
  final DocumentoTipo tipo;
  final String uri; // file://, content:// o path local
  DocumentoAdjunto({required this.tipo, required this.uri});
}

/// =======================
/// ENTIDADES DEL FLUJO
/// =======================
class ServidorPublico {
  final String numero;
  final String nombre;
  final String dependencia;
  ServidorPublico({
    required this.numero,
    required this.nombre,
    required this.dependencia,
  });
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

  int? get tramiteTypeId => tramite?.id;

  Map<String, dynamic> toPayload() => {
        if (tramiteTypeId != null) 'tramiteTypeId': tramiteTypeId,
        if (servidor != null) 'numeroServidorPublico': servidor!.numero,
        'contacto': {
          if (contacto.telefono != null) 'telefono': contacto.telefono,
          if (contacto.email != null) 'email': contacto.email,
        },
        'consentimiento': consentimiento,
      };
}
