import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';

class ScanPage extends StatefulWidget {
  final bool returnPath; // si true, devolvemos el archivo/uri al caller
  const ScanPage({super.key, this.returnPath = false});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? _savedPath; // puede ser ruta local o content://
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  Future<void> _startScan() async {
    setState(() { _busy = true; _error = null; _savedPath = null; });

    try {
      final options = DocumentScannerOptions(
        documentFormat: DocumentFormat.pdf,
        mode: ScannerMode.filter,
        isGalleryImport: true,
        pageLimit: 20,
      );

      final scanner = DocumentScanner(options: options);
      final result = await scanner.scanDocument();
      await scanner.close();

      // Preferimos PDF
      if (result.pdf != null) {
        final uri = result.pdf!.uri; // String (content:// o file://)
        final persisted = await _persistIfFilePath(uri);
        final finalPath = persisted ?? uri;

        setState(() { _savedPath = finalPath; _busy = false; });
        if (widget.returnPath && mounted) Navigator.of(context).pop(finalPath);
        return;
      }

      // Fallback: primera imagen (en esta versión es List<String>)
      if (result.images.isNotEmpty) {
        final imgUri = result.images.first;
        final persisted = await _persistIfFilePath(imgUri);
        final finalPath = persisted ?? imgUri;

        setState(() { _savedPath = finalPath; _busy = false; });
        if (widget.returnPath && mounted) Navigator.of(context).pop(finalPath);
        return;
      }

      setState(() { _error = 'No se obtuvo ningún documento.'; _busy = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _busy = false; });
    }
  }

  /// Copia al directorio de la app si es ruta local (file:// o sin esquema).
  /// Si es content:// no podemos usar File directamente → devolvemos null.
  Future<String?> _persistIfFilePath(String uriOrPath) async {
    final u = Uri.tryParse(uriOrPath);
    final scheme = u?.scheme ?? '';
    final isFileLike = scheme.isEmpty || scheme == 'file';
    if (!isFileLike) return null;

    final srcPath = scheme == 'file' ? u!.toFilePath() : uriOrPath;
    final src = File(srcPath);
    if (!await src.exists()) return null;

    final dir = await getApplicationDocumentsDirectory();
    final ext = srcPath.toLowerCase().endsWith('.pdf') ? '.pdf' : '.jpg';
    final dst = File('${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}$ext');
    await src.copy(dst.path);
    return dst.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear documento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _busy
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                  if (_savedPath != null) ...[
                    const Text('Documento listo:'),
                    const SizedBox(height: 8),
                    SelectableText(_savedPath!),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(_savedPath),
                      icon: const Icon(Icons.check),
                      label: const Text('Usar este archivo'),
                    ),
                  ],
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar escaneo'),
                  ),
                ],
              ),
      ),
    );
  }
}
