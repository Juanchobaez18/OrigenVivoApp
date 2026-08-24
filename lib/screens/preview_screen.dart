import 'package:flutter/material.dart';
import 'order_confirmation_screen.dart';

class PreviewScreen extends StatelessWidget {
  final String productoSeleccionado;
  final String disenoSeleccionado;
  final String coleccion;
  final String textoPersonalizado;
  final Color colorTexto;
  final String fuenteTexto;
  final TextAlign alineacionTexto;

  const PreviewScreen({
    super.key,
    required this.productoSeleccionado,
    required this.disenoSeleccionado,
    required this.coleccion,
    required this.textoPersonalizado,
    required this.colorTexto,
    required this.fuenteTexto,
    required this.alineacionTexto,
  });

  @override
  Widget build(BuildContext context) {
    IconData productIcon = Icons.checkroom;
    if (productoSeleccionado.toLowerCase().contains('mug') || productoSeleccionado.toLowerCase().contains('vaso') || productoSeleccionado.toLowerCase().contains('termico')) {
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

            // SIMULADOR DE MOCKUP VISUAL PREMIUM
            Container(
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 20,
                    bottom: 20,
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(
                        productIcon,
                        size: 200,
                        color: const Color(0xFFA26334),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E3D3C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFA26334).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image_outlined,
                                color: Color(0xFFA26334),
                                size: 36,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                disenoSeleccionado.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'COLECCIÓN: $coleccion',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFB7B7B6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (textoPersonalizado.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1C1A).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              textoPersonalizado,
                              textAlign: alineacionTexto,
                              style: TextStyle(
                                color: colorTexto,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: colorTexto.withValues(alpha: 0.4),
                              ),
                            ),
                          )
                        else
                          Text(
                            '[Sin Texto Adicional]',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: 12,
                    child: Text(
                      '• MOCKUP DE PREVISUALIZACIÓN •',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFFB7B7B6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
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
                  _buildDetailRow('Diseño de Estampa:', disenoSeleccionado),
                  const Divider(height: 20, color: Color(0xFF3E3D3C)),
                  _buildDetailRow(
                    'Texto Grabado:',
                    textoPersonalizado.isEmpty ? 'Ninguno' : '"$textoPersonalizado"',
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
                      colorTexto: colorTexto,
                      fuenteTexto: fuenteTexto,
                      alineacionTexto: alineacionTexto,
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
