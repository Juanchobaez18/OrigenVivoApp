import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../order_service.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
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

  const OrderConfirmationScreen({
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

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    final String prodLower = widget.productoSeleccionado.toLowerCase();
    final double precio = (prodLower.contains('buso') || prodLower.contains('camiseta') || prodLower.contains('oversize'))
        ? 45000.0
        : 25000.0;

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
          'Confirmación del Pedido',
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
            const Icon(
              Icons.check_circle_outline,
              size: 72,
              color: Color(0xFFA26334),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Casi Listo!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor verifica los detalles del pedido antes de confirmar.',
              style: TextStyle(fontSize: 14, color: Color(0xFFB7B7B6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Tarjeta de resumen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2D2C),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                  )
                ],
                border: Border.all(color: const Color(0xFF3E3D3C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESUMEN DEL SOUVENIR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA26334),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem('Producto:', widget.productoSeleccionado),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Diseño / Plantilla:', '${widget.disenoSeleccionado} (${widget.coleccion})'),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Imagen Personal:', widget.customImageBase64 != null ? 'Cargada por cliente' : 'Ninguna'),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Texto Adicional:', widget.textoPersonalizado.isEmpty ? 'Sin texto' : widget.textoPersonalizado),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Observaciones:', widget.observacionesCliente == null || widget.observacionesCliente!.trim().isEmpty ? 'Ninguna' : widget.observacionesCliente!.trim()),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Tipo de Pedido:', 'Sublimación Personalizada (Canvas 2D)'),
                  const Divider(height: 32, color: Color(0xFF3E3D3C)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$${precio.toStringAsFixed(0)} COP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA26334),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Información sobre el proceso
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2D2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3E3D3C)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFA26334)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu producto se preparará de inmediato. Podrás ver el estado en tiempo real en la siguiente pantalla.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB7B7B6), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Botón de confirmación final
            ElevatedButton(
              onPressed: _cargando
                  ? null
                  : () async {
                      setState(() => _cargando = true);
                      try {
                        String detallePedido = '${widget.disenoSeleccionado} (${widget.coleccion})';
                        if (widget.textoPersonalizado.isNotEmpty) {
                          detallePedido += ' - Texto: "${widget.textoPersonalizado}"';
                        }
                        if (widget.observacionesCliente != null && widget.observacionesCliente!.trim().isNotEmpty) {
                          detallePedido += ' - Obs: "${widget.observacionesCliente!.trim()}"';
                        }

                        // Subir imagen personalizada a Supabase Storage si se ha cargado una
                        if (widget.customImageBase64 != null) {
                          try {
                            final String base64String = widget.customImageBase64!.split(',').last;
                            final bytes = base64Decode(base64String);
                            final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
                            final String filePath = '${Supabase.instance.client.auth.currentUser?.id ?? "anonymous"}/$fileName';

                            // Subir archivo al bucket 'custom_designs'
                            await Supabase.instance.client.storage.from('custom_designs').uploadBinary(
                              filePath,
                              bytes,
                              fileOptions: const FileOptions(contentType: 'image/png'),
                            );

                            final String imageUrl = Supabase.instance.client.storage.from('custom_designs').getPublicUrl(filePath);
                            detallePedido += ' - Imagen de producción: $imageUrl';
                          } catch (e) {
                            // Fallback de respaldo descriptivo
                            detallePedido += ' - Imagen: [Cargada localmente por el cliente]';
                          }
                        }

                        // Agregar coordenadas detalladas de maquetado en el registro de pedidos para producción
                        detallePedido += ' | Layout: Texto(X:${widget.textX.toStringAsFixed(0)}, Y:${widget.textY.toStringAsFixed(0)}, Escala:${widget.textScale.toStringAsFixed(1)}, Rotación:${widget.textRotation.toStringAsFixed(2)})';
                        if (widget.customImageBase64 != null) {
                          detallePedido += ', Imagen(X:${widget.imageX.toStringAsFixed(0)}, Y:${widget.imageY.toStringAsFixed(0)}, Escala:${widget.imageScale.toStringAsFixed(1)}, Rotación:${widget.imageRotation.toStringAsFixed(2)})';
                        }

                        final nuevoPedido = await OrderService().registrarPedidoSublimacion(
                          producto: widget.productoSeleccionado,
                          diseno: detallePedido,
                          precio: precio,
                        );

                        if (!context.mounted) return;

                        if (nuevoPedido != null) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTrackingScreen(
                                pedido: nuevoPedido,
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al crear el pedido. Inténtalo de nuevo.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _cargando = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Confirmar y Enviar Pedido',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB7B7B6), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
