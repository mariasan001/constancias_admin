
//lib/features/admins/data/admin_model.dart

class AdminModel {
  final String nombreCompleto;
  final String curp;
  final String rfc;
  final String cargo;
  final String dependencia;
  final String correo;
  final String telefono;
  final String? direccion;
  final List<String> anexos; // rutas a PDFs/imagenes escaneadas

  AdminModel({
    required this.nombreCompleto,
    required this.curp,
    required this.rfc,
    required this.cargo,
    required this.dependencia,
    required this.correo,
    required this.telefono,
    this.direccion,
    this.anexos = const [],
  });

  Map<String, dynamic> toJson() => {
        'nombreCompleto': nombreCompleto,
        'curp': curp,
        'rfc': rfc,
        'cargo': cargo,
        'dependencia': dependencia,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
        'anexos': anexos,
      };
}
