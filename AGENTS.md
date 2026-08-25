# AGENTS.md — App ABCD Foviedo

Última actualización: 2026-08-25 | Versión app: v1.0

## Qué hace esta app
Muestra los productos con categoría D (sin venta año móvil, con stock) de 5 sucursales.
Agrega la última fecha de venta histórica + rotación 3/6/12/24 meses desde SQLite (2020–2026).

## URL pública
https://oviedoem.github.io/ag-categorias/
Login: rrojas / categoriaD (hash SHA-256, no guardar contraseña en texto claro)

## Cómo actualizar datos
1. El jefe entrega nuevo Excel con productos D → guardar en `C:\Users\alejandro\Desktop\D para Alejandro.xlsx`
2. Correr: `E:\python-portable\python.exe "E:\SQL\ABCD\generar_data.py"`
3. El script genera `E:\SQL\ABCD\data_d.json` automáticamente
4. Commit y push: `git add data_d.json && git commit -m "data: actualizar D" && git push`

## Servidor local (prueba)
```
E:\python-portable\python.exe -m http.server 8090 --directory "E:\SQL\ABCD"
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
| data_d.json | ❌ | Generado por script (rastreado en git) |
| generar_data.py | ✅ | Script de regeneración (excluido de git) |
| IDS_REFERENCIA_ABCD.md | ✅ | IDs de sucursales, bodegas, tablas SQLite |
| CLAUDE.md | ✅ | Instrucciones técnicas del proyecto |
| AGENTS.md | ✅ | Este archivo |
| .github/workflows/deploy.yml | ❌ | Deploy automático a GitHub Pages |
