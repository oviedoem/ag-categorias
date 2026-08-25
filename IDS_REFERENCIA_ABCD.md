# IDs de Referencia — App ABCD Foviedo

Generado: 2026-08-25 | Verificado contra SQLite `foviedo_local.db` y ERP.

---

## Sucursales (IDSUCURSAL en ERP)

| Tienda (Excel) | Código Sucursal | ID ERP |
|---|:---:|:---:|
| EL MANZANO | 04 | 04 |
| ISABEL RIQUELME | 02 | 02 |
| LAS CABRAS | 06 | 06 |
| SAN VICENTE | 05 | 05 |
| LITUECHE | 11 | 11 |

---

## Bodegas de Facturación (solo ventas reales)

Estas son las bodegas que se usan para calcular stock y ventas en la app.
Solo bodegas de **facturación** (PEM, SEM, etc.) — NO bodegas de tránsito ni merma.

### Isabel Riquelme (02)
| ID Bodega | Nombre / Tipo |
|:---:|---|
| 4 | Bodega principal IR |
| 86 | Bodega secundaria IR |

### El Manzano (04)
| ID Bodega | Nombre / Tipo |
|:---:|---|
| 13 | PEM — Principal El Manzano |
| 22 | SEM — Secundaria El Manzano |
| 24 | Bodega adicional EM |

### San Vicente (05)
| ID Bodega | Nombre / Tipo |
|:---:|---|
| 39 | Bodega SV 1 |
| 40 | Bodega SV 2 |
| 44 | Bodega SV 3 |

### Las Cabras (06)
| ID Bodega | Nombre / Tipo |
|:---:|---|
| 33 | PLC — Principal Las Cabras |
| 34 | SLC — Secundaria Las Cabras |
| 35 | CLC — Bodega adicional LC |

### Litueche (11)
| ID Bodega | Nombre / Tipo |
|:---:|---|
| 60 | Bodega LT 1 |
| 62 | Bodega LT 2 (tiene datos en r_stock_productos) |
| 78 | Bodega LT 3 |

---

## Tipos de Documento para Ventas

Solo estos documentos cuentan como **venta real** en el cálculo de última venta y rotación:

| tipo_doc | Descripción |
|:---:|---|
| BVE | Boleta de Venta |
| FVE | Factura de Venta |
| BVP | Boleta de Venta (variante) |
| FVP | Factura (variante) |

**Filtros adicionales obligatorios:**
- `estado NOT IN ('Nulo')` — excluir documentos anulados
- `neto > 0` — excluir devoluciones/negativos

---

## Ventanas de Rotación

Relativas a fecha base **2026-08-25**:

| Campo JSON | Periodo | Fecha desde |
|:---:|:---:|---|
| r3m | 3 meses | 2026-05-25 |
| r6m | 6 meses | 2026-02-25 |
| r12m | 12 meses | 2025-08-25 |
| r24m | 24 meses | 2024-08-25 |

> **Nota:** Los productos en esta app son categoría D = sin venta en año móvil.
> Por eso `r12m` siempre es 0. `r24m` captura ventas históricas de hace 1-2 años.

---

## Stock: Fuente de datos por sucursal

| Sucursal | Fuente stock en app | Notas |
|---|---|---|
| El Manzano | Excel del jefe (ERP) | r_stock_productos tiene bodegas 13,22,24 ✓ |
| Isabel Riquelme | Excel del jefe (ERP) | r_stock_productos NO tiene bodegas 4,86 |
| Las Cabras | Excel del jefe (ERP) | r_stock_productos NO tiene bodegas 33,34,35 |
| San Vicente | Excel del jefe (ERP) | r_stock_productos NO tiene bodegas 39,40,44 |
| Litueche | Excel del jefe (ERP) | r_stock_productos tiene bodega 62 parcial |

**Decisión:** Se usa `stock_disp` del Excel como fuente oficial para TODAS las sucursales,
ya que ese valor viene directo del ERP y es el mismo para todas las sucursales.

---

## Tablas SQLite usadas

| Tabla | Uso |
|---|---|
| `documentos` | Fecha, sucursal, tipo_doc, estado de cada documento |
| `documento_lineas` | Código interno, neto por línea de documento |
| `productos` | Mapeo `codigo_tecnico` ↔ `codigo` interno + subfamilia |
| `subfamilias` | Nombre de subfamilia (join por id_hiper + id_subfamilia) |
| `r_stock_productos` | Stock disponible por bodega (cobertura parcial) |

---

## Archivo Excel fuente

- **Nombre:** `D para Alejandro.xlsx` (escritorio)
- **Hoja:** `Hoja1`
- **Columnas (orden):** tienda, abc, cod_tec, desc, familia, marca, stock_xl, stock_val, vta_am, vta_costo_am, hiper
- **Universo:** productos con categoría D (sin venta año móvil, con stock)

---

## Script de regeneración

```
E:\python-portable\python.exe "E:\SQL\ABCD\generar_data.py"
```

Genera: `E:\SQL\ABCD\data_d.json` (5,757 productos, ~1.5 MB)
