import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class CheckInQrScreen extends StatefulWidget {
  static const String name = 'checkin_qr_screen';
  const CheckInQrScreen({super.key});

  @override
  State<CheckInQrScreen> createState() => _CheckInQrScreenState();
}

class _CheckInQrScreenState extends State<CheckInQrScreen> {
  static const _qrData = 'bloodhero-checkin-code';
  final GlobalKey _qrKey = GlobalKey();
  bool _isProcessing = false;

  Future<Uint8List> _captureQrBytes() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('No se pudo generar el código QR.');
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('No se pudo obtener la imagen del código QR.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<File> _persistQr(Uint8List bytes, Directory directory) async {
    final file = File(
      '${directory.path}/bloodhero-checkin-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<File> _storeQrTemporarily(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    return _persistQr(bytes, dir);
  }

  Future<void> _downloadQr() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureQrBytes();
      final dir = await getApplicationDocumentsDirectory();
      final file = await _persistQr(bytes, dir);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código guardado en: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos guardar el código: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _shareQr() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureQrBytes();
      final tempFile = await _storeQrTemporarily(bytes);
      await SharePlus.instance.share(
        ShareParams(
          text: 'Mi código de check-in para BloodHero',
          files: [XFile(tempFile.path)],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos compartir el código: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in QR')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Mostrá este código QR al llegar al centro para agilizar tu registro.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 220,
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _downloadQr,
              icon: const Icon(Icons.download),
              label: const Text('Descargar código'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isProcessing ? null : _shareQr,
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
