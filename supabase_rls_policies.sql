-- ============================================================
-- OrigenVivo - Políticas de Seguridad (Row Level Security)
-- Ejecutar en Supabase Dashboard → SQL Editor
-- ============================================================

-- ============================================================
-- TABLA: perfiles
-- ============================================================
ALTER TABLE perfiles ENABLE ROW LEVEL SECURITY;

-- Un usuario solo puede ver su propio perfil
CREATE POLICY "perfiles_select_own" ON perfiles
  FOR SELECT USING (auth.uid() = user_id);

-- Un usuario solo puede actualizar su propio perfil
CREATE POLICY "perfiles_update_own" ON perfiles
  FOR UPDATE USING (auth.uid() = user_id);

-- Solo el sistema (trigger) puede insertar perfiles (al registrarse)
CREATE POLICY "perfiles_insert_trigger" ON perfiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- El admin puede ver todos los perfiles
CREATE POLICY "perfiles_admin_select_all" ON perfiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid() AND p.rol = 'admin'
    )
  );

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
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid()
        AND p.rol IN ('admin', 'caja', 'produccion')
    )
  );

-- Staff puede actualizar estado de pedidos
CREATE POLICY "pedidos_staff_update" ON pedidos
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid()
        AND p.rol IN ('admin', 'caja', 'produccion')
    )
  );

-- Solo admin puede eliminar pedidos
CREATE POLICY "pedidos_admin_delete" ON pedidos
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid() AND p.rol = 'admin'
    )
  );

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
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid()
        AND p.rol IN ('admin', 'caja', 'produccion')
    )
  );

-- ============================================================
-- TABLA: productos_cafe
-- ============================================================
ALTER TABLE productos_cafe ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado puede ver el catálogo de café
CREATE POLICY "cafe_select_authenticated" ON productos_cafe
  FOR SELECT USING (auth.role() = 'authenticated');

-- Solo el admin puede gestionar el catálogo de café
CREATE POLICY "cafe_admin_all" ON productos_cafe
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid() AND p.rol = 'admin'
    )
  );

-- ============================================================
-- TABLA: productos_sublimables
-- ============================================================
ALTER TABLE productos_sublimables ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado puede ver los productos
CREATE POLICY "sublimables_select_authenticated" ON productos_sublimables
  FOR SELECT USING (auth.role() = 'authenticated');

-- Solo el admin puede gestionar el catálogo de sublimación
CREATE POLICY "sublimables_admin_all" ON productos_sublimables
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid() AND p.rol = 'admin'
    )
  );

-- ============================================================
-- TABLA: disenos
-- ============================================================
ALTER TABLE disenos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "disenos_select_authenticated" ON disenos
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "disenos_admin_all" ON disenos
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid() AND p.rol = 'admin'
    )
  );

-- ============================================================
-- TABLA: colecciones
-- ============================================================
ALTER TABLE colecciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "colecciones_select_authenticated" ON colecciones
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "colecciones_admin_all" ON colecciones
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid() AND p.rol = 'admin'
    )
  );

-- ============================================================
-- STORAGE: Bucket custom_designs
-- Configura el bucket para que solo usuarios autenticados puedan
-- subir y solo el dueño o staff pueda leer.
-- Ejecutar en Supabase Dashboard → Storage → Policies
-- ============================================================

-- Permite a usuarios autenticados subir sus diseños a su carpeta
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

-- El staff puede ver todos los diseños para producción
CREATE POLICY "custom_designs_staff_select" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'custom_designs'
    AND EXISTS (
      SELECT 1 FROM perfiles p
      WHERE p.user_id = auth.uid()
        AND p.rol IN ('admin', 'produccion')
    )
  );
