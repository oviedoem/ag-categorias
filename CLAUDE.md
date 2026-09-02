# CLAUDE.md — Proyecto ABCD (Productos Categoría D)

Carpeta: `E:\ABCD\`
Repo GitHub: https://github.com/oviedoem/ag-categorias
App pública: https://oviedoem.github.io/ag-categorias/
Última actualización: 2026-08-25 | v1.0

## REGLA FLUJO ACTUAL — leer al inicio de cada sesión

Revisar fechas de modificación de archivos en la raíz. Los más recientes marcan el flujo actual:
```powershell
Get-ChildItem "E:\ABCD" -File | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime | Select-Object -First 15
```
Un `.py`, `.json` o `.html` con fecha reciente puede indicar pipeline nuevo no documentado aún.

## Propósito
Visualizar productos con categoría D (sin venta año móvil, con stock disponible)
de 5 sucursales. Muestra última fecha de venta histórica + rotación 3/6/12/24 meses.

## Archivos
- `index.html` — App web completa con login SHA-256 (dark theme, estilo Foviedo)
- `data_d.json` — Datos generados por script Python (NO editar a mano, SÍ en git)
- `generar_data.py` — Script Python de regeneración (excluido de git por .gitignore)
- `IDS_REFERENCIA_ABCD.md` — IDs de sucursales, bodegas, tablas SQLite
- `AGENTS.md` — Protocolo de cambios seguros
- `CLAUDE.md` — Este archivo
- `.github/workflows/deploy.yml` — CI/CD GitHub Pages automático

## Fuente de datos
- **Excel:** `C:\Users\alejandro\Desktop\D para Alejandro.xlsx` (Hoja1)
  Columnas: Tienda, ABC, Codigo, Descripcion, Familia, Marca, Stock disp,
  Stock val, Vta AM, Vta Costo AM, HiperFamilia
- **SQLite:** `E:\SQL\db\foviedo_local.db` (1.89 GB, 2020-2026)
  Join: `productos.codigo_tecnico → productos.codigo → documento_lineas.codigo`

## Para regenerar data_d.json
```powershell
E:\python-portable\python.exe "E:\ABCD\generar_data.py"
```
Luego: `git add data_d.json && git commit -m "data: actualizar D" && git push`

## Para servir localmente
```powershell
E:\python-portable\python.exe -m http.server 8090 --directory "E:\ABCD"
# Abrir: http://localhost:8090
```

## Sucursales y bodegas de facturación
Ver `IDS_REFERENCIA_ABCD.md` para detalle completo.

| Tienda | Suc ID | Bodegas facturación |
|---|:---:|---|
| EL MANZANO | 04 | 13, 22, 24 |
| ISABEL RIQUELME | 02 | 4, 86 |
| LAS CABRAS | 06 | 33, 34, 35 |
| SAN VICENTE | 05 | 39, 40, 44 |
| LITUECHE | 11 | 60, 62, 78 |

## Seguridad
- Login: usuario `rrojas`, hash SHA-256 embebido en index.html (no contraseña en texto)
- data_d.json es público en GitHub (sin datos de precios costo ni RUT)
- Credenciales SQL: solo en scripts locales, NUNCA en archivos del repo
- Token GitHub: Windows Credential Manager (wincredman), nunca en archivos

## Reglas
- Solo lectura — no modificar datos en SQL Server ni SQLite
- data_d.json se regenera completo cada vez (no editar a mano)
- La app es estática: index.html + data_d.json, sin backend
- `*.py` excluidos de git por .gitignore (contienen rutas internas)
