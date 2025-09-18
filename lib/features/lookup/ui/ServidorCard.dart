import 'package:constancias_admin/data/model_buscar_user/models.dart';
import 'package:flutter/material.dart';

class ServidorCard extends StatelessWidget {
  final UserModel usuario;
  final VoidCallback onNext;

  const ServidorCard({
    super.key,
    required this.usuario,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final rol = usuario.roles.isNotEmpty ? usuario.roles.first.description : "Sin rol";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y rol
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        rol,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info básica
            _infoRow(Icons.badge, "ID", usuario.userId),
            _infoRow(Icons.email, "Correo", usuario.email),
            _infoRow(Icons.phone, "Teléfono", usuario.phone ?? "No registrado"),
            _infoRow(Icons.credit_card, "RFC", usuario.rfc ?? "No registrado"),
            _infoRow(Icons.credit_card_outlined, "CURP", usuario.curp ?? "No registrado"),

            const SizedBox(height: 20),

            // Botón para continuar
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Continuar con documentación"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
