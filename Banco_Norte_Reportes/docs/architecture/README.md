# Caso 3: Automatización de Reportes Financieros — BancoNorte

> **Curso:** Introducción a Data Science  
> **Institución:** Universidad Científica del Sur  
> **Carrera:** Ingeniería Empresarial y de Sistemas  
> **Año:** 2026

## Integrantes

| Nombre | Código |
|--------|--------|
| Sánchez Echevarría, Sebastian Alberto | 100159969 |
| Gómez Ccente, Lino Roy | 100162894 |
| Nombre 3 | codigo |
| Nombre 4 | codigo |
| Nombre 5 | codigo |

---

## Resumen Ejecutivo

Este proyecto automatiza el pipeline de reportes financieros del departamento de BancoNorte, reduciendo el ciclo mensual de **15 días hábiles a menos de 2 días** (87% de reducción). La solución reemplaza procesos manuales en Excel por un stack tecnológico integrado que cubre extracción, transformación, análisis estadístico, visualización y gobernanza de datos.

| Indicador | Estado Actual | Objetivo | Mejora |
|-----------|---------------|----------|--------|
| Tiempo de ciclo de reportes | 15 días hábiles | < 2 días hábiles | 87% reducción |
| Tiempo de extracción SQL | 3 horas | < 15 minutos | 92% reducción |
| Reportes manuales | 40 mensuales | 0 (100% automatizados) | Eliminación de errores humanos |
| Tiempo de onboarding | 2 semanas | 2 días | 90% reducción |

---

## Stack Tecnológico

| Capa | Herramienta | Función |
|------|-------------|---------|
| Extracción | PostgreSQL + SQL optimizado | Reducción de 3 horas a < 15 minutos |
| Transformación | Python (pandas, openpyxl) | Reemplazo de VLOOKUP y agregaciones manuales |
| Análisis | R (tidyverse, rmarkdown) | Cálculo de métricas de riesgo (VaR) |
| Visualización | Power BI / Tableau | Dashboards interactivos para ejecutivos |
| Gobernanza | Git + Jupyter Notebooks | Control de versiones y documentación reproducible |

---

## Estructura del Repositorio

```
banco-norte-reportes/
│
├── README.md                          # Este archivo
├── requirements.txt                   # Dependencias Python
├── .gitignore                         # Archivos ignorados por Git
│
├── data/
│   ├── raw/                           # Datos originales (NO versionar)
│   ├── processed/                     # Datos transformados (NO versionar)
│   └── external/                      # Datos de mercado (yfinance)
│
├── sql/
│   ├── queries/
│   │   └── reporte_mensual_optimizado.sql   # Query principal optimizada
│   ├── indexes/
│   │   └── create_indexes.sql              # Scripts de creación de índices
│   └── views/
│       └── create_materialized_views.sql     # Vistas materializadas
│
├── python/
│   ├── etl/
│   │   └── etl_pipeline.py            # Pipeline ETL principal
│   ├── reports/
│   │   └── (reportes generados)
│   └── tests/
│       └── test_etl.py                # Tests unitarios del ETL
│
├── r/
│   ├── var/
│   │   └── var_calculator.R           # Función VaR (3 métodos)
│   ├── analysis/
│   │   └── (análisis estadísticos)
│   └── reports/
│       └── reporte_var.Rmd            # Reporte reproducible en RMarkdown
│
├── notebooks/
│   ├── exploratory/
│   │   └── 01_analisis_exploratorio.ipynb
│   └── final/
│       └── (notebooks documentados)
│
├── dashboards/
│   ├── powerbi/
│   │   └── (archivos .pbix)
│   └── tableau/
│       └── (archivos .twb)
│
└── docs/
    ├── architecture/
    │   └── README.md                  # Documentación de arquitectura
    └── meeting_notes/
        └── (actas de reunión)
```

---

## Instalación y Configuración

### Requisitos Previos

- Python 3.10+
- R 4.3+
- PostgreSQL 14+
- Git

### 1. Clonar el Repositorio

```bash
git clone https://github.com/[usuario]/banco-norte-reportes.git
cd banco-norte-reportes
```

### 2. Instalar Dependencias Python

```bash
pip install -r requirements.txt
```

### 3. Configurar Base de Datos

Ejecutar los scripts SQL en el siguiente orden:

```bash
# 1. Crear índices (sin bloquear tablas en producción)
psql -h [host] -U [usuario] -d [database] -f sql/indexes/create_indexes.sql

# 2. Crear vistas materializadas
psql -h [host] -U [usuario] -d [database] -f sql/views/create_materialized_views.sql

# 3. Verificar query optimizada
psql -h [host] -U [usuario] -d [database] -f sql/queries/reporte_mensual_optimizado.sql
```

### 4. Configurar R y Paquetes

```r
install.packages(c("tidyverse", "quantmod", "PerformanceAnalytics", "MASS", "rmarkdown"))
```

---

## Uso

### Tarea 1: Pipeline ETL (Python)

```bash
python python/etl/etl_pipeline.py --input data/raw/reporte_original.xlsx --output data/processed/reporte_automatizado.xlsx
```

**Parámetros:**
- `--input`: Ruta al archivo Excel original
- `--output`: Ruta de salida del reporte generado

### Tarea 2: Cálculo de VaR (R)

```r
source("r/var/var_calculator.R")

# Ejemplo de uso
resultado <- calcular_var(
  tickers = c("AAPL", "MSFT", "GOOGL"),
  weights = c(0.4, 0.35, 0.25),
  confidence = 0.95,
  method = "parametric"
)
```

### Tarea 3: Extracción SQL Optimizada

```bash
# Medir tiempo de ejecución
\timing on
\i sql/queries/reporte_mensual_optimizado.sql
```

---

## Tareas Prácticas

### 4.1. Tarea 1: Migración Excel → Python

- **Objetivo:** Reemplazar reporte de 10 hojas con VLOOKUP por script Python de ~200 líneas
- **Archivo:** `python/etl/etl_pipeline.py`
- **Tecnologías:** pandas, openpyxl, logging
- **Tiempo objetivo:** < 5 minutos

**Checklist de Validación:**
- [ ] Datos de salida coinciden con reporte original (sample de 100 registros)
- [ ] Tiempos de ejecución medidos y documentados
- [ ] Manejo de errores implementado (try/except)
- [ ] Logs generados para auditoría
- [ ] Código documentado con docstrings
- [ ] Tests unitarios con cobertura > 80%

### 4.2. Tarea 2: Función VaR en R

- **Objetivo:** Calcular Value at Risk de una cartera con 3 métodos
- **Archivo:** `r/var/var_calculator.R`
- **Tecnologías:** tidyverse, quantmod, PerformanceAnalytics, MASS
- **Métodos:** Paramétrico, Histórico, Monte Carlo

**Checklist de Validación:**
- [ ] Pesos suman exactamente 1
- [ ] Comparación de resultados entre 3 métodos (divergencia < 5%)
- [ ] Test con datos conocidos (benchmark cartera de 1 activo)
- [ ] Reporte en RMarkdown con gráficos
- [ ] Documentación de supuestos y limitaciones

### 4.3. Tarea 3: Optimización SQL

- **Objetivo:** Reducir extracción de 3 horas a < 15 minutos
- **Archivo:** `sql/queries/reporte_mensual_optimizado.sql`
- **Técnicas:** Índices B-Tree, vistas materializadas, CTEs, extracción incremental

**Checklist de Validación:**
- [ ] EXPLAIN (ANALYZE, BUFFERS) muestra mejora cuantificable
- [ ] Tiempo medido: antes (3h) vs. después (< 15 min)
- [ ] Resultados idénticos entre query original y optimizada
- [ ] Índices creados con CONCURRENTLY
- [ ] Vista materializada con REFRESH CONCURRENTLY
- [ ] Estrategia de mantenimiento definida
- [ ] Documentación en `docs/sql/indexes.md`

---

## Arquitectura de la Solución

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Fuentes       │     │   Extracción   │     │  Transformación │
│  PostgreSQL     │────▶│   SQL Optimizado│────▶│   Python ETL    │
│  Yahoo Finance  │     │   < 15 min      │     │   pandas        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                              ┌─────────────────┐      │
                              │   Almacenamiento│◄─────┘
                              │   Excel/CSV/   │
                              │   Parquet        │
                              └─────────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    ▼                  ▼                  ▼
            ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
            │  Análisis R │    │ Visualización│    │ Gobernanza  │
            │  VaR, Stats │    │ Power BI/   │    │ Git +       │
            │  RMarkdown  │    │ Tableau     │    │ Jupyter     │
            └─────────────┘    └─────────────┘    └─────────────┘
```

---

## Flujo de Trabajo Git

| Rama | Propósito | Reglas de Merge |
|------|-----------|-----------------|
| `main` | Código en producción | Solo desde `develop` vía PR aprobado por 2 revisores |
| `develop` | Integración de features | Desde cualquier `feature/*` vía PR con tests pasados |
| `feature/sql-optimizacion` | Índices y queries optimizadas | A `develop` cuando pase benchmark de performance |
| `feature/python-etl` | Migración Excel → Python | A `develop` cuando pase validación vs. Excel original |
| `feature/r-var` | Función VaR y reportes | A `develop` cuando benchmark con datos conocidos sea correcto |
| `hotfix/*` | Correcciones urgentes | Directo a `main` y luego merge a `develop` |

---

## Métricas de Éxito (KPIs)

| Métrica | Objetivo | Medición |
|---------|----------|----------|
| Tiempo total de ciclo | < 2 días hábiles | Días desde extracción hasta entrega |
| Tiempo de extracción SQL | < 15 minutos | EXPLAIN (ANALYZE) + timestamp |
| Reportes manuales | 0 | Conteo mensual |
| Errores reportados | < 1 por mes | Tickets de soporte |
| Cobertura de tests | > 80% | `pytest --cov` / `covr::package_coverage()` |
| Documentación reproducible | 100% | % de reportes con notebook/RMarkdown |

---

## Próximos Pasos

1. [ ] Reunión de kickoff con stakeholders del departamento financiero
2. [ ] Acceso a Data Warehouse y muestra representativa de datos
3. [ ] Obtener reporte Excel actual para análisis de migración
4. [ ] Definir cartera de prueba para cálculo de VaR
5. [ ] Configurar CI/CD básico en GitHub

---

## Licencia

Proyecto académico — Universidad Científica del Sur, 2026.
