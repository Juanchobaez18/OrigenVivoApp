import 'package:flutter/material.dart';
import '../order_service.dart';
import '../supabase_client.dart';

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

  @override
  Widget build(BuildContext context) {
    final todosLosPedidos = _orderService.pedidos;

    // Si es del departamento de producción, solo visualiza pedidos de Sublimación
    final pedidos = widget.role == 'produccion'
        ? todosLosPedidos.where((p) => p.tipo == 'Sublimación').toList()
        : todosLosPedidos;

    // Calcular estadísticas
    final double totalVentas = pedidos
        .where((p) => p.estado == 'Entregado' || p.estado == 'Completado')
        .fold(0, (sum, p) => sum + (p.precio * p.cantidad));
    final int pendientes = pedidos.where((p) => p.estado == 'Pendiente').length;
    final int enProduccion = pedidos.where((p) => p.estado == 'En producción').length;
    final int listoParaEntrega = pedidos.where((p) => p.estado == 'Listo para entrega').length;

    // Filtrar pedidos por estado seleccionado
    final pedidosFiltrados = _filtroEstado == 'Todos'
        ? pedidos
        : pedidos.where((p) => p.estado == _filtroEstado).toList();

    // Título y subtítulo por rol
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
              icon: const Icon(Icons.add_box_outlined, color: Color(0xFFB8863B)),
              tooltip: 'Crear Producto',
              onPressed: () => _abrirFormularioCrearProducto(context),
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
          // Sección de métricas/resumen con fondo verde primario de la marca
          Container(
            color: const Color(0xFF0D2818),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Ventas Realizadas', '\$${totalVentas.toStringAsFixed(0)}', Colors.white.withValues(alpha: 0.08)),
                    _buildStatCard('Pendientes', '$pendientes', const Color(0xFFB8863B).withValues(alpha: 0.2)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('En Taller', '$enProduccion', Colors.blue.withValues(alpha: 0.2)),
                    _buildStatCard('Listos', '$listoParaEntrega', Colors.green.withValues(alpha: 0.2)),
                  ],
                ),
              ],
            ),
          ),

          // Filtros de estado de pedido
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Pendiente', 'Confirmado', 'En producción', 'Control de calidad', 'Listo para entrega', 'Entregado', 'Cancelado'].map((estado) {
                  final esSeleccionado = _filtroEstado == estado;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        estado,
                        style: TextStyle(
                          color: esSeleccionado ? Colors.white : const Color(0xFF0D2818),
                          fontWeight: FontWeight.bold,
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

          // Listado de pedidos
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
                                  // Botón Descargar para producción
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
                                      // Flujo para Rol CAJA o ADMIN
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

                                      // Flujo para Rol PRODUCCION o ADMIN
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
                                            onPressed: () => _orderService.actualizarEstadoPedido(pedido.id, 'Control de calidad'),
                                            icon: const Icon(Icons.fact_check, size: 16),
                                            label: const Text('Control de Calidad', style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange.shade700,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        if (pedido.estado == 'Control de calidad')
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

                                      // Botón Cancelar/Eliminar para admin o caja
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
                              )
                            ],
                          ),
                        ),
                      );
                    },
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

  void _abrirFormularioCrearProducto(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String tipoProducto = 'Café'; // 'Café' o 'Sublimable'
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    final TextEditingController categoryCtrl = TextEditingController(text: 'Bebidas Calientes');
    final TextEditingController priceCtrl = TextEditingController();
    String selectedIcon = 'coffee';
    bool guardando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFAF6F0),
              title: const Text(
                'Nuevo Producto',
                style: TextStyle(color: Color(0xFF0E3821), fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de Producto
                      DropdownButtonFormField<String>(
                        initialValue: tipoProducto,
                        decoration: const InputDecoration(labelText: 'Tipo de Producto'),
                        items: ['Café', 'Sublimable'].map((tipo) {
                          return DropdownMenuItem(value: tipo, child: Text(tipo));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              tipoProducto = val;
                              selectedIcon = val == 'Café' ? 'coffee' : 'checkroom';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nombre
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 12),

                      // Descripción
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa una descripción' : null,
                      ),
                      const SizedBox(height: 12),

                      // Campos condicionales para Café
                      if (tipoProducto == 'Café') ...[
                        DropdownButtonFormField<String>(
                          initialValue: categoryCtrl.text,
                          decoration: const InputDecoration(labelText: 'Categoría'),
                          items: ['Bebidas Calientes', 'Bebidas Frías', 'Alimentos'].map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                categoryCtrl.text = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(labelText: 'Precio (COP)'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Ingresa un precio';
                            if (double.tryParse(value) == null) return 'Ingresa un número válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Selector de Icono
                      DropdownButtonFormField<String>(
                        initialValue: selectedIcon,
                        decoration: const InputDecoration(labelText: 'Icono Ilustrativo'),
                        items: (tipoProducto == 'Café'
                            ? ['coffee', 'coffee_maker', 'local_drink', 'bakery_dining', 'cake']
                            : ['checkroom', 'checkroom_outlined', 'dry_cleaning', 'dry_cleaning_outlined', 'local_cafe', 'accessibility_new', 'child_care', 'opacity']
                        ).map((iconKey) {
                          return DropdownMenuItem(value: iconKey, child: Text(iconKey));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedIcon = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: guardando ? null : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() => guardando = true);

                    try {
                      if (tipoProducto == 'Café') {
                        await supabase.from('productos_cafe').insert({
                          'nombre': nameCtrl.text.trim(),
                          'categoria': categoryCtrl.text,
                          'descripcion': descCtrl.text.trim(),
                          'precio': double.parse(priceCtrl.text.trim()),
                          'icono_name': selectedIcon,
                        });
                      } else {
                        await supabase.from('productos_sublimables').insert({
                          'nombre': nameCtrl.text.trim(),
                          'descripcion': descCtrl.text.trim(),
                          'icono_name': selectedIcon,
                        });
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Producto "$tipoProducto" creado exitosamente en Supabase!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (err) {
                      setDialogState(() => guardando = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar el producto: $err'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3821),
                    foregroundColor: Colors.white,
                  ),
                  child: guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

