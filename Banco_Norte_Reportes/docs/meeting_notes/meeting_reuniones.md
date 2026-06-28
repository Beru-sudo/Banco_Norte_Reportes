---

**ACTA DE REUNIÓN N° 001 — PROYECTO BANCONORTE**

| Campo | Detalle |
|-------|---------|
| **Fecha** | 15 de junio de 2026 |
| **Hora** | 10:00 - 11:30 |
| **Lugar** | Sala de conferencias, Universidad Científica del Sur |
| **Asistentes** | Sánchez Echevarría, Sebastian Alberto; Gómez Ccente, Lino Roy; [Integrante 3]; [Integrante 4]; [Integrante 5] |
| **Objetivo** | Kickoff del Caso 3: Automatización de Reportes Financieros |

---

## 1. Agenda

- Presentación del escenario BancoNorte
- Revisión de las 3 tareas prácticas
- Distribución de responsabilidades
- Definición de hitos y entregables

---

## 2. Decisiones Tomadas

| Decisión | Justificación |
|----------|---------------|
| Priorizar Tarea 3 (SQL) como punto de partida | Es el cuello de botella crítico; sin extracción rápida, todo el pipeline se retrasa |
| Usar PostgreSQL 14+ como motor de base de datos | Especificado en el caso; soporta vistas materializadas con REFRESH CONCURRENTLY |
| Estructura de carpetas en mayúsculas para Data, Python, R, SQL, Notebooks | Consistencia con convenciones del equipo previo (Caso 1 y 2) |
| Tickers de prueba para VaR: AAPL, MSFT, GOOGL, AMZN, TSLA | Cartera diversificada sector tecnología/consumo, datos históricos disponibles en yfinance |

---

## 3. Distribución de Responsabilidades

| Integrante | Código | Tarea Principal |
|------------|--------|-----------------|
| Sánchez Echevarría, Sebastian Alberto | 100159969 | Tarea 3 (SQL optimización) + Infraestructura Git |
| Gómez Ccente, Lino Roy | 100162894 | Tarea 2 (VaR en R) + Documentación RMarkdown |
| [Integrante 3] | [Código] | Tarea 1 (Python ETL) + Tests unitarios |
| [Integrante 4] | [Código] | Dashboards Power BI + Visualización ejecutiva |
| [Integrante 5] | [Código] | Jupyter Notebooks + Documentación reproducible |

---

## 4. Acciones Pendientes

| Acción | Responsable | Fecha límite |
|--------|-------------|--------------|
| Crear repositorio GitHub y estructura inicial | Sánchez Echevarría | 16 de junio |
| Ejecutar query original y medir tiempo base | Sánchez Echevarría | 17 de junio |
| Desarrollar índices y vista materializada | Sánchez Echevarría | 18 de junio |
| Validar función calcular_var con datos benchmark | Gómez Ccente | 18 de junio |
| Desarrollar reporte_var.Rmd con gráficos | Gómez Ccente | 20 de junio |
| Migrar reporte Excel a etl_pipeline.py | [Integrante 3] | 19 de junio |
| Crear test_etl.py con cobertura > 80% | [Integrante 3] | 21 de junio |
| Diseñar wireframes de dashboards ejecutivos | [Integrante 4] | 20 de junio |
| Conectar Power BI a datos procesados | [Integrante 4] | 22 de junio |
| Crear notebook de análisis exploratorio | [Integrante 5] | 19 de junio |
| Documentar arquitectura en docs/architecture/ | [Integrante 5] | 21 de junio |
| Primera reunión de seguimiento | Todos | 20 de junio |

---

## 5. Riesgos Identificados

- Dependencia de conexión a internet para descarga de datos de mercado (yfinance)
- Posible incompatibilidad de versiones entre paquetes de R (quantmod vs. tidyverse)
- Integrantes 3, 4 y 5 aún no confirman disponibilidad horaria completa

---

## 6. Próxima Reunión

- **Fecha:** 20 de junio de 2026
- **Objetivo:** Revisar avance de Tarea 3, validar primeros resultados de VaR y demo del ETL

---

*Documento generado el 15 de junio de 2026 — Proyecto académico Universidad Científica del Sur*

