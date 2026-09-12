# CLAUDE.md — Proyecto ABCD (Productos Categoría D)

Carpeta: `E:\ABCD\`
Repo GitHub: https://github.com/oviedoem/ag-categorias (público)
App pública: https://oviedoem.github.io/ag-categorias/
Última actualización: 2026-09-12 | v1.1

## REGLA FLUJO ACTUAL — leer al inicio de cada sesión

Revisar fechas de modificación de archivos en la raíz. Los más recientes marcan el flujo actual:
```powershell
Get-ChildItem "E:\ABCD" -File | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime | Select-Object -First 15
```

## PENDIENTE (sin corregir a pedido del usuario)
`generar_data.py` crashea en el último `print()` de éxito con `UnicodeEncodeError`
(carácter `✓`, consola cp1252) — fix conocido (`sys.stdout.reconfigure(encoding='utf-8')`)
pero el usuario pidió explícitamente NO aplicarlo. El script igual completa los 5 pasos
y escribe `data_d.json` antes de crashear — el crash es cosmético, no pierde datos.

## Propósito
Visualizar productos con categoría D (sin venta año móvil, con stock disponible)
de 6 sucursales (5 tiendas + Centro Distribución). Además incluye una segunda
pestaña ("Extracto 360 días") con un universo más chico pero 100% trazable a SQL.

## Pipeline de actualización — `ACTUALIZAR_TODO.bat`
Corre los 8 scripts en el orden correcto (ver el .bat para detalle de cada paso):
`generar_data.py → agregar_stock_360.py → agregar_abc.py → agregar_bodegas.py →
agregar_costo.py → agregar_costo_actualizar_em.py → recalcular_valorizado.py →
generar_data_360.py`. Requiere que ya existan localmente (ninguno va a git):
`C:\Users\alejandro\Desktop\D para Alejandro.xlsx`, `Stock sin venta 360 dias.xlsx`,
`actualizar.xlsx`. NO baja bodegas nuevas del SQL Server en vivo — eso es manual
y puntual (ver "Refresco de bodegas" más abajo), usa lo que ya está en
`E:\SQL\db\foviedo_local.db`.

## Archivos
| Archivo | Va a git | Descripción |
|---|:---:|---|
| `index.html` | ✅ | App completa: login SHA-256, filtros, gráficos, 2 pestañas |
| `ACTUALIZAR_TODO.bat` | ✅ | Pipeline completo, ver arriba |
| `AGENTS.md` | ✅ | Protocolo de cambios seguros |
| `CLAUDE.md` | ✅ | Este archivo |
| `IDS_REFERENCIA_ABCD.md` | ✅ | IDs de sucursales, bodegas, tablas SQLite |
| `.github/workflows/deploy.yml` | ✅ | CI/CD GitHub Pages automático |
| `data_d.json` | ❌ | Pestaña "Categoría D" — generado, contiene costo real, NUNCA al repo público |
| `data_360.json` | ❌ | Pestaña "Extracto 360 días" — generado, mismo motivo |
| `generar_data.py` y todos los `agregar_*.py` / `recalcular_*.py` | ❌ | Contienen rutas internas |
| `Stock sin venta 360 dias.xlsx`, `actualizar.xlsx` | ❌ | Excels fuente con datos de stock/costo interno |

## Fuentes de datos
- **Excel del jefe:** `C:\Users\alejandro\Desktop\D para Alejandro.xlsx` (Hoja1) —
  universo base, 5.757 productos, 100% categoría D confirmada.
- **`Stock sin venta 360 dias.xlsx`** (E:\ABCD, local) — reporte por bodega, 2.749
  filas / 7 "tiendas" (incluye Centro Distribución y Mercado Libre, mezcla
  categorías C y D). Fuente del merge de 428 códigos nuevos y de la pestaña
  "Extracto 360 días" completa.
- **`actualizar.xlsx`** (E:\ABCD, local) — export fresco del jefe, El Manzano +
  Centro Distribución, 10.026 códigos con costo real. Usado para rellenar 120
  códigos de El Manzano que no existen en la tabla `productos` de SQLite.
- **SQLite:** `E:\SQL\db\foviedo_local.db` (~2.15 GB, 2020-2026) — tablas
  `productos`, `marcas`, `familias`, `subfamilias`, `hiperfamilias`,
  `r_stock_productos`, `documentos`, `documento_lineas`.

## Sucursales y bodegas de facturación
Ver `IDS_REFERENCIA_ABCD.md` para detalle completo.

| Tienda | Suc ID | Bodegas facturación | Sala+Patio (para Bodega Disp./Físico) |
|---|:---:|---|---|
| EL MANZANO | 04 | 13, 22, 24 | 13 (Sala) + 22 (Patio) |
| ISABEL RIQUELME | 02 | 4, 86, 94 | 86 (Sala) + 94 (Patio Constructor Santiago) |
| LAS CABRAS | 06 | 33, 34, 35 | 33 (Sala) + 34 (Patio) |
| SAN VICENTE | 05 | 39, 40, 44 | 39 (Sala) + 40 (Patio) |
| LITUECHE | 11 | 60, 62, 78 | 62 (Sala) — 60/78 sin nombre confirmado |
| CENTRO DISTRIBUCION | 08 | 23 | 23 (única bodega) |

## Costo Prom. $ y Stock Valorizado
`Costo Prom. $` = dato real de `r_stock_productos.costopromediobodega`, con
**fallback global**: si la bodega Sala de la propia sucursal no tiene costo, se
usa el costo real de CUALQUIER otra bodega del sistema que sí lo tenga para ese
mismo código técnico (mismo producto = mismo costo de compra — dato real, nunca
inventado ni promediado). Con este fallback + `actualizar.xlsx` como respaldo
para El Manzano, **0 de 6.185 productos quedan sin costo** en `data_d.json` y
**0 de 2.326** en `data_360.json`.

`Stock Valorizado` = `Costo Prom. $ x Stock Disp.` (`recalcular_valorizado.py`),
calculado en Python — el HTML nunca hace esta cuenta, solo lee el campo ya
resuelto (a pedido explícito del usuario: "todo se baja de sqlite o sql server,
dato real, skill optimizar tokens").

## Pestaña "Extracto 360 días (solo SQL)"
Universo = SOLO los 2.326 códigos de `Stock sin venta 360 dias.xlsx` (sin
Mercado Libre, categorías C/D). Todo lo demás sale de SQLite, no del Excel:
descripción/marca/familia/subfamilia/hiperfamilia (join `productos`+`marcas`+
`hiperfamilias`+`familias`+`subfamilias`), Stock Disp./Bodega Físico/Costo Prom.
(suma de TODAS las bodegas del extracto por sucursal, cada una con su propio
costo real), última venta y rotación. Única excepción: la categoría ABC sigue
viniendo del Excel porque esa clasificación NO existe en ninguna tabla SQL
(`productos.categoria` es otra cosa — códigos '01'-'29', no A/B/C/D).

**Reconciliación final vs el Excel** ($191.724.122 sin Mercado Libre):
Total app $188.661.479 = **98,4%**. Por sucursal: Centro Distribución y San
Vicente ~100%, Litueche ~100%, Las Cabras 99%, El Manzano 99%, Isabel Riquelme
97%. La diferencia restante es desfase normal de sincronización SQL-Excel
(horas/días — ver skill `flujo-stock-erp`), no datos faltantes.

## Refresco de bodegas en `r_stock_productos` (manual, puntual)
El SQLite local no tenía cobertura completa de todas las bodegas usadas por
esta app. Se bajaron en vivo y solo lectura desde `Foviedo.dbo.R_STOCK_PRODUCTOS`
(pausas de 3s por bodega para no saturar el SQL Server ni bloquear IP) las 26
bodegas de facturación + extra: 13,22,24,4,86,94,33,34,35,39,40,44,60,62,78,23,
83,85,99,69,77,96,97,95,64,74. Se detectó que 5 de ellas (13,22,24,62,23) tenían
datos viejos de antes de esta sesión (ej. código AMS006 en bodega 13: 1 unidad
en el SQLite viejo vs 94 reales — verificado con `http://localhost:8934`,
herramienta de Análisis de Stock). Si vuelve a haber discrepancias grandes vs
un Excel fresco, repetir este refresco (script ad-hoc, no forma parte de
`ACTUALIZAR_TODO.bat` porque es lento — ~30-60 min — y no hace falta cada vez).

## Marca / diseño (2026-09-12)
La app dejó de usar el nombre/logo "Foviedo" — ahora es **"Sistemas A.G."**
(triángulo rojo con signo de exclamación, gradiente, `#brandGrad` en SVG
compartido). Fuente Inter (Google Fonts). Login con fondo animado (3 blobs
difuminados, `@keyframes float1/float2`, respeta `prefers-reduced-motion`).
El footer sigue diciendo "Ferretería Oviedo · Sistema interno" (atribución
interna, no logo de la app).

## Otras features
- **Gráficos**: por Sucursal (combo barras+línea), Top 10 Marcas, Top 10
  Familias — Chart.js vía CDN (`cdnjs.cloudflare.com/.../Chart.js/4.4.0/chart.umd.min.js`).
  Interactúan en tiempo real con todos los filtros. Toggle Valorizado $/Unidades.
- **Filtros**: Sucursal, Categoría (A/B/C/D, D preseleccionada por defecto),
  Stock (Con/Sin/Todos), Familia, Subfamilia, Marca, Última venta, búsqueda libre.
- Orden por defecto: Stock Disp. de mayor a menor.

## Para servir localmente
```powershell
E:\python-portable\python.exe -m http.server 8090 --directory "E:\ABCD"
# Abrir: http://localhost:8090
```

## Seguridad
- Login: usuario `rrojas`, hash SHA-256 embebido en `index.html`.
- ⚠️ **Incidente conocido, sin resolver a pedido del usuario:** la contraseña
  real quedó en texto plano en `AGENTS.md` entre el commit `9a199b1`
  (2026-08-25) y este cierre de sesión (2026-09-12) — ya removida del archivo
  actual, pero **sigue visible en el historial de git de un repo público**. El
  usuario decidió explícitamente no rotar la contraseña ni reescribir el
  historial. Cualquier sesión futura debe saber que este login no es
  confiable como "acceso restringido" real.
- `data_d.json` y `data_360.json` NUNCA van al repo — contienen costo real,
  no solo stock. Confirmado en `.gitignore` (`*.json`, `*.xlsx`, `*.xls`).
- Credenciales SQL: solo en `E:\config\credenciales_db.enc` (DPAPI) /
  `E:\ferreteria-oviedo\credenciales_db.ini`, nunca en archivos de este repo.
- Token GitHub: Windows Credential Manager (wincredman), nunca en archivos.

## Reglas
- Solo lectura contra SQL Server — nunca se modifican datos ahí, solo se lee
  (incluso al "bajar bodegas" es un SELECT, nunca INSERT/UPDATE en el ERP).
- `data_d.json` / `data_360.json` se regeneran completos cada vez — no editar a mano.
- La app es estática: `index.html` + los 2 JSON, sin backend.
- `*.py`, `*.json`, `*.xlsx` excluidos de git por `.gitignore`.
