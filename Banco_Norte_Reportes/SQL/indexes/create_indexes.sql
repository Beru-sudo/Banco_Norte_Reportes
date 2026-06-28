-- ============================================
-- CREACION DE INDICES OPTIMIZADOS
-- BancoNorte - Data Warehouse
-- Ejecutar: psql -d banco_norte -f create_indexes.sql
-- ============================================

-- Nota: Usar CONCURRENTLY para evitar bloqueo de tablas en produccion
-- Requiere: SET maintenance_work_mem = '256MB';

-- ============================================
-- INDICES TABLA: transacciones
-- ============================================

-- Indice 1: Fecha (filtro mas frecuente en reportes mensuales)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transacciones_fecha 
ON transacciones(fecha);

-- Indice 2: Cuenta + Fecha (JOIN con clientes + filtro temporal)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transacciones_cuenta_fecha 
ON transacciones(cuenta_id, fecha);

-- Indice 3: Estado + Fecha (filtrar solo activas por periodo)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transacciones_estado_fecha 
ON transacciones(estado, fecha) 
WHERE estado = 'ACTIVO';

-- Indice 4: Tipo de transaccion (agregaciones por categoria)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transacciones_tipo 
ON transacciones(tipo_transaccion, fecha);

-- Indice 5: Monto (deteccion de outliers, rangos)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transacciones_monto 
ON transacciones(monto) 
WHERE monto > 10000;

-- ============================================
-- INDICES TABLA: clientes
-- ============================================

-- Indice 6: ID de cliente (JOIN principal)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_clientes_id 
ON clientes(id);

-- Indice 7: Clientes activos (filtro recurrente)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_clientes_activos 
ON clientes(segmento, region) 
WHERE activo = TRUE;

-- Indice 8: Segmento (reportes por segmento de negocio)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_clientes_segmento 
ON clientes(segmento);

-- ============================================
-- INDICES TABLA: productos
-- ============================================

-- Indice 9: ID de producto (JOIN con transacciones)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_productos_id 
ON productos(id);

-- Indice 10: Categoria de producto (agregaciones)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_productos_categoria 
ON productos(categoria);

-- ============================================
-- VERIFICACION
-- ============================================

SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('transacciones', 'clientes', 'productos')
ORDER BY tablename, indexname;

-- ============================================
-- ESTADISTICAS DE USO (ejecutar despues de 1 semana)
-- ============================================
-- SELECT * FROM pg_stat_user_indexes WHERE relname = 'transacciones';