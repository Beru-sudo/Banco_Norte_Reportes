-- ============================================
-- VISTAS MATERIALIZADAS
-- BancoNorte - Data Warehouse
-- Ejecutar: psql -d banco_norte -f create_materialized_views.sql
-- ============================================

-- ============================================
-- VISTA 1: Resumen Mensual por Cliente
-- Uso: Reportes de saldo, actividad, segmentacion
-- Refresh: Diario (2:00 AM)
-- ============================================

DROP MATERIALIZED VIEW IF EXISTS mv_resumen_mensual CASCADE;

CREATE MATERIALIZED VIEW mv_resumen_mensual AS
SELECT
    t.cuenta_id,
    c.nombre_cliente,
    c.segmento,
    c.region,
    DATE_TRUNC('month', t.fecha) AS mes,
    SUM(t.monto)                 AS total_mes,
    COUNT(*)                     AS num_transacciones,
    AVG(t.monto)                 AS promedio_mes,
    SUM(t.comision)              AS total_comisiones,
    MAX(t.fecha)                 AS ultima_transaccion
FROM transacciones t
INNER JOIN clientes c ON t.cuenta_id = c.id
WHERE t.estado = 'ACTIVO'
  AND c.activo = TRUE
GROUP BY
    t.cuenta_id,
    c.nombre_cliente,
    c.segmento,
    c.region,
    DATE_TRUNC('month', t.fecha);

-- Indices en vista materializada
CREATE UNIQUE INDEX idx_mv_resumen_mensual_pk
ON mv_resumen_mensual(cuenta_id, mes);

CREATE INDEX idx_mv_resumen_mensual_segmento
ON mv_resumen_mensual(segmento, mes);

CREATE INDEX idx_mv_resumen_mensual_region
ON mv_resumen_mensual(region, mes);

-- ============================================
-- VISTA 2: Resumen Diario de Actividad
-- Uso: Dashboards en tiempo real, alertas
-- Refresh: Cada 4 horas
-- ============================================

DROP MATERIALIZED VIEW IF EXISTS mv_resumen_diario CASCADE;

CREATE MATERIALIZED VIEW mv_resumen_diario AS
-- CORRECCIÓN: usar INNER JOIN para garantizar que segmento no sea NULL,
-- lo que rompia el UNIQUE INDEX (dia, segmento) con LEFT JOIN anterior.
-- Se agrega alias explicito en WHERE para evitar ambiguedad de columna 'fecha'.
SELECT
    DATE_TRUNC('day', t.fecha)                              AS dia,
    c.segmento,
    COUNT(DISTINCT t.cuenta_id)                             AS clientes_activos,
    COUNT(*)                                                AS total_transacciones,
    SUM(t.monto)                                            AS volumen_total,
    AVG(t.monto)                                            AS ticket_promedio,
    SUM(CASE WHEN t.estado = 'ACTIVO'  THEN 1 ELSE 0 END)  AS transacciones_ok,
    SUM(CASE WHEN t.estado = 'ANULADA' THEN 1 ELSE 0 END)  AS transacciones_anuladas
FROM transacciones t
INNER JOIN clientes c ON t.cuenta_id = c.id
WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', t.fecha), c.segmento;

CREATE UNIQUE INDEX idx_mv_resumen_diario_pk
ON mv_resumen_diario(dia, segmento);

-- ============================================
-- VISTA 3: Cartera de Productos por Cliente
-- Uso: Cross-selling, analisis de productos
-- Refresh: Semanal
-- ============================================

DROP MATERIALIZED VIEW IF EXISTS mv_cartera_productos CASCADE;

CREATE MATERIALIZED VIEW mv_cartera_productos AS
SELECT
    c.id           AS cuenta_id,
    c.nombre_cliente,
    c.segmento,
    p.categoria    AS categoria_producto,
    p.nombre       AS nombre_producto,
    COUNT(t.id)    AS frecuencia_uso,
    SUM(t.monto)   AS monto_total,
    MAX(t.fecha)   AS ultimo_uso
FROM clientes c
INNER JOIN transacciones t ON c.id = t.cuenta_id
INNER JOIN productos p     ON t.producto_id = p.id
WHERE c.activo = TRUE
  AND t.estado = 'ACTIVO'
GROUP BY c.id, c.nombre_cliente, c.segmento, p.categoria, p.nombre;

CREATE INDEX idx_mv_cartera_segmento
ON mv_cartera_productos(segmento, categoria_producto);

-- ============================================
-- FUNCION DE REFRESCO AUTOMATIZADO
-- ============================================

CREATE OR REPLACE FUNCTION refrescar_vistas_materializadas()
RETURNS TABLE(vista TEXT, estado TEXT, duracion INTERVAL) AS $$
DECLARE
    v_start TIMESTAMP;
    v_name  TEXT;
    vistas  TEXT[] := ARRAY['mv_resumen_mensual', 'mv_resumen_diario', 'mv_cartera_productos'];
BEGIN
    FOREACH v_name IN ARRAY vistas
    LOOP
        v_start := clock_timestamp();
        BEGIN
            EXECUTE format('REFRESH MATERIALIZED VIEW CONCURRENTLY %I', v_name);
            RETURN QUERY SELECT v_name, 'OK'::TEXT, clock_timestamp() - v_start;
        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT v_name, 'ERROR: ' || SQLERRM, clock_timestamp() - v_start;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMANDOS DE REFRESCO MANUAL
-- ============================================
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_resumen_mensual;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_resumen_diario;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_cartera_productos;
-- SELECT * FROM refrescar_vistas_materializadas();
