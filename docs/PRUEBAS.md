# Plan y registro de pruebas

## Estado actual

Sesión 004: T00 y laboratorio físico T20–T23 comprobados con Godot 4.7.2. T10/T11 conservan comprobaciones de cámara y encuadre aprobado por el usuario en sesión 003. Golpes, parejas, reglas y partido continúan pendientes.

## Escenarios mínimos

| ID | Etapa | Escenario | Resultado a comprobar |
| --- | --- | --- | --- |
| T00 | E0 | Importar y ejecutar escena inicial | Sin errores del motor; piso y cámara visibles |
| T10 | E1 | Cuatro jugadores y pelota en extremos | Se distinguen y no quedan tapados |
| T11 | E1 | Globo y pelota junto al fondo cercano | Seguimiento visual posible en 16:9 y ventana pequeña |
| T20 | E2 | Caída vertical, impacto frontal y oblicuo | Respuesta consistente con parámetros fijados |
| T21 | E2 | Velocidad máxima contra piso/pared/red | Sin atravesar superficies ni quedar atrapada |
| T22 | E2 | Impacto cerca de esquina | Orden de contactos estable, sin doble conteo |
| T23 | E2 | Mismo lanzamiento a 30/60/120 FPS | Trayectorias equivalentes dentro de tolerancia fijada en P20 |
| T30 | E3 | Preparación temprana/tardía y fuera de alcance | Contacto o fallo comprensible; nunca golpe remoto |
| T31 | E3 | Mantener y soltar botón | Como máximo un impacto autorizado por golpe |
| T40 | E4 | Base/globo/remate/volea | Diferencias de altura, tiempo y destino observables |
| T50 | E5 | Pelota al medio de pareja | Receptor asignado y compañero cubriendo |
| T51 | E5 | Globo y rebote de fondo | Recuperación sin bloqueo recurrente |
| T60 | E6 | Piso rival → vidrio versus vidrio rival directo | Resultado conforme a regla confirmada; separar servicio/intercambio |
| T61 | E6 | Segundo pique sin devolución | Un solo fin de punto y marcador actualizado una vez |
| T62 | E6 | Saque, falta, doble falta y repetición | Transiciones según variante elegida en P60 |
| T63 | E6 | Partido y revancha | Termina y reinicia sin estado residual |
| T70 | E7 | Ejecutable fuera del editor | Inicia y permite completar partido |
| T80 | E8 | Táctil e interrupción en teléfono | Control cómodo y reanudación coherente |

Antes de automatizar reglas, consultar FIP y registrar la variante/simplificación adoptada. No tratar una hipótesis de esta tabla como reglamento ya implementado.

## Registro por ejecución

Fecha y responsable; ID del caso; versión del motor; revisión de código; escena/build; equipo; posición/velocidad inicial y semilla si aplica; entradas; esperado; observado; aprobado/fallido/pendiente; evidencia y siguiente acción. Unidades y tolerancias se fijan con la implementación.

Gravedad de fallos: impide jugar, altera reglas, dificulta control/lectura o detalle visual. Corregir primero los que impiden jugar y los que cambian el resultado del punto.

## Prueba de diversión

En E4 jugar sesiones breves y anotar: ¿se entiende por qué se falló?, ¿se puede dirigir el tiro?, ¿hay decisiones útiles?, ¿la cámara deja seguir la pelota?, ¿dan ganas de repetir? Requiere evaluación humana; no se demuestra con un test automático.


## Ejecución 27/10/2026 — sesión 002

Motor: 4.7.2.stable.official.ed1daf0bf. Escena: main.tscn, código de sesión 002, anterior al commit de cierre. Render: Compatibility sobre Mesa llvmpipe, sin medición válida de rendimiento objetivo.

- Importación: completada sin errores de scripts. El primer intento encontró directorios de usuario de solo lectura; resuelto guardando datos en `.local/` y usando modo portátil.
- T00: escena ejecutada con render y capturas PNG.
- T10/T11, componente geométrico: ocho extremos de cerramiento y 101 muestras de trayectoria por cámara y resolución; tres presets, 1280×720 y 640×360. Cero puntos fuera de cuadro. Margen de 6 px para la trayectoria.
- Diámetro visual mínimo de pelota: 5.47/4.87/5.73 px para cámaras 1/2/3 a 720p; 2.74/2.43/2.87 px a 360p. El radio visual está ampliado a 0.105 m; no es una pelota reglamentaria ni una decisión final.
- Control del laboratorio: alpha disminuye al atenuar cerramiento; Espacio cambia pausa; R vuelve a origen de trayectoria. Aprobados mediante ejecución de eventos del script.
- Evidencia: seis PNG y `previews/camera-checks.json`; vistas 1, 2 y ventana reducida inspeccionadas. No equivalen a una validación de oclusiones para todas las posiciones posibles.
- Pendiente: revisión del usuario y seguimiento cómodo en movimiento. Pruebas físicas y de reglas no ejecutadas.

Reproducir con los comandos de ENTORNO.md. Los JSON y capturas se sobrescriben al regenerarlos; registrar nuevas condiciones en la bitácora.


## Ejecución 27/10/2026 — sesión 003

Cambio: perfil lateral de rejas alto en los 2 m de cada extremo, con nivel central de 3 m, según variante de cristal FIP. Cámara sin cambios.

Importación completada sin errores de scripts; seis capturas regeneradas y vista principal inspeccionada: escalones de esquina visibles. Reejecutado camera_checks.gd en 720p/360p: cero puntos fuera de cuadro y lista de fallos vacía. No se añadieron pruebas de física porque no cambió ni existe aún ese sistema.

El primer intento de captura de esta sesión fue bloqueado por acceso al socket gráfico; tras conceder permiso de conexión local se repitió con éxito. Persisten los avisos de driver/Mesa ya conocidos.


## Ejecución 27/10/2026 — sesión 004: E2

Motor 4.7.2.stable.official.ed1daf0bf; revisión de trabajo de sesión 004, posterior a 15f9c20 y anterior al commit de cierre. Escena main.tscn; física 120 Hz, radio provisional 0.105 m, parámetros de LABORATORIO_PELOTA.md. Datos iniciales de todos los casos en tests/ball_checks.gd; sin azar.

**13 escenarios físicos:** caída vertical, vidrio de fondo, reja lateral, red, esquina de vidrio, tiro de 60 m/s, junta vidrio/reja, reja alta de esquina, salida por encima de reja, reposo durante 15 s, vidrio atenuado, vidrio opaco y relanzamiento repetido. Cero fallos. También se ejecutaron entradas Espacio/R/F4: pausa sin avance físico, reanudación, restablecimiento de estado y selección de escenario correctos.

- Caída vertical: un impacto en el primer segundo, a t≈0.768 s; dentro de 0.025 s del cálculo balístico independiente. Restitución vertical dentro de 0.001 del parámetro.
- Vidrio/reja: clasificación y cambio de dirección correctos. Red: bloquea tiro bajo y conserva pelota del lado de lanzamiento.
- Esquina: se invierten ambas componentes horizontales sin exceder presupuesto de impactos.
- Tiro rápido: no atraviesa cerramientos. La pelota por encima de la reja sí puede salir; no hay techo invisible.
- Sin penetración mayor de 0.002 m en los escenarios contenidos, contactos ordenados y energía saliente no superior a entrante por impacto (tolerancia 0.001 m/s).
- Reposo: sin nuevos contactos durante 240 pasos adicionales después de asentarse. Atenuación del vidrio y repetición no cambian posición final por más de 0.00001 m.

**Render programado:** tres procesos del motor con --fixed-fps 30/60/120, caso canónico de F2 durante 2 s. Se observaron 61/121/241 frames contando inicialización, con física a 120 Hz. tools/compare-fps.py confirmó posición, velocidad, tiempos y secuencia de contactos coincidentes dentro de 0.00001. JSON en previews/ball-fps-*.json y ball-fps-comparison.json. No es prueba de rendimiento real ni determinismo entre equipos.

**Regresión visual:** camera_checks.gd aprobado con su modo E1 aislado. Video de 120 frames a 30 FPS (4 s), PNG de laboratorio y revisión visual de la captura. Marcas de impacto/estela sin autoridad física. Mismo encuadre y geometría lateral.

**Limitaciones:** radio ampliado, restituciones de diseño, sin giro ni dispersión irregular de reja. Jugadores sin colisión. Accesos sin modelar. El test no cubre todas las posibles posiciones/velocidades ni reemplaza probar la sensación de juego.

**Incidencias corregidas:** el primer ejecutor de comparación de FPS intentaba leer la pelota antes de completar la carga de escena; se detuvo y corrigió la espera de inicialización. Las ejecuciones finales completaron sin errores de scripts. Los avisos Mesa/VSync conocidos no se usan como evidencia de rendimiento.


## Ejecución 27/10/2026 — sesión 005: calibración de superficies

Se reprodujo el F7 anterior: vidrio antes de piso, con velocidad de retorno que lo llevaba de vuelta al otro lado. Se corrigieron condiciones iniciales y amortiguación sin imponer límites artificiales al alcance.

- Pruebas físicas existentes: 13 casos, cero fallos con nuevos parámetros.
- `surface_calibration_checks.gd`: vidrio amortigua también componente tangencial; nuevo F7 cumple piso→vidrio→piso y no cruza Z=0 entre pared y segundo pique. En ese intervalo su Z máxima es aproximadamente -4.50 m.
- Reja: veinte semillas de tiro frontal, salidas dentro del semiespacio interior, energía no creciente y variación horizontal en ambos sentidos (aprox. -19.9° a +22.7°). Misma semilla repite dentro de 0.00001 m/m·s⁻¹; semillas 42 y 43 producen posiciones distintas en más de 0.01 m; N cambia semilla y relanza. Cero fallos.
- Comparación FPS actualizada al caso de reja F3/semilla 42: tres procesos a 30/60/120 FPS programados, resultados idénticos a 2 s dentro de tolerancia 0.00001. El informe reemplaza la captura numérica del caso F2 previo, conservado en historial Git.
- Los parámetros no son una validación de realismo deportivo. No se probaron efectos porque no hay giro implementado. La reja continúa como superficie sólida equivalente con perturbación de respuesta, no una simulación geométrica de alambres.

Evidencia numérica: `previews/surface-calibration.json`, `ball-checks.json` y `ball-fps-*.json`.


Capturas de sesión 005: importación y prueba de cámara sin errores de scripts; video F2 regenerado con calibración actual y comparación visual de reja (semillas 42/43). La Z máxima registrada hasta el paso del segundo pique del globo es -4.478 m; el contacto del segundo piso ocurre en Z≈-4.503 m.


## Ejecución 27/10/2026 — sesión 006: recorrido completo

Reproducido con física anterior (20e7267): F7 retorna 9.7476 m desde primer vidrio; veinte semillas F3 llegan a 9.7844 m desde reja y hasta 11.8415 m de camino horizontal. Esto muestra por qué el criterio previo de “segundo pique en lado rival” era insuficiente para el feedback del usuario.

Con fricción tangencial por impacto, desaceleración de rodadura y nuevos coeficientes: F7 retorna 1.9961 m; F3 máximo 4.2474 m, camino máximo 4.3466 m. Todos se detienen antes de 12 s. F2 (tiro bajo más rápido) retorna 8.0180 m y se detiene antes de la red; no se exige alcance de globo a ese tiro.

`travel_checks.gd`: 22 lanzamientos (F2, F7, veinte semillas F3), umbrales por caso, detención y prueba independiente v²/(2a) de rodadura a 3 m/s con tolerancia 0.03 m. Se verificó que después de reposo no hay deriva ni contactos nuevos. Cero fallos finales. El umbral inicial exploratorio de 7 m para F2 se revisó a 9 m porque es un tiro más rápido; F7/F3 tienen criterios separados y el modelo no incorpora estos límites.

Regresiones: 13 casos base y calibración de superficies aprobados; veinte semillas conservan desvío en ambos sentidos y energía no creciente. Comparación de reja a 30/60/120 FPS programados coincide a dos segundos; importación y cámara sin errores de scripts. Informes actualizados, más travel-checks.json y travel-comparison.json.

Los valores son una calibración de jugabilidad, no validación empírica de materiales. Continúa sin giro.


Videos de sesión 006 regenerados: F7 completo de ocho segundos, y reja con semillas 42/43 durante cuatro segundos por variante. Se inspeccionó el globo en vuelo y al final del video, detenido junto al fondo rival. Cámara conservada. Para iniciar el caso directamente: `./tools/run-godot.sh -- --scenario=7`.
