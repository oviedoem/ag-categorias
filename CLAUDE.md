# CLAUDE.md — Proyecto ABCD (Productos Categoría D)

Carpeta: `E:\SQL\ABCD\`
App standalone: `index.html` (requiere `data_d.json` en misma carpeta)

## Propósito
Visualizar productos con categoría D (sin venta año móvil, con stock disponible)
por sucursal, con última fecha de venta histórica.

## Archivos
- `index.html` — App web (dark theme, estilo Foviedo)
- `data_d.json` — Datos generados por script Python (NO editar a mano)
- `AGENTS.md` — Reglas de agente
- `CLAUDE.md` — Este archivo

## Fuente de datos
- Excel origen: `C:\Users\alejandro\Desktop\D para Alejandro.xlsx`
  Columnas: Tienda, ABC, Codigo producto, Descripcion, Familia, Marca,
  Stock disponible, Stock valorizado, Venta año movil, Venta Costo año movil, HIPERFAMILIA
- Última venta: `E:\SQL\db\foviedo_local.db` tabla `documentos` + `documento_lineas`
  Join via `productos.codigo_tecnico → productos.codigo → documento_lineas.codigo`

## Para regenerar data_d.json
```powershell
cd E:\SQL
E:\python-portable\python.exe ABCD\generar_data.py
```

## Para servir localmente (ver en browser)
```powershell
cd E:\SQL\ABCD
E:\python-portable\python.exe -m http.server 8090
# Abrir: http://localhost:8090
```

## Sucursales mapeadas
| Excel Tienda    | SQLite sucursal |
|----------------|:---:|
| EL MANZANO     | 04  |
| ISABEL RIQUELME| 02  |
| LAS CABRAS     | 06  |
| LITUECHE       | 11  |
| SAN VICENTE    | 05  |

## Reglas
- Solo lectura — no modificar datos en SQL Server ni SQLite
- data_d.json se regenera completo cada vez
- La app es estática: index.html + data_d.json, sin backend
