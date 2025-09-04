import 'package:flutter/material.dart';

class DocumentoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value; // uri/path si ya está cargado
  final VoidCallback onScan;
  final VoidCallback? onRemove;

  const DocumentoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onScan,
    this.onRemove,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cargado = value != null && value!.isNotEmpty;
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: cargado ? Text(value!, maxLines: 1, overflow: TextOverflow.ellipsis) : const Text('Pendiente'),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (cargado && onRemove != null)
              IconButton(
                tooltip: 'Eliminar',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            FilledButton.icon(
              onPressed: onScan,
              icon: Icon(cargado ? Icons.edit : Icons.document_scanner),
              label: Text(cargado ? 'Reemplazar' : 'Escanear'),
            ),
          ],
        ),
      ),
    );
  }
}
