@echo off
REM ACTUALIZAR_TODO.bat -- Pipeline completo de ABCD (Categoria D)
REM Corre todos los pasos en el orden correcto para regenerar data_d.json y
REM data_360.json desde cero. Requiere que ya existan en E:\ABCD:
REM   - "D para Alejandro.xlsx" en el Desktop del usuario (Excel del jefe)
REM   - "Stock sin venta 360 dias.xlsx" y "actualizar.xlsx" (locales, NO van a git)
REM No baja bodegas nuevas del SQL Server en vivo -- eso es manual y puntual
REM (ver CLAUDE.md "Refresco completo de las 26 bodegas"), este bat solo usa
REM lo que ya esta cacheado en E:\SQL\db\foviedo_local.db.
setlocal
set PY=E:\python-portable\python.exe
cd /d E:\ABCD

echo.
echo === 1/8 generar_data.py (base: Excel del jefe + SQL) ===
%PY% generar_data.py
if errorlevel 1 goto :error

echo.
echo === 2/8 agregar_stock_360.py (merge 428 nuevos + Centro Distribucion) ===
%PY% agregar_stock_360.py
if errorlevel 1 goto :error

echo.
echo === 3/8 agregar_abc.py (categoria A/B/C/D desde Excel) ===
%PY% agregar_abc.py
if errorlevel 1 goto :error

echo.
echo === 4/8 agregar_bodegas.py (Bodega Disp./Fisico real, Sala+Patio) ===
%PY% agregar_bodegas.py
if errorlevel 1 goto :error

echo.
echo === 5/8 agregar_costo.py (Costo Prom. real, con fallback entre bodegas) ===
%PY% agregar_costo.py
if errorlevel 1 goto :error

echo.
echo === 6/8 agregar_costo_actualizar_em.py (huecos El Manzano desde actualizar.xlsx) ===
%PY% agregar_costo_actualizar_em.py
if errorlevel 1 goto :error

echo.
echo === 7/8 recalcular_valorizado.py (Stock Valorizado = Costo x Disponible) ===
%PY% recalcular_valorizado.py
if errorlevel 1 goto :error

echo.
echo === 8/8 generar_data_360.py (pestana "Extracto 360 dias", solo SQL) ===
%PY% generar_data_360.py
if errorlevel 1 goto :error

echo.
echo === OK -- pipeline completo. Revisar la app en http://localhost:8090 ===
echo Recordatorio: data_d.json y data_360.json NO van a git (ver .gitignore).
goto :fin

:error
echo.
echo *** ERROR en un paso del pipeline -- revisar el mensaje de arriba ***
exit /b 1

:fin
endlocal
