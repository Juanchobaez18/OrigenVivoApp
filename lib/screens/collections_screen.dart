import 'package:flutter/material.dart';
import 'designs_screen.dart';

class CollectionItem {
  final String nombre;
  final String disenosCount;
  final IconData icono;
  final Color colorIcono;

  CollectionItem({
    required this.nombre,
    required this.disenosCount,
    required this.icono,
    required this.colorIcono,
  });
}

class CollectionsScreen extends StatelessWidget {
  final String? productoSeleccionado;
  final bool isEmbedded; // True if shown inside the dashboard tab bar directly

  const CollectionsScreen({
    super.key,
    this.productoSeleccionado,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    // List of collections matching Page 6 of the PDF
    final List<CollectionItem> colecciones = [
      CollectionItem(
        nombre: 'Boyacá',
        disenosCount: '24 diseños',
        icono: Icons.landscape,
        colorIcono: Colors.green.shade700,
      ),
      CollectionItem(
        nombre: 'Café',
        disenosCount: '18 diseños',
        icono: Icons.coffee,
        colorIcono: const Color(0xFF8B5E34),
      ),
      CollectionItem(
        nombre: 'Amor',
        disenosCount: '20 diseños',
        icono: Icons.favorite,
        colorIcono: Colors.red.shade400,
      ),
      CollectionItem(
        nombre: 'Mascotas',
        disenosCount: '16 diseños',
        icono: Icons.pets,
        colorIcono: Colors.brown.shade600,
      ),
      CollectionItem(
        nombre: 'Infantil',
        disenosCount: '22 diseños',
        icono: Icons.child_friendly,
        colorIcono: Colors.orange.shade400,
      ),
      CollectionItem(
        nombre: 'Empresas',
        disenosCount: '15 diseños',
        icono: Icons.business,
        colorIcono: Colors.blue.shade700,
      ),
      CollectionItem(
        nombre: 'Temporadas',
        disenosCount: '28 diseños',
        icono: Icons.celebration,
        colorIcono: Colors.teal,
      ),
    ];

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (productoSeleccionado != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0E3821),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Personalizando: $productoSeleccionado',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                'COLECCIONES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E3821),
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Elige una coleccion y descubre diseños exclusivos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: colecciones.length,
            itemBuilder: (context, index) {
              final col = colecciones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: const Color(0xFFFBF9F6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: col.colorIcono.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      col.icono,
                      color: col.colorIcono,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    col.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  subtitle: Text(
                    col.disenosCount,
                    style: const TextStyle(color: Colors.black45),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF8B5E34),
                    ),
                  ),
                  onTap: () {
                    // Navigate to designs screen for the chosen collection
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DesignsScreen(
                          coleccion: col.nombre,
                          productoSeleccionado: productoSeleccionado,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );

    if (isEmbedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0E3821)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Colecciones',
          style: TextStyle(
            color: Color(0xFF0E3821),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }
}
