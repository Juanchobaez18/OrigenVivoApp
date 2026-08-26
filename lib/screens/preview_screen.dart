import 'dart:convert';
import 'package:flutter/material.dart';
import 'order_confirmation_screen.dart';

class PreviewScreen extends StatelessWidget {
  final String productoSeleccionado;
  final String disenoSeleccionado;
  final String coleccion;
  final String textoPersonalizado;
  final String? observacionesCliente;
  final Color colorTexto;
  final String fuenteTexto;
  final TextAlign alineacionTexto;

  // --- PARÁMETROS DEL CANVAS ---
  final String? customImageBase64;
  final double textX;
  final double textY;
  final double textScale;
  final double textRotation;
  final double imageX;
  final double imageY;
  final double imageScale;
  final double imageRotation;

  const PreviewScreen({
    super.key,
    required this.productoSeleccionado,
    required this.disenoSeleccionado,
    required this.coleccion,
    required this.textoPersonalizado,
    this.observacionesCliente,
    required this.colorTexto,
    required this.fuenteTexto,
    required this.alineacionTexto,
    this.customImageBase64,
    required this.textX,
    required this.textY,
    required this.textScale,
    required this.textRotation,
    required this.imageX,
    required this.imageY,
    required this.imageScale,
    required this.imageRotation,
  });

  ImageProvider? _obtenerImageProvider(String base64Str) {
    try {
      final base64String = base64Str.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData productIcon = Icons.checkroom;
    final String prodLower = productoSeleccionado.toLowerCase();
    if (prodLower.contains('mug') || prodLower.contains('taza') || prodLower.contains('vaso')) {
      productIcon = Icons.local_cafe;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1C1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA26334)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vista Previa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Playfair Display',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Así lucirá tu producto:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // SIMULADOR DE MOCKUP VISUAL PREMIUM (LIENZO ESTATICO DE COORDENADAS)
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E2D2C), Color(0xFF1E1C1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF3E3D3C), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      // Silueta base
                      Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            productIcon,
                            size: 180,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Imagen personalizada
                      if (customImageBase64 != null)
                        Positioned(
                          left: imageX,
                          top: imageY,
                          child: Transform.rotate(
                            angle: imageRotation,
                            child: Transform.scale(
                              scale: imageScale,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Image(
                                  image: _obtenerImageProvider(customImageBase64!)!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Texto personalizado
                      Positioned(
                        left: textX,
                        top: textY,
                        child: Transform.rotate(
                          angle: textRotation,
                          child: Transform.scale(
                            scale: textScale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Text(
                                textoPersonalizado.isEmpty ? 'Mi Texto' : textoPersonalizado,
                                style: TextStyle(
                                  color: colorTexto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fuenteTexto,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Text(
                          '• VISTA PREVIA DE PRODUCCIÓN •',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFB7B7B6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tarjeta de información técnica
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2D2C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3E3D3C)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Producto Base:', productoSeleccionado),
                  const Divider(height: 20, color: Color(0xFF3E3D3C)),
                  _buildDetailRow('Diseño Estampa:', disenoSeleccionado),
                  const Divider(height: 20, color: Color(0xFF3E3D3C)),
                  _buildDetailRow(
                    'Imagen Propia:',
                    customImageBase64 != null ? 'Cargada (.png / .jpg)' : 'Ninguna',
                  ),
                  const Divider(height: 20, color: Color(0xFF3E3D3C)),
                  _buildDetailRow(
                    'Texto Grabado:',
                    textoPersonalizado.isEmpty ? 'Ninguno' : '"$textoPersonalizado"',
                  ),
                  const Divider(height: 20, color: Color(0xFF3E3D3C)),
                  _buildDetailRow(
                    'Observaciones:',
                    observacionesCliente == null || observacionesCliente!.trim().isEmpty
                        ? 'Ninguna'
                        : observacionesCliente!.trim(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationScreen(
                      productoSeleccionado: productoSeleccionado,
                      disenoSeleccionado: disenoSeleccionado,
                      coleccion: coleccion,
                      textoPersonalizado: textoPersonalizado,
                      observacionesCliente: observacionesCliente,
                      colorTexto: colorTexto,
                      fuenteTexto: fuenteTexto,
                      alineacionTexto: alineacionTexto,
                      customImageBase64: customImageBase64,
                      textX: textX,
                      textY: textY,
                      textScale: textScale,
                      textRotation: textRotation,
                      imageX: imageX,
                      imageY: imageY,
                      imageScale: imageScale,
                      imageRotation: imageRotation,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceder a la Orden',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.payment),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB7B7B6)),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
