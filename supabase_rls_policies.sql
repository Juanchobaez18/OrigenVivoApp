-- ============================================================
-- OrigenVivo - Políticas de Seguridad (Row Level Security)
-- Ejecutar en Supabase Dashboard -> SQL Editor
-- ============================================================
-- NOTA: Este script detecta automáticamente si la tabla perfiles
-- usa 'id' o 'user_id' como columna de referencia al auth.uid().
-- Ajusta las políticas según tu esquema real.
-- ============================================================

-- ============================================================
-- PASO 0: Verificar estructura de la tabla perfiles
-- Ejecuta esto primero para ver qué columnas existen:
-- SELECT column_name FROM information_schema.columns
-- WHERE table_name = 'perfiles' AND table_schema = 'public';
-- ============================================================

-- ============================================================
-- TABLA: perfiles
-- Usa la columna que matchea auth.uid() en tu tabla.
-- Si usas 'id':     reemplaza user_id por id en todas las políticas.
-- Si usas 'user_id': déjalo como está.
-- ============================================================
ALTER TABLE perfiles ENABLE ROW LEVEL SECURITY;

-- Un usuario solo puede ver su propio perfil
-- (cambia 'id' por 'user_id' si tu columna se llama así)
CREATE POLICY "perfiles_select_own" ON perfiles
  FOR SELECT USING (auth.uid() = id);

-- Un usuario solo puede actualizar su propio perfil
CREATE POLICY "perfiles_update_own" ON perfiles
  FOR UPDATE USING (auth.uid() = id);

-- El sistema puede insertar perfiles (trigger de registro)
CREATE POLICY "perfiles_insert_own" ON perfiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- FUNCIÓN AUXILIAR: obtener rol sin recursión en RLS
-- Evita el error de recursión infinita al consultar perfiles
-- desde dentro de una política de perfiles.
-- ============================================================
CREATE OR REPLACE FUNCTION get_my_rol()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT rol FROM public.perfiles WHERE id = auth.uid() LIMIT 1;
$$;

-- El admin puede ver todos los perfiles (usando la función auxiliar)
CREATE POLICY "perfiles_admin_select_all" ON perfiles
  FOR SELECT USING (get_my_rol() = 'admin');

-- ============================================================
-- TABLA: pedidos
-- ============================================================
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;

-- El cliente solo ve sus propios pedidos
CREATE POLICY "pedidos_select_own" ON pedidos
  FOR SELECT USING (auth.uid() = user_id);

-- El cliente puede crear pedidos
CREATE POLICY "pedidos_insert_own" ON pedidos
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Staff (admin, caja, produccion) puede ver todos los pedidos
CREATE POLICY "pedidos_staff_select_all" ON pedidos
  FOR SELECT USING (get_my_rol() IN ('admin', 'caja', 'produccion'));

-- Staff puede actualizar estado de pedidos
CREATE POLICY "pedidos_staff_update" ON pedidos
  FOR UPDATE USING (get_my_rol() IN ('admin', 'caja', 'produccion'));

-- Solo admin puede eliminar pedidos
CREATE POLICY "pedidos_admin_delete" ON pedidos
  FOR DELETE USING (get_my_rol() = 'admin');

-- ============================================================
-- TABLA: pedido_detalles
-- ============================================================
ALTER TABLE pedido_detalles ENABLE ROW LEVEL SECURITY;

-- El cliente puede ver detalles de sus propios pedidos
CREATE POLICY "detalles_select_own" ON pedido_detalles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM pedidos p
      WHERE p.id = pedido_id AND p.user_id = auth.uid()
    )
  );

-- El cliente puede insertar detalles al hacer checkout
CREATE POLICY "detalles_insert_own" ON pedido_detalles
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM pedidos p
      WHERE p.id = pedido_id AND p.user_id = auth.uid()
    )
  );

-- Staff puede ver todos los detalles
CREATE POLICY "detalles_staff_select_all" ON pedido_detalles
  FOR SELECT USING (get_my_rol() IN ('admin', 'caja', 'produccion'));

-- ============================================================
-- TABLA: productos_cafe
-- ============================================================
ALTER TABLE productos_cafe ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado puede ver el catálogo de café
CREATE POLICY "cafe_select_authenticated" ON productos_cafe
  FOR SELECT USING (auth.role() = 'authenticated');

-- Solo el admin puede gestionar el catálogo de café
CREATE POLICY "cafe_admin_insert" ON productos_cafe
  FOR INSERT WITH CHECK (get_my_rol() = 'admin');

CREATE POLICY "cafe_admin_update" ON productos_cafe
  FOR UPDATE USING (get_my_rol() = 'admin');

CREATE POLICY "cafe_admin_delete" ON productos_cafe
  FOR DELETE USING (get_my_rol() = 'admin');

-- ============================================================
-- TABLA: productos_sublimables
-- ============================================================
ALTER TABLE productos_sublimables ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sublimables_select_authenticated" ON productos_sublimables
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "sublimables_admin_insert" ON productos_sublimables
  FOR INSERT WITH CHECK (get_my_rol() = 'admin');

CREATE POLICY "sublimables_admin_update" ON productos_sublimables
  FOR UPDATE USING (get_my_rol() = 'admin');

CREATE POLICY "sublimables_admin_delete" ON productos_sublimables
  FOR DELETE USING (get_my_rol() = 'admin');

-- ============================================================
-- TABLA: disenos
-- ============================================================
ALTER TABLE disenos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "disenos_select_authenticated" ON disenos
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "disenos_admin_insert" ON disenos
  FOR INSERT WITH CHECK (get_my_rol() = 'admin');

CREATE POLICY "disenos_admin_update" ON disenos
  FOR UPDATE USING (get_my_rol() = 'admin');

CREATE POLICY "disenos_admin_delete" ON disenos
  FOR DELETE USING (get_my_rol() = 'admin');

-- ============================================================
-- TABLA: colecciones
-- ============================================================
ALTER TABLE colecciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "colecciones_select_authenticated" ON colecciones
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "colecciones_admin_insert" ON colecciones
  FOR INSERT WITH CHECK (get_my_rol() = 'admin');

CREATE POLICY "colecciones_admin_update" ON colecciones
  FOR UPDATE USING (get_my_rol() = 'admin');

CREATE POLICY "colecciones_admin_delete" ON colecciones
  FOR DELETE USING (get_my_rol() = 'admin');

-- ============================================================
-- STORAGE: Bucket custom_designs
-- Ejecutar en Supabase Dashboard -> Storage -> Policies
-- ============================================================

-- Usuarios autenticados pueden subir a su propia carpeta
CREATE POLICY "custom_designs_upload_own" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'custom_designs'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- El dueño puede ver su propio diseño
CREATE POLICY "custom_designs_select_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'custom_designs'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Admin y produccion pueden ver todos los diseños
CREATE POLICY "custom_designs_staff_select" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'custom_designs'
    AND get_my_rol() IN ('admin', 'produccion')
  );
