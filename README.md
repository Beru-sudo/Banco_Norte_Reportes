# Caso 3 — Automatización de Reportes Financieros · BancoNorte

> **Curso:** Introducción a Data Science
> **Institución:** Universidad Científica del Sur
> **Carrera:** Ingeniería Empresarial y de Sistemas
> **Año:** 2026

## Integrantes

| Nombre | Código |
|--------|--------|
| Sánchez Echevarría, Sebastian Alberto | 100159969 |
| Gómez Ccente, Lino Roy | 100162894 |
| [Integrante 3] | [Código] |
| [Integrante 4] | [Código] |
| [Integrante 5] | [Código] |

---

## Resumen del Proyecto

Este proyecto automatiza el pipeline de reportes financieros de BancoNorte, reduciendo el ciclo mensual de **15 días hábiles a menos de 2 días** (87% de reducción). La solución reemplaza procesos manuales en Excel por un stack tecnológico integrado que cubre extracción, transformación, análisis de riesgo, visualización y gobernanza de datos.

| Indicador | Antes | Después | Mejora |
|-----------|-------|---------|--------|
| Tiempo de ciclo de reportes | 15 días hábiles | < 2 días | 87% |
| Tiempo de extracción SQL | 3 horas | < 15 minutos | 92% |
| Reportes manuales mensuales | 40 | 0 | 100% automatizados |
| Tiempo de onboarding | 2 semanas | 2 días | 90% |

---

## Stack Tecnológico

| Capa | Herramienta | Función |
|------|-------------|---------|
| Extracción | PostgreSQL + SQL optimizado | Reducción de 3 horas a < 15 minutos |
| Transformación | Python (pandas, openpyxl) | Reemplazo de VLOOKUP y agregaciones manuales |
| Análisis de riesgo | R (tidyverse, quantmod, MASS) | Cálculo de VaR con 3 métodos estadísticos |
| Visualización | Power BI / Tableau | Dashboards interactivos para ejecutivos |
| Gobernanza | Git + Jupyter Notebooks | Control de versiones y documentación reproducible |

---

## Estructura del Repositorio

```
EC3-DataScience/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── Banco_Norte_Reportes/
│   │
│   ├── Data/
│   │   ├── raw/              # Datos originales (no versionados)
│   │   ├── processed/        # Reportes generados por el ETL
│   │   └── external/         # Datos de mercado (Yahoo Finance)
│   │
│   ├── Python/
│   │   ├── etl/
│   │   │   └── etl_pipeline.py       # Pipeline ETL principal
│   │   ├── reports/
│   │   └── tests/
│   │       └── test_etl.py           # Tests unitarios
│   │
│   ├── R/
│   │   ├── var/
│   │   │   └── var_calculator.R      # Función VaR (3 métodos)
│   │   ├── analysis/
│   │   └── reports/
│   │       └── reporte_var.Rmd       # Reporte reproducible
│   │
│   ├── SQL/
│   │   ├── queries/
│   │   │   └── reporte_mensual_optimizado.sql
│   │   ├── indexes/
│   │   │   └── create_indexes.sql
│   │   └── views/
│   │       └── create_materialized_views.sql
│   │
│   ├── Notebooks/
│   │   └── exploratory/
│   │       └── 01_analisis_exploratorio.ipynb
│   │
│   ├── Dashboards/
│   │   ├── powerbi/
│   │   └── tableau/
│   │
│   └── docs/
│       ├── architecture/
│       │   └── README.md
│       └── meeting_notes/
│           └── meeting_reuniones.md
```

---

## Instalación

### Requisitos previos

- Python 3.10+
- R 4.3+
- PostgreSQL 14+
- Git

### 1. Clonar el repositorio

```bash
git clone https://github.com/[usuario]/EC3-DataScience.git
cd EC3-DataScience
```

### 2. Instalar dependencias Python

```bash
pip install -r requirements.txt
```

### 3. Instalar paquetes R

```r
install.packages(c("tidyverse", "quantmod", "PerformanceAnalytics", 
                   "MASS", "rmarkdown", "knitr", "kableExtra"))
```

### 4. Configurar base de datos PostgreSQL

Ejecutar los scripts SQL en este orden:

```bash
# 1. Crear índices (sin bloquear tablas en producción)
psql -h [host] -U [usuario] -d banco_norte -f Banco_Norte_Reportes/SQL/indexes/create_indexes.sql

# 2. Crear vistas materializadas
psql -h [host] -U [usuario] -d banco_norte -f Banco_Norte_Reportes/SQL/views/create_materialized_views.sql
```

---

## Uso

### Tarea 1 — Pipeline ETL (Python)

Transforma el archivo Excel origen en un reporte estructurado con múltiples hojas y formato corporativo.

```bash
python Banco_Norte_Reportes/Python/etl/etl_pipeline.py \
  --input "Banco_Norte_Reportes/Data/raw/datos_banco_norte.xlsx" \
  --output "Banco_Norte_Reportes/Data/processed/" \
  --validate
```

El reporte de salida aparece en `Data/processed/` con el nombre `reporte_automatizado_YYYYMMDD_HHMMSS.xlsx` e incluye las hojas: `Datos_Transformados`, `Resumen_Categoria`, `Resumen_Mensual`, `Resumen_Segmento` y `Metadata`.

**Ejecutar tests unitarios:**

```bash
pytest Banco_Norte_Reportes/Python/tests/test_etl.py -v
```

### Tarea 2 — Análisis de Riesgo VaR (R)

Calcula el Value at Risk de una cartera usando tres métodos estadísticos: paramétrico, histórico y Monte Carlo.

```r
source("Banco_Norte_Reportes/R/var/var_calculator.R")

resultado <- calcular_var(
  tickers    = c("AAPL", "MSFT", "GOOGL", "AMZN", "TSLA"),
  weights    = c(0.25, 0.25, 0.20, 0.20, 0.10),
  confidence = 0.95,
  method     = "parametric"   # "parametric" | "historical" | "montecarlo"
)
```

**Compilar reporte RMarkdown:**

```r
rmarkdown::render("Banco_Norte_Reportes/R/reports/reporte_var.Rmd")
```

Genera un reporte HTML con tabla de contenidos flotante, matriz de correlación, histogramas de retornos y comparación de los tres métodos VaR.

### Tarea 3 — Optimización SQL

Reduce el tiempo de extracción de 3 horas a menos de 15 minutos mediante índices B-Tree, vistas materializadas y CTEs con extracción incremental.

```sql
-- Ejecutar reporte mensual optimizado
\timing on
\i Banco_Norte_Reportes/SQL/queries/reporte_mensual_optimizado.sql

-- Refrescar vistas materializadas manualmente
SELECT * FROM refrescar_vistas_materializadas();
```

---

## Arquitectura de la Solución

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│    Fuentes       │     │   Extracción     │     │  Transformación  │
│  PostgreSQL DW   │────▶│  SQL Optimizado  │────▶│  Python ETL      │
│  Yahoo Finance   │     │  < 15 minutos    │     │  pandas          │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                                          │
                          ┌──────────────────┐           │
                          │  Almacenamiento  │◄──────────┘
                          │  Excel / CSV     │
                          └──────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
      ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
      │  Análisis R  │    │ Visualización│    │  Gobernanza  │
      │  VaR, Stats  │    │ Power BI /   │    │  Git +       │
      │  RMarkdown   │    │ Tableau      │    │  Jupyter     │
      └──────────────┘    └──────────────┘    └──────────────┘
```

---

## Distribución de Responsabilidades

| Integrante | Tarea principal |
|------------|----------------|
| Sánchez Echevarría, Sebastian Alberto | Tarea 3 (SQL) + Infraestructura Git |
| Gómez Ccente, Lino Roy | Tarea 2 (VaR en R) + Documentación RMarkdown |
| Quispe Huaman Henry | Tarea 1 (Python ETL) + Tests unitarios |
| Teves Paniura Lucio Raymundo | Dashboards Power BI + Visualización ejecutiva |
| Salaz Jimenez Angel David | Jupyter Notebooks + Documentación reproducible |

---

## Métricas de Éxito

| Métrica | Objetivo | Cómo medir |
|---------|----------|------------|
| Tiempo de ciclo total | < 2 días hábiles | Timestamp inicio → entrega |
| Tiempo extracción SQL | < 15 minutos | `EXPLAIN (ANALYZE, BUFFERS)` |
| Cobertura de tests Python | > 80% | `pytest --cov` |
| Reportes manuales | 0 | Conteo mensual |
| Errores en producción | < 1 por mes | Tickets de soporte |

---

## Notas Técnicas

- **Python 3.12+ / pandas 2.2+:** las frecuencias de `pd.date_range` cambiaron de mayúsculas a minúsculas (`'H'` → `'h'`, `'M'` → `'ME'`). El código ya está corregido para estas versiones.
- **Vistas materializadas:** requieren índice único para poder usar `REFRESH CONCURRENTLY` sin bloquear lecturas.
- **VaR:** la descarga de precios vía `quantmod::getSymbols()` requiere conexión a internet. Los resultados pueden variar según el periodo de datos disponible en Yahoo Finance.
- **Data/raw y Data/processed** están en `.gitignore` para no versionar datos financieros sensibles.

---

## Licencia

Proyecto académico — Universidad Científica del Sur, 2026.