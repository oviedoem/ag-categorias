# AGENTS.md — App ABCD Sistemas A.G.

Última actualización: 2026-11-24 | versión documental 1.2

## Qué hace esta app
Muestra los productos con categoría D (sin venta año móvil, con stock) de 5 sucursales.
Agrega la última fecha de venta histórica + rotación 3/6/12/24 meses desde SQLite (2020–2026).

## URL pública
https://oviedoem.github.io/ag-categorias/
Login: usuario `rrojas` (hash SHA-256 embebido en index.html — la contraseña real NUNCA se guarda en archivos de texto, ver CLAUDE.md)

## Fuente de datos y Excel base
- E:\ABCD\D para Alejandro.xlsx es el Excel base del jefe. Se entrega una vez por diseño; no se espera un Excel nuevo en cada corrida.
- E:\ABCD\Stock sin venta 360 dias.xlsx y E:\ABCD\actualizar.xlsx son fuentes locales auxiliares.
- E:\SQL\db\foviedo_local.db es la fuente SQLite de stock, bodegas, descripciones, costos, ventas y rotación. ABCD no consulta el ERP en vivo.
- El Excel de categoría ABC es la excepción: esa clasificación proviene del Excel porque no existe en SQLite.
- No leer, modificar ni imprimir credenciales. No editar manualmente los JSON generados.

## Pipeline vigente
Ejecutar solo desde el Centro de Control, después de que SQL haya terminado su sincronización.

E:\ABCD\ACTUALIZAR_TODO.bat

1. generar_data.py — genera data_d.json desde el Excel base y SQLite.
2. agregar_stock_360.py — incorpora el universo de 360 días y Centro de Distribución.
3. agregar_abc.py — agrega categoría A/B/C/D desde el Excel base.
4. agregar_bodegas.py — agrega disponible/físico por bodega.
5. agregar_costo.py — agrega costo promedio real con fallback entre bodegas.
6. agregar_costo_actualizar_em.py — completa huecos de El Manzano desde actualizar.xlsx.
7. recalcular_valorizado.py — calcula costo por disponible.
8. generar_data_360.py — genera data_360.json desde SQLite.

El BAT aborta ante un error de cualquier paso y luego llama a scripts\PUBLICAR_DATOS.bat. El pipeline usa CRLF; no convertirlo a LF porque las etiquetas y goto pueden fallar.

## Publicación
scripts\PUBLICAR_DATOS.bat valida la cuenta Git ferreteriaoviedo.elmanzano@gmail.com, el remoto oviedoem/ag-categorias y que ambos JSON sean válidos y de la fecha esperada. Si hay cambios, hace commit/push solo de data_d.json y data_360.json; GitHub Pages publica desde main y el script espera que los datos públicos coincidan con los locales.

Los JSON están versionados deliberadamente desde el 13-09-2026 porque el repositorio y GitHub Pages son públicos por decisión del dueño. Los Excel fuente no se publican.

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

## Blindaje y cambios seguros
Verificación de solo lectura:

`E:\python-portable\python.exe -I E:\ABCD\scripts\verificar_blindaje.py`

No usar `--guardar` sin orden expresa del dueño. Antes de tocar un archivo declarar TOCO / ARCHIVO / RAZÓN / NO TOCO, respaldar el archivo y no modificar SQLite ni otros proyectos.

Los ocho scripts Python configuran la salida con `errors="replace"` para que el carácter ✓ no rompa el pipeline con `UnicodeEncodeError` cuando la salida está redirigida.

## Archivos en esta carpeta
| Archivo | Editable | Descripción |
|---|:---:|---|
| index.html | ✅ | App principal con login embebido |
| data_d.json | ✅ | Datos generados de Categoría D, versionados y publicados |
| generar_data.py | ✅ | Paso 1 del pipeline |
| data_360.json | ✅ | Datos generados del Extracto 360 días, versionados y publicados |
| generar_data_360.py | ✅ | Paso 8 del pipeline |
| agregar_stock_360.py | ✅ | Merge del universo de 360 días |
| agregar_bodegas.py | ✅ | Desglose de disponible/físico |
| agregar_costo.py | ✅ | Costo promedio real |
| agregar_abc.py | ✅ | Categoría ABC desde Excel |
| recalcular_valorizado.py | ✅ | Stock valorizado = costo x disponible |
| agregar_costo_actualizar_em.py | ✅ | Completa datos de El Manzano |
| actualizar.xlsx | ❌ | Fuente local auxiliar, no se publica |
| D para Alejandro.xlsx | ❌ | Excel base único del jefe, no se publica |
| Stock sin venta 360 dias.xlsx | ❌ | Fuente local auxiliar, no se publica |
| IDS_REFERENCIA_ABCD.md | ✅ | IDs de sucursales, bodegas y tablas SQLite |
| CLAUDE.md | ✅ | Instrucciones técnicas e historial |
| AGENTS.md | ✅ | Esta guía operativa |
| scripts\PUBLICAR_DATOS.bat | ✅ | Validación y publicación de JSON |
| scripts\verificar_blindaje.py | ✅ | Auditoría de integridad |
