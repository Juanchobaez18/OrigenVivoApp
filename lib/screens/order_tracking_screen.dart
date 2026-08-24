import 'package:flutter/material.dart';
import '../order_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderItem pedido;

  const OrderTrackingScreen({
    super.key,
    required this.pedido,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _orderService.addListener(_refrescarUI);
  }

  @override
  void dispose() {
    _orderService.removeListener(_refrescarUI);
    super.dispose();
  }

  void _refrescarUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buscar el pedido actualizado de la lista
    final actual = _orderService.pedidos.firstWhere(
      (p) => p.id == widget.pedido.id,
      orElse: () => widget.pedido,
    );

    // Mapeo de estados a índices
    int currentStep = 0;
    if (actual.estado == 'Confirmado') {
      currentStep = 1;
    } else if (actual.estado == 'En producción') {
      currentStep = 2;
    } else if (actual.estado == 'Control de calidad') {
      currentStep = 3;
    } else if (actual.estado == 'Listo para entrega') {
      currentStep = 4;
    } else if (actual.estado == 'Entregado') {
      currentStep = 5;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1C1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFA26334)),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: const Text(
          'Seguimiento del Pedido',
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
            // Encabezado con ID del pedido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2D2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3E3D3C)),
              ),
              child: Column(
                children: [
                  Text(
                    'PEDIDO: ${actual.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA26334),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Registrado el ${actual.fecha.day}/${actual.fecha.month}/${actual.fecha.year} a las ${actual.fecha.hour.toString().padLeft(2, '0')}:${actual.fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB7B7B6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // LÍNEA DE TIEMPO DE PASOS (Seguimiento del pedido)
            const Text(
              'Estado del Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildTimelineStep(
              0,
              'Pedido Recibido',
              'Hemos recibido tu pedido de sublimación y está en cola.',
              currentStep >= 0,
              isFirst: true,
            ),
            _buildTimelineStep(
              1,
              'Confirmado',
              'Pago validado en caja y aprobado para producción.',
              currentStep >= 1,
            ),
            _buildTimelineStep(
              2,
              'En Producción',
              'El taller de sublimación está estampando tu producto.',
              currentStep >= 2,
            ),
            _buildTimelineStep(
              3,
              'Control de Calidad',
              'Revisando acabados y detalles finales del estampado.',
              currentStep >= 3,
            ),
            _buildTimelineStep(
              4,
              'Listo para Entrega',
              '¡Tu souvenir personalizado está listo! Pasa a recogerlo al counter.',
              currentStep >= 4,
            ),
            _buildTimelineStep(
              5,
              'Entregado',
              'El producto fue entregado con éxito. ¡Gracias por tu compra!',
              currentStep >= 5,
              isLast: true,
            ),
            const SizedBox(height: 32),

            // Detalles del producto en seguimiento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2D2C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3E3D3C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles del Producto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(actual.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('1 unidad', style: TextStyle(color: Color(0xFFB7B7B6))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    actual.detalle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB7B7B6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Botón de Volver al Inicio
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Volver a Inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    int stepIndex,
    String title,
    String description,
    bool isCompleted, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final activeColor = const Color(0xFFA26334);
    final inactiveColor = const Color(0xFF3E3D3C);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna de la línea y el círculo
        Column(
          children: [
            // Línea superior
            if (!isFirst)
              Container(
                width: 3,
                height: 20,
                color: isCompleted ? activeColor : inactiveColor,
              ),
            // Círculo del paso
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? activeColor : const Color(0xFF2E2D2C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? activeColor : inactiveColor,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            // Línea inferior
            if (!isLast)
              Container(
                width: 3,
                height: 40,
                color: isCompleted ? activeColor : inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Columna del texto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.white : const Color(0xFFB7B7B6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? const Color(0xFFB7B7B6) : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
