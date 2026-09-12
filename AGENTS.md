# AGENTS.md — App ABCD Sistemas A.G.

Última actualización: 2026-08-25 | Versión app: v1.0

## Qué hace esta app
Muestra los productos con categoría D (sin venta año móvil, con stock) de 5 sucursales.
Agrega la última fecha de venta histórica + rotación 3/6/12/24 meses desde SQLite (2020–2026).

## URL pública
https://oviedoem.github.io/ag-categorias/
Login: usuario `rrojas` (hash SHA-256 embebido en index.html — la contraseña real NUNCA se guarda en archivos de texto, ver CLAUDE.md)

## Cómo actualizar datos
1. El jefe entrega nuevo Excel con productos D → guardar en `C:\Users\alejandro\Desktop\D para Alejandro.xlsx`
2. Correr: `E:\python-portable\python.exe "E:\ABCD\generar_data.py"`
3. El script genera `E:\ABCD\data_d.json` automáticamente
4. `data_d.json` NO va a git (ver `.gitignore` — removido por seguridad, contiene datos de stock ERP). Solo commitear si se toca `index.html` u otro archivo trackeado.

## Servidor local (prueba)
```
E:\python-portable\python.exe -m http.server 8090 --directory "E:\ABCD"
```
Abrir: http://localhost:8090

## Filtros disponibles en la app
- Sucursal, Familia, Subfamilia, Marca
- Última venta (sin registro / hasta 2024 / 2025 / 2026)
- Búsqueda libre (código o descripción)

## Columnas de rotación
- Rot. 3M / 6M / 12M / 24M = neto vendido en ese periodo (en CLP)
- Para productos D: r12m siempre es 0 (por definición). r24m muestra ventas históricas.

## Exportar a Excel
Botón "⬇ Excel" genera CSV UTF-8 con BOM compatible con Excel chileno (separador ;)

## Columnas de última venta
- Rojo = hasta 2023 (muy antiguo)
- Amarillo = 2024
- Verde = 2025–2026
- Gris itálica = Sin registro en BD histórica

## Safe-Change Protocol
ANTES de tocar cualquier archivo:
- TOCO: index.html o generar_data.py
- RAZÓN: cambio solicitado
- NO TOCO: data_d.json (generado), foviedo_local.db (solo lectura), otros proyectos

## Archivos en esta carpeta
| Archivo | Editable | Descripción |
|---|:---:|---|
| index.html | ✅ | App principal con login embebido |
| data_d.json | ❌ | Generado por script (NO va a git, ver .gitignore) |
| generar_data.py | ✅ | Script de regeneración (excluido de git) |
| data_360.json | ❌ | Pestaña "Extracto 360 días" — generado por script (NO va a git) |
| generar_data_360.py | ✅ | Regenera data_360.json (excluido de git) |
| agregar_stock_360.py | ✅ | Merge puntual 2026-09-12 (excluido de git) |
| agregar_bodegas.py | ✅ | Agrega desglose Bodega Disp./Físico (excluido de git) |
| agregar_costo.py | ✅ | Agrega Costo Prom. real (excluido de git) |
| agregar_abc.py | ✅ | Agrega categoría ABC (excluido de git) |
| recalcular_valorizado.py | ✅ | Recalcula Stock Valorizado = Costo x Disp (excluido de git) |
| agregar_costo_actualizar_em.py | ✅ | Rellena costo/desc de El Manzano desde actualizar.xlsx (excluido de git) |
| actualizar.xlsx | ❌ | Export fresco del jefe, El Manzano + CD (NO va a git) |
| IDS_REFERENCIA_ABCD.md | ✅ | IDs de sucursales, bodegas, tablas SQLite |
| CLAUDE.md | ✅ | Instrucciones técnicas del proyecto |
| AGENTS.md | ✅ | Este archivo |
| .github/workflows/deploy.yml | ❌ | Deploy automático a GitHub Pages |
