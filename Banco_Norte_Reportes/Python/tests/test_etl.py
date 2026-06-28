"""
========================================
TESTS UNITARIOS - ETL PIPELINE
           BancoNorte
========================================
"""

import pytest
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import sys
from pathlib import Path

# Agregar ruta del ETL
sys.path.insert(0, str(Path(__file__).parent.parent / "etl"))

try:
    from etl_pipeline import transformar_datos, calcular_agregaciones
except ImportError:
    print("ERROR: No se pudo importar etl_pipeline.py")
    print(f"Buscando en: {Path(__file__).parent.parent / 'etl'}")
    sys.exit(1)


# ============================================
#        FIXTURES (datos de prueba)
# ============================================

@pytest.fixture
def sample_data():
    """Crea datos de prueba simulados."""
    np.random.seed(42)
    n = 1000
    
    return {
        'Datos': pd.DataFrame({
            'ID_TRANSACCION': range(1, n+1),
            'ID_CLIENTE': np.random.choice(['C001', 'C002', 'C003', 'C004', 'C005'], n),
            'ID_PRODUCTO': np.random.choice(['P001', 'P002', 'P003'], n),
            'FECHA': pd.date_range('2024-01-01', periods=n, freq="h"),
            'MONTO': np.random.uniform(100, 10000, n),
            'COMISION': np.random.uniform(1, 50, n),
            'ESTADO': np.random.choice(['ACTIVO', 'ANULADA'], n, p=[0.95, 0.05])
        }),
        'Clientes': pd.DataFrame({
            'ID_CLIENTE': ['C001', 'C002', 'C003', 'C004', 'C005'],
            'NOMBRE_CLIENTE': ['Cliente A', 'Cliente B', 'Cliente C', 'Cliente D', 'Cliente E'],
            'SEGMENTO': ['Premium', 'Standard', 'Premium', 'Standard', 'VIP'],
            'REGION': ['Norte', 'Sur', 'Este', 'Oeste', 'Norte']
        }),
        'Productos': pd.DataFrame({
            'ID_PRODUCTO': ['P001', 'P002', 'P003'],
            'NOMBRE_PRODUCTO': ['Producto X', 'Producto Y', 'Producto Z'],
            'CATEGORIA': ['A', 'B', 'A']
        })
    }


# ============================================
#             TESTS DE EXTRACCION
# ============================================

class TestExtraccion:
    """Tests para la fase de extraccion."""
    
    def test_hojas_esperadas(self, sample_data):
        """Verifica que existen las hojas minimas."""
        assert 'Datos' in sample_data
        assert 'Clientes' in sample_data
        assert 'Productos' in sample_data
    
    def test_dimensiones_datos(self, sample_data):
        """Verifica dimensiones de los datos."""
        assert len(sample_data['Datos']) == 1000
        assert len(sample_data['Clientes']) == 5
        assert len(sample_data['Productos']) == 3


# ============================================
#             TESTS DE TRANSFORMACION
# ============================================

class TestTransformacion:
    """Tests para la fase de transformacion."""
    
    def test_merge_clientes(self, sample_data):
        """Verifica que el merge con clientes funciona."""
        result = transformar_datos(sample_data)
        assert 'NOMBRE_CLIENTE' in result.columns
        assert 'SEGMENTO' in result.columns
        assert result['NOMBRE_CLIENTE'].notna().sum() > 0
    
    def test_merge_productos(self, sample_data):
        """Verifica que el merge con productos funciona."""
        result = transformar_datos(sample_data)
        assert 'NOMBRE_PRODUCTO' in result.columns
        assert 'CATEGORIA' in result.columns
    
    def test_feature_engineering(self, sample_data):
        """Verifica que se crearon las columnas derivadas."""
        result = transformar_datos(sample_data)
        assert 'AÑO' in result.columns
        assert 'MES' in result.columns
        assert 'TRIMESTRE' in result.columns
        assert 'MONTO_COMISION' in result.columns
    
    def test_no_perdida_registros(self, sample_data):
        """Verifica que no se pierden registros validos."""
        result = transformar_datos(sample_data)
        assert len(result) >= len(sample_data['Datos']) * 0.9


# ============================================
#           TESTS DE AGREGACIONES
# ============================================

class TestAgregaciones:
    """Tests para la fase de agregaciones."""
    
    def test_resumen_categoria(self, sample_data):
        """Verifica agregacion por categoria."""
        df = transformar_datos(sample_data)
        res_cat, _, _ = calcular_agregaciones(df)
        
        assert len(res_cat) > 0
        assert 'TOTAL_MONTO' in res_cat.columns
        assert res_cat['TOTAL_MONTO'].sum() > 0
    
    def test_resumen_mensual(self, sample_data):
        """Verifica agregacion mensual."""
        df = transformar_datos(sample_data)
        _, res_mes, _ = calcular_agregaciones(df)
        
        assert len(res_mes) > 0
        assert any('A' in col or 'B' in col for col in res_mes.columns)


# ============================================
#              TESTS DE RENDIMIENTO
# ============================================

class TestRendimiento:
    """Tests de performance."""
    
    def test_tiempo_transformacion(self, sample_data):
        """Verifica que la transformacion toma menos de 5 segundos."""
        import time
        start = time.time()
        transformar_datos(sample_data)
        duration = time.time() - start
        assert duration < 5, f"Transformacion tomo {duration:.2f}s, maximo 5s"


# ============================================
#                  EJECUCION
# ============================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])