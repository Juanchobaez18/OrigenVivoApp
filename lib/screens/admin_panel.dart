import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../order_service.dart';
import 'product_management_screen.dart';

enum AdminView { orders, stats }

class AdminPanelScreen extends StatefulWidget {
  final String email;
  final String role;

  const AdminPanelScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final OrderService _orderService = OrderService();
  String _filtroEstado = 'Todos';
  AdminView _currentView = AdminView.orders;

  @override
  void initState() {
    super.initState();
    _orderService.addListener(_refrescarUI);
    _orderService.cargarPedidosDesdeDB();
  }

  @override
  void dispose() {
    _orderService.removeListener(_refrescarUI);
    super.dispose();
  }

  void _refrescarUI() {
    if (mounted) setState(() {});
  }

  // --- GRÁFICOS ESTADÍSTICOS CON FL_CHART ---

  Widget _buildLineChart(List<OrderItem> pedidos) {
    // Ventas de los últimos 7 días
    final hoy = DateTime.now();
    final List<double> ventasSemana = List.filled(7, 0.0);
    final List<String> nombresDias = [];

    for (int i = 6; i >= 0; i--) {
      final dia = hoy.subtract(Duration(days: i));
      nombresDias.add('${dia.day}/${dia.month}');
      
      final double totalDia = pedidos
          .where((p) => (p.estado == 'Entregado' || p.estado == 'Completado') &&
                        p.fecha.year == dia.year &&
                        p.fecha.month == dia.month &&
                        p.fecha.day == dia.day)
          .fold(0.0, (sum, p) => sum + (p.precio * p.cantidad));
      ventasSemana[6 - i] = totalDia;
    }

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recaudación Semanal (Últimos 7 Días)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D2818)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < nombresDias.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(nombresDias[idx], style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(7, (i) => FlSpot(i.toDouble(), ventasSemana[i])),
                      isCurved: true,
                      color: const Color(0xFFB8863B),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFB8863B).withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<OrderItem> pedidos) {
    // Horas de mayor consumo: 8, 10, 12, 14, 16, 18
    final List<int> horas = [8, 10, 12, 14, 16, 18];
    final List<double> recuentoPorHora = List.filled(6, 0.0);

    for (final p in pedidos) {
      if (p.tipo != 'Sublimación') {
        final hora = p.fecha.hour;
        if (hora >= 7 && hora < 9) {
          recuentoPorHora[0] += p.cantidad;
        } else if (hora >= 9 && hora < 11) {
          recuentoPorHora[1] += p.cantidad;
        } else if (hora >= 11 && hora < 13) {
          recuentoPorHora[2] += p.cantidad;
        } else if (hora >= 13 && hora < 15) {
          recuentoPorHora[3] += p.cantidad;
        } else if (hora >= 15 && hora < 17) {
          recuentoPorHora[4] += p.cantidad;
        } else if (hora >= 17 && hora <= 19) {
          recuentoPorHora[5] += p.cantidad;
        }
      }
    }

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cafetería: Unidades por Horario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D2818)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < horas.length) {
                            return Text('${horas[idx]}h', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(6, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: recuentoPorHora[i],
                          color: const Color(0xFF0D2818),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<OrderItem> pedidos) {
    int totalCafe = 0;
    int totalSublimados = 0;

    for (final p in pedidos) {
      if (p.tipo == 'Sublimación') {
        totalSublimados += p.cantidad;
      } else {
        totalCafe += p.cantidad;
      }
    }

    final double total = (totalCafe + totalSublimados).toDouble();
    final double pctCafe = total > 0 ? (totalCafe / total * 100) : 50.0;
    final double pctSub = total > 0 ? (totalSublimados / total * 100) : 50.0;

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución de Items Vendidos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D2818)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: pctCafe,
                            title: '${pctCafe.toStringAsFixed(0)}%',
                            color: const Color(0xFF8B5E34),
                            radius: 35,
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                          ),
                          PieChartSectionData(
                            value: pctSub,
                            title: '${pctSub.toStringAsFixed(0)}%',
                            color: const Color(0xFF0D2818),
                            radius: 35,
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Cafetería', const Color(0xFF8B5E34)),
                    const SizedBox(height: 8),
                    _buildLegendItem('Sublimación', const Color(0xFF0D2818)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosLosPedidos = _orderService.pedidos;

    final pedidos = widget.role == 'produccion'
        ? todosLosPedidos.where((p) => p.tipo == 'Sublimación').toList()
        : todosLosPedidos;

    // Calcular estadísticas principales
    final double totalVentas = pedidos
        .where((p) => p.estado == 'Entregado' || p.estado == 'Completado')
        .fold(0, (sum, p) => sum + (p.precio * p.cantidad));
    final int pendientes = pedidos.where((p) => p.estado == 'Pendiente').length;
    final int enProduccion = pedidos.where((p) => p.estado == 'En producción').length;
    final int listoParaEntrega = pedidos.where((p) => p.estado == 'Listo para entrega').length;

    final pedidosFiltrados = _filtroEstado == 'Todos'
        ? pedidos
        : pedidos.where((p) => p.estado == _filtroEstado).toList();

    String titleText = 'Panel de Control';
    String subtitleText = 'Origen Vivo';
    if (widget.role == 'produccion') {
      titleText = 'Panel de Producción';
      subtitleText = 'Operario / Taller de Sublimación';
    } else if (widget.role == 'caja') {
      titleText = 'Caja y Validación';
      subtitleText = 'Cajero / Punto de Venta';
    } else if (widget.role == 'admin') {
      titleText = 'Panel Administrativo';
      subtitleText = 'Administrador Global';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2818),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Playfair Display', color: Colors.white),
            ),
            Text(
              subtitleText,
              style: const TextStyle(fontSize: 11, color: Color(0xFFF5EDE3)),
            ),
          ],
        ),
        actions: [
          if (widget.role == 'admin')
            IconButton(
              icon: const Icon(Icons.inventory_2_outlined, color: Color(0xFFB8863B)),
              tooltip: 'Gestionar Catálogo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductManagementScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFB8863B)),
            onPressed: () {
              _orderService.cargarPedidosDesdeDB();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFB8863B)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección de métricas/resumen con fondo verde
          Container(
            color: const Color(0xFF0D2818),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: Column(
              children: [
                if (widget.role == 'produccion')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Cola de Trabajo', '$pendientes', const Color(0xFFB8863B).withValues(alpha: 0.2)),
                      _buildStatCard('En Taller', '$enProduccion', Colors.blue.withValues(alpha: 0.2)),
                    ],
                  )
                else if (widget.role == 'caja')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Ventas Realizadas', '\$${totalVentas.toStringAsFixed(0)}', Colors.white.withValues(alpha: 0.08)),
                      _buildStatCard('Por Entregar', '$listoParaEntrega', Colors.green.withValues(alpha: 0.2)),
                    ],
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Ventas Realizadas', '\$${totalVentas.toStringAsFixed(0)}', Colors.white.withValues(alpha: 0.08)),
                      _buildStatCard('Pendientes', '$pendientes', const Color(0xFFB8863B).withValues(alpha: 0.2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('En Taller', '$enProduccion', Colors.blue.withValues(alpha: 0.2)),
                      _buildStatCard('Listos', '$listoParaEntrega', Colors.green.withValues(alpha: 0.2)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Selector de Vista (Pedidos vs Estadísticas)
          if (widget.role == 'admin')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Lista de Pedidos')),
                      selected: _currentView == AdminView.orders,
                      onSelected: (val) => setState(() => _currentView = AdminView.orders),
                      selectedColor: const Color(0xFF0D2818),
                      labelStyle: TextStyle(
                        color: _currentView == AdminView.orders ? Colors.white : const Color(0xFF0D2818),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Estadísticas')),
                      selected: _currentView == AdminView.stats,
                      onSelected: (val) => setState(() => _currentView = AdminView.stats),
                      selectedColor: const Color(0xFF0D2818),
                      labelStyle: TextStyle(
                        color: _currentView == AdminView.stats ? Colors.white : const Color(0xFF0D2818),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Contenido principal dinámico
          Expanded(
            child: _currentView == AdminView.stats && widget.role == 'admin'
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildLineChart(pedidos),
                      const SizedBox(height: 16),
                      _buildBarChart(pedidos),
                      const SizedBox(height: 16),
                      _buildPieChart(pedidos),
                      const SizedBox(height: 24),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filtros de estado de pedido
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Todos', 'Pendiente', 'Confirmado', 'En producción', 'Listo para entrega', 'Entregado', 'Cancelado'].map((estado) {
                              final esSeleccionado = _filtroEstado == estado;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    estado,
                                    style: TextStyle(
                                      color: esSeleccionado ? Colors.white : const Color(0xFF0D2818),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: esSeleccionado,
                                  selectedColor: const Color(0xFF0D2818),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(color: Color(0xFFE2D6C5)),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _filtroEstado = estado);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Listado de tarjetas de pedido
                      Expanded(
                        child: pedidosFiltrados.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text(
                                      'No hay pedidos en esta categoría',
                                      style: TextStyle(color: Color(0xFF0D2818), fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: pedidosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final pedido = pedidosFiltrados[index];
                                  final esSublimacion = pedido.tipo == 'Sublimación';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 2,
                                    color: Colors.white,
                                    shadowColor: Colors.black.withValues(alpha: 0.04),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF5EDE3),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: const Color(0xFFE2D6C5)),
                                                ),
                                                child: Text(
                                                  pedido.id,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0D2818),
                                                  ),
                                                ),
                                              ),
                                              _buildBadgeEstado(pedido.estado),
                                            ],
                                          ),
                                          const Divider(height: 20, color: Color(0xFFE2D6C5)),
                                          
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFF5EDE3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  esSublimacion ? Icons.palette : Icons.local_cafe,
                                                  color: const Color(0xFF0D2818),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pedido.nombre,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF0D2818),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      pedido.detalle,
                                                      style: const TextStyle(fontSize: 13, color: Color(0xFF4A5D4C)),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Cantidad: ${pedido.cantidad}  |  Precio Unitario: \$${pedido.precio.toStringAsFixed(0)}',
                                                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A5D4C)),
                                                    ),
                                                    if (pedido.clienteNombre != null || pedido.clienteEmail != null) ...[
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.person_outline, size: 12, color: Color(0xFFB8863B)),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              'Cliente: ${pedido.clienteNombre ?? ''} (${pedido.clienteEmail ?? 'Sin correo'})',
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFFB8863B),
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),

                                          // Acciones de administración basadas en Rol
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (esSublimacion && (widget.role == 'produccion' || widget.role == 'admin'))
                                                TextButton.icon(
                                                  onPressed: () => _simularDescargarDiseno(context, pedido),
                                                  icon: const Icon(Icons.download, size: 16, color: Color(0xFFB8863B)),
                                                  label: const Text('Descargar Diseño', style: TextStyle(color: Color(0xFFB8863B), fontSize: 12, fontWeight: FontWeight.bold)),
                                                )
                                              else
                                                const SizedBox(),

                                              Row(
                                                children: [
                                                  if (widget.role == 'caja' || widget.role == 'admin') ...[
                                                    if (pedido.estado == 'Pendiente')
                                                      ElevatedButton.icon(
                                                        onPressed: () => _orderService.actualizarEstadoPedido(pedido.id, 'Confirmado'),
                                                        icon: const Icon(Icons.check, size: 16),
                                                        label: const Text('Confirmar Pedido', style: TextStyle(fontSize: 12)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF0D2818),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        ),
                                                      ),
                                                    if (pedido.estado == 'Confirmado')
                                                      ElevatedButton.icon(
                                                        onPressed: () => _orderService.actualizarEstadoPedido(pedido.id, 'En producción'),
                                                        icon: const Icon(Icons.payment, size: 16),
                                                        label: const Text('Validar Pago', style: TextStyle(fontSize: 12)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFFB8863B),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        ),
                                                      ),
                                                    if (pedido.estado == 'Listo para entrega')
                                                      ElevatedButton.icon(
                                                        onPressed: () => _orderService.actualizarEstadoPedido(pedido.id, 'Entregado'),
                                                        icon: const Icon(Icons.delivery_dining, size: 16),
                                                        label: const Text('Entregar Producto', style: TextStyle(fontSize: 12)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green.shade700,
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        ),
                                                      ),
                                                  ],

                                                  if (widget.role == 'produccion' || widget.role == 'admin') ...[
                                                    if (pedido.estado == 'Confirmado' || (pedido.estado == 'Pendiente' && widget.role == 'produccion'))
                                                      ElevatedButton.icon(
                                                        onPressed: () => _orderService.actualizarEstadoPedido(pedido.id, 'En producción'),
                                                        icon: const Icon(Icons.play_arrow, size: 16),
                                                        label: const Text('Iniciar Producción', style: TextStyle(fontSize: 12)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.blue.shade700,
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        ),
                                                      ),
                                                    if (pedido.estado == 'En producción')
                                                      ElevatedButton.icon(
                                                        onPressed: () => _orderService.actualizarEstadoPedido(pedido.id, 'Listo para entrega'),
                                                        icon: const Icon(Icons.thumb_up, size: 16),
                                                        label: const Text('Listo para Entrega', style: TextStyle(fontSize: 12)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green.shade700,
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                        ),
                                                      ),
                                                  ],

                                                  if ((widget.role == 'admin' || widget.role == 'caja') && pedido.estado != 'Entregado' && pedido.estado != 'Cancelado') ...[
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      onPressed: () => _confirmarEliminacion(context, pedido.id),
                                                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                                      tooltip: 'Cancelar Pedido',
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2D6C5).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFFF5EDE3), fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeEstado(String estado) {
    Color bg;
    Color fg;

    switch (estado) {
      case 'Pendiente':
        bg = const Color(0xFFFCEFD9);
        fg = const Color(0xFFE8A33D);
        break;
      case 'Confirmado':
        bg = const Color(0xFFF5EDE3);
        fg = const Color(0xFFB8863B);
        break;
      case 'En producción':
        bg = const Color(0xFFE3F0FC);
        fg = const Color(0xFF3D7BE8);
        break;
      case 'Control de calidad':
        bg = Colors.orange.withValues(alpha: 0.12);
        fg = Colors.orange.shade800;
        break;
      case 'Listo para entrega':
        bg = const Color(0xFFE3F5E6);
        fg = const Color(0xFF3FA34D);
        break;
      case 'Entregado':
      case 'Completado':
        bg = const Color(0xFFE3F5E6);
        fg = const Color(0xFF3FA34D);
        break;
      case 'Cancelado':
      default:
        bg = const Color(0xFFFCE8E6);
        fg = const Color(0xFFD9383A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _simularDescargarDiseno(BuildContext context, OrderItem pedido) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EDE3),
          title: const Text('Descargar Diseño Sublimación', style: TextStyle(color: Color(0xFF0D2818), fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido ID: ${pedido.id}', style: const TextStyle(color: Color(0xFF4A5D4C))),
              const SizedBox(height: 8),
              Text('Producto Base: ${pedido.nombre}', style: const TextStyle(color: Color(0xFF4A5D4C))),
              const SizedBox(height: 8),
              Text('Personalización: ${pedido.detalle}', style: const TextStyle(color: Color(0xFF4A5D4C))),
              const SizedBox(height: 16),
              const Center(
                child: Icon(Icons.insert_drive_file, size: 72, color: Color(0xFFB8863B)),
              ),
              const SizedBox(height: 12),
              const Text('Archivo listo para impresión (formato SVG/PNG a alta resolución).', style: TextStyle(color: Color(0xFF4A5D4C), fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Color(0xFF4A5D4C))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('¡Diseño SVG para "${pedido.nombre}" descargado con éxito!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2818)),
              child: const Text('Descargar SVG', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminacion(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF6F0),
          title: const Text('Cancelar Pedido'),
          content: const Text('¿Estás seguro de que deseas cancelar este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _orderService.eliminarPedido(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pedido cancelado correctamente.')),
                );
              },
              child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
