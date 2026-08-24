import 'package:flutter/material.dart';
import 'customization_screen.dart';

class DesignItem {
  final String nombre;
  final String descripcion;
  final IconData icono;

  DesignItem({
    required this.nombre,
    required this.descripcion,
    required this.icono,
  });
}

class DesignsScreen extends StatelessWidget {
  final String coleccion;
  final String? productoSeleccionado;

  const DesignsScreen({
    super.key,
    required this.coleccion,
    this.productoSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    // Generar diseños ficticios según la colección (por ejemplo, Boyacá como en el PDF)
    final List<DesignItem> disenos = List.generate(6, (index) {
      return DesignItem(
        nombre: 'MÁS BOYACENSE QUE LA RUANA',
        descripcion: 'Diseño tradicional campesino #${index + 1}',
        icono: Icons.landscape_outlined,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0E3821)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          coleccion.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF0E3821),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text(
                  productoSeleccionado != null 
                      ? 'Aplicando a: $productoSeleccionado' 
                      : 'Elige un diseño para sublimar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B5E34),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Visualiza y selecciona tu estampado favorito',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: disenos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final diseno = disenos[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: const Color(0xFFFBF9F6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _mostrarDetallesDiseno(context, diseno);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Simulación de la ilustración del PDF (Campesino, Ruana, etc.)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5EADA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Color(0xFF8B5E34),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Estampado ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            diseno.nombre,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '• QUE LA RUANA •',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
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

  void _mostrarDetallesDiseno(BuildContext context, DesignItem diseno) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: const Color(0xFFFAF6F0),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                diseno.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E3821),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Colección: $coleccion',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              if (productoSeleccionado != null) ...[
                Text(
                  '¿Deseas enviar a sublimación un(a) "$productoSeleccionado" con este diseño?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                 ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // cerrar sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomizationScreen(
                          productoSeleccionado: productoSeleccionado!,
                          disenoSeleccionado: diseno.nombre,
                          coleccion: coleccion,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E3821),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Personalizar diseño', style: TextStyle(fontSize: 16)),
                ),
              ] else ...[
                const Text(
                  'Primero debes seleccionar un producto de la sección "Personaliza tu Producto" para aplicar este diseño.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E34),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Entendido'),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
