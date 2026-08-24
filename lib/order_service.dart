import 'package:flutter/material.dart';
import 'supabase_client.dart';

class OrderItem {
  final String id;
  final String tipo; // 'Bebidas y Alimentos' o 'Sublimación'
  final String nombre;
  final String detalle; // e.g. "Diseño: Boyacá" o "Cafetería Origen Vivo"
  final int cantidad;
  final double precio;
  final DateTime fecha;
  String estado; // 'Pendiente', 'Preparando', 'Completado', 'Cancelado'

  OrderItem({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.detalle,
    required this.cantidad,
    required this.precio,
    required this.fecha,
    this.estado = 'Pendiente',
  });
}

class OrderService {
  // Singleton pattern
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;

  OrderService._internal() {
    // Carga inicial asíncrona de pedidos desde Supabase
    cargarPedidosDesdeDB();
  }

  final List<OrderItem> _pedidos = [];
  final List<Map<String, dynamic>> _carritoCafe = [];
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  List<OrderItem> get pedidos => List.unmodifiable(_pedidos);
  List<Map<String, dynamic>> get carritoCafe => List.unmodifiable(_carritoCafe);

  // Cargar pedidos desde la Base de Datos de Supabase
  Future<void> cargarPedidosDesdeDB() async {
    try {
      final response = await supabase
          .from('pedido_detalles')
          .select('*, pedidos(*)');

      final List<OrderItem> dbItems = [];
      for (final row in response) {
        final parent = row['pedidos'];
        if (parent == null) continue;
        dbItems.add(
          OrderItem(
            id: row['id'].toString(),
            tipo: parent['tipo'] as String? ?? 'Bebidas y Alimentos',
            nombre: row['nombre_producto'] as String? ?? '',
            detalle: row['detalle_personalizacion'] as String? ?? '',
            cantidad: row['cantidad'] as int? ?? 1,
            precio: (row['precio_unitario'] as num? ?? 0.0).toDouble(),
            fecha: DateTime.tryParse(parent['fecha'] as String? ?? '') ?? DateTime.now(),
            estado: parent['estado'] as String? ?? 'Pendiente',
          ),
        );
      }
      _pedidos.clear();
      _pedidos.addAll(dbItems);
      _notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar pedidos de Supabase: $e');
    }
  }

  // Módulo Café: Agregar al carrito
  void agregarAlCarritoCafe(Map<String, dynamic> item) {
    final index = _carritoCafe.indexWhere((element) => element['nombre'] == item['nombre']);
    if (index != -1) {
      _carritoCafe[index]['cantidad'] += item['cantidad'];
    } else {
      _carritoCafe.add(Map<String, dynamic>.from(item));
    }
    _notifyListeners();
  }

  // Módulo Café: Quitar del carrito
  void quitarDelCarritoCafe(String nombre) {
    _carritoCafe.removeWhere((element) => element['nombre'] == nombre);
    _notifyListeners();
  }

  // Módulo Café: Limpiar carrito
  void limpiarCarritoCafe() {
    _carritoCafe.clear();
    _notifyListeners();
  }

  // Registrar pedido de Sublimación en la Base de Datos
  Future<void> registrarPedidoSublimacion({
    required String producto,
    required String diseno,
    required double precio,
  }) async {
    try {
      final pedidoId = 'SUB-${DateTime.now().millisecondsSinceEpoch}';
      final userId = supabase.auth.currentUser?.id;

      // 1. Insertar en tabla principal de pedidos
      await supabase.from('pedidos').insert({
        'id': pedidoId,
        'user_id': userId,
        'tipo': 'Sublimación',
        'estado': 'Pendiente',
        'total': precio,
      });

      // 2. Insertar en detalles del pedido
      await supabase.from('pedido_detalles').insert({
        'pedido_id': pedidoId,
        'nombre_producto': producto,
        'detalle_personalizacion': diseno,
        'cantidad': 1,
        'precio_unitario': precio,
      });

      // 3. Sincronizar UI cargando de Supabase
      await cargarPedidosDesdeDB();
    } catch (e) {
      debugPrint('Error al registrar pedido de sublimación: $e');
    }
  }

  // Registrar pedido de Café en la Base de Datos (Checkout)
  Future<void> realizarCheckoutCafe() async {
    if (_carritoCafe.isEmpty) return;

    try {
      final pedidoId = 'CAF-${DateTime.now().millisecondsSinceEpoch}';
      final userId = supabase.auth.currentUser?.id;
      
      double total = 0.0;
      for (final item in _carritoCafe) {
        total += (item['precio'] as double) * (item['cantidad'] as int);
      }

      // 1. Insertar el Pedido principal
      await supabase.from('pedidos').insert({
        'id': pedidoId,
        'user_id': userId,
        'tipo': 'Bebidas y Alimentos',
        'estado': 'Pendiente',
        'total': total,
      });

      // 2. Insertar los Detalles de cada producto del carrito
      for (final item in _carritoCafe) {
        await supabase.from('pedido_detalles').insert({
          'pedido_id': pedidoId,
          'nombre_producto': item['nombre'] as String,
          'detalle_personalizacion': 'Cafetería Origen Vivo',
          'cantidad': item['cantidad'] as int,
          'precio_unitario': item['precio'] as double,
        });
      }

      limpiarCarritoCafe();

      // 3. Sincronizar UI cargando de Supabase
      await cargarPedidosDesdeDB();
    } catch (e) {
      debugPrint('Error al realizar checkout de café: $e');
    }
  }

  // Funciones de Administración: Actualizar estado en la base de datos
  Future<void> actualizarEstadoPedido(String id, String nuevoEstado) async {
    try {
      // Buscar el pedido_id al que pertenece este detalle
      final res = await supabase
          .from('pedido_detalles')
          .select('pedido_id')
          .eq('id', int.parse(id))
          .maybeSingle();

      if (res != null && res['pedido_id'] != null) {
        final String pid = res['pedido_id'] as String;
        
        // Actualizar el estado en la tabla pedidos
        await supabase
            .from('pedidos')
            .update({'estado': nuevoEstado})
            .eq('id', pid);

        // Recargar pedidos
        await cargarPedidosDesdeDB();
      }
    } catch (e) {
      debugPrint('Error al actualizar estado del pedido: $e');
    }
  }

  // Funciones de Administración: Eliminar pedido de la base de datos
  Future<void> eliminarPedido(String id) async {
    try {
      final res = await supabase
          .from('pedido_detalles')
          .select('pedido_id')
          .eq('id', int.parse(id))
          .maybeSingle();

      if (res != null && res['pedido_id'] != null) {
        final String pid = res['pedido_id'] as String;

        // Eliminar de pedidos (eliminará en cascada los detalles)
        await supabase
            .from('pedidos')
            .delete()
            .eq('id', pid);

        // Recargar pedidos
        await cargarPedidosDesdeDB();
      }
    } catch (e) {
      debugPrint('Error al eliminar pedido de la DB: $e');
    }
  }
}
