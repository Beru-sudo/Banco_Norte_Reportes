-- ============================================
-- QUERY OPTIMIZADA PARA REPORTE MENSUAL
-- BancoNorte - Data Warehouse
-- Caso 3 - Tarea 3: Optimización SQL
-- Tiempo objetivo: < 15 minutos (vs 3 horas original)
-- ============================================

-- EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
-- Para ver plan de ejecución antes de correr

WITH 
-- ============================================
-- CTE 1: Parametros configurables
-- ============================================
parametros AS (
    SELECT 
        CURRENT_DATE - INTERVAL '30 days' AS fecha_inicio,
        CURRENT_DATE AS fecha_fin,
        'ACTIVO' AS estado_valido
),

-- ============================================
-- CTE 2: Transacciones recientes (extraccion incremental)
-- Usa indice: idx_transacciones_estado_fecha
-- ============================================
transacciones_recientes AS (
    SELECT 
        t.id,
        t.cuenta_id,
        t.fecha,
        t.monto,
        t.comision,
        t.tipo_transaccion,
        t.estado
    FROM transacciones t
    CROSS JOIN parametros p
    WHERE t.fecha >= p.fecha_inicio
      AND t.fecha <= p.fecha_fin
      AND t.estado = p.estado_valido
),

-- ============================================
-- CTE 3: Clientes activos (filtrado temprano)
-- Usa indice: idx_clientes_activos
-- ============================================
clientes_base AS (
    SELECT 
        id AS cuenta_id,
        nombre_cliente,
        segmento,
        region,
        fecha_alta
    FROM clientes
    WHERE activo = TRUE
),

-- ============================================
-- CTE 4: Agregaciones desde vista materializada
-- Usa: mv_resumen_mensual (pre-calculada)
-- ============================================
agregado_historico AS (
    SELECT 
        cuenta_id,
        mes,
        total_mes,
        num_transacciones,
        promedio_mes
    FROM mv_resumen_mensual
    WHERE mes >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3 months')
),

-- ============================================
-- CTE 5: Union de datos recientes + historico
-- ============================================
union_datos AS (
    SELECT 
        cb.cuenta_id,
        cb.nombre_cliente,
        cb.segmento,
        cb.region,
        tr.fecha,
        tr.monto,
        tr.comision,
        tr.tipo_transaccion,
        ah.total_mes AS total_mes_anterior,
        ah.num_transacciones AS freq_mes_anterior
    FROM clientes_base cb
    LEFT JOIN transacciones_recientes tr ON cb.cuenta_id = tr.cuenta_id
    LEFT JOIN agregado_historico ah ON cb.cuenta_id = ah.cuenta_id
        AND ah.mes = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
),

-- ============================================
-- CTE 6: Agregaciones finales por segmento/region
-- ============================================
resumen_final AS (
    SELECT 
        segmento,
        region,
        COUNT(DISTINCT cuenta_id) AS num_clientes_activos,
        COUNT(*) AS total_transacciones_periodo,
        SUM(monto) AS volumen_total,
        AVG(monto) AS ticket_promedio,
        SUM(comision) AS total_comisiones,
        AVG(total_mes_anterior) AS promedio_mes_anterior,
        SUM(CASE WHEN tipo_transaccion = 'DEPOSITO' THEN monto ELSE 0 END) AS total_depositos,
        SUM(CASE WHEN tipo_transaccion = 'RETIRO' THEN monto ELSE 0 END) AS total_retiros,
        SUM(CASE WHEN tipo_transaccion = 'TRANSFERENCIA' THEN monto ELSE 0 END) AS total_transferencias
    FROM union_datos
    GROUP BY segmento, region
)

-- ============================================
-- SELECT FINAL: Proyeccion del reporte mensual
-- ============================================
SELECT 
    rf.segmento,
    rf.region,
    rf.num_clientes_activos,
    rf.total_transacciones_periodo,
    ROUND(rf.volumen_total, 2) AS volumen_total,
    ROUND(rf.ticket_promedio, 2) AS ticket_promedio,
    ROUND(rf.total_comisiones, 2) AS total_comisiones,
    ROUND(rf.promedio_mes_anterior, 2) AS promedio_mes_anterior,
    ROUND(rf.total_depositos, 2) AS total_depositos,
    ROUND(rf.total_retiros, 2) AS total_retiros,
    ROUND(rf.total_transferencias, 2) AS total_transferencias,
    
    -- Metricas derivadas adicionales
    ROUND(
        (rf.volumen_total - COALESCE(rf.promedio_mes_anterior * rf.num_clientes_activos, 0)) 
        / NULLIF(rf.promedio_mes_anterior * rf.num_clientes_activos, 0) * 100, 
        2
    ) AS variacion_porcentual_vs_mes_anterior,
    
    ROUND(
        rf.total_comisiones / NULLIF(rf.volumen_total, 0) * 100, 
        2
    ) AS tasa_comision_porcentual,
    
    ROUND(
        rf.total_transferencias / NULLIF(rf.volumen_total, 0) * 100, 
        2
    ) AS pct_transferencias_sobre_total,

    -- Metadata del reporte
    CURRENT_DATE AS fecha_generacion,
    (SELECT fecha_inicio FROM parametros) AS periodo_inicio,
    (SELECT fecha_fin FROM parametros) AS periodo_fin

FROM resumen_final rf

-- Ordenamiento para facilitar lectura del reporte
ORDER BY 
    rf.segmento ASC,
    rf.region ASC;

-- ============================================
-- NOTAS DE OPTIMIZACION
-- ============================================
-- 1. Indices requeridos:
--    - idx_transacciones_estado_fecha ON transacciones(estado, fecha)
--    - idx_clientes_activos ON clientes(activo) WHERE activo = TRUE
--    - idx_mv_resumen_mensual_cuenta_mes ON mv_resumen_mensual(cuenta_id, mes)
--
-- 2. Vista materializada mv_resumen_mensual:
--    - Refrescar diariamente via cron/job programado
--    - Contiene agregaciones pre-calculadas por cuenta/mes
--
-- 3. Para monitoreo de rendimiento:
--    SET work_mem = '256MB';
--    SET effective_cache_size = '4GB';
--    -- Ajustar segun recursos del servidor DW
--
-- 4. Si el volumen crece, considerar:
--    - Particionamiento de transacciones por fecha (RANGE)
--    - Parallel query execution (max_parallel_workers_per_gather)
-- ============================================