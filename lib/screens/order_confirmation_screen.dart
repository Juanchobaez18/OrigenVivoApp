import 'package:flutter/material.dart';
import '../order_service.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String productoSeleccionado;
  final String disenoSeleccionado;
  final String coleccion;
  final String textoPersonalizado;
  final Color colorTexto;
  final String fuenteTexto;
  final TextAlign alineacionTexto;

  const OrderConfirmationScreen({
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
    // Calcular el precio
    final String prodLower = productoSeleccionado.toLowerCase();
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
                  _buildSummaryItem('Producto:', productoSeleccionado),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Diseño / Plantilla:', '$disenoSeleccionado ($coleccion)'),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Texto Adicional:', textoPersonalizado.isEmpty ? 'Sin texto' : textoPersonalizado),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Tipo de Pedido:', 'Sublimación Personalizada'),
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
              onPressed: () {
                // Registrar en memoria
                final detallePedido = '$disenoSeleccionado ($coleccion)${textoPersonalizado.isNotEmpty ? " - Texto: \"$textoPersonalizado\"" : ""}';
                
                OrderService().registrarPedidoSublimacion(
                  producto: productoSeleccionado,
                  diseno: detallePedido,
                  precio: precio,
                );

                // Obtener el ID del pedido recién creado
                final pedidos = OrderService().pedidos;
                final ultimoPedido = pedidos.last;

                // Navegar a Seguimiento de Pedido
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(
                      pedido: ultimoPedido,
                    ),
                  ),
                  (route) => route.isFirst,
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
              child: const Text(
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
