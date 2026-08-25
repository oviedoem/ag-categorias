# AGENTS.md — App ABCD Foviedo

## Qué hace esta app
Muestra los productos con categoría D (sin venta año móvil, con stock) de 5 sucursales.
Agrega la última fecha de venta histórica desde SQLite (2020–2026).

## Cómo actualizar datos
1. El jefe entrega nuevo Excel con productos D
2. Correr: `E:\python-portable\python.exe ABCD\generar_data.py`
3. El script genera `ABCD\data_d.json` automáticamente
4. Abrir `index.html` con servidor local (no doble clic — necesita fetch())

## Filtros disponibles en la app
- Sucursal (tienda)
- Familia
- Marca
- Última venta (sin registro / hasta 2024 / 2025 / 2026)
- Búsqueda libre (código o descripción)

## Exportar a Excel
Botón "⬇ Excel" genera CSV UTF-8 con BOM compatible con Excel chileno (separador ;)

## Columnas de última venta
- 🔴 Rojo = hasta 2023 (muy antiguo)
- 🟡 Amarillo = 2024
- 🟢 Verde = 2025–2026
- Gris itálica = Sin registro en BD histórica

## Safe-Change Protocol
ANTES de tocar cualquier archivo:
- TOCO: index.html o generar_data.py
- RAZÓN: cambio solicitado
- NO TOCO: data_d.json (generado), foviedo_local.db (solo lectura), otros proyectos

## Archivos en esta carpeta
| Archivo | Editable | Descripción |
|---|:---:|---|
| index.html | ✅ | App principal |
| data_d.json | ❌ | Generado por script |
| generar_data.py | ✅ | Script de regeneración |
| CLAUDE.md | ✅ | Instrucciones técnicas |
| AGENTS.md | ✅ | Este archivo |
