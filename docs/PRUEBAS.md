# Plan y registro de pruebas

## Estado actual

Sesión 012: usuario acepta sensación de E3/P34 tras probar versión con riesgo de red. Presentación provisional de golpe/audio implementada y comprobada técnicamente; su valoración humana sigue pendiente. E2 conserva sus regresiones aprobadas. Parejas, reglas y partido continúan pendientes.

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


## Ejecución 27/10/2026 — sesión 007: jugador y primer golpe

Motor 4.7.2.stable.official.ed1daf0bf; código posterior a 9d03459, anterior al commit de cierre. Física 120 Hz, mismos parámetros de E2.

**Entrada y movimiento:** acciones de teclado y botón A sintético identificadas; adaptador recibe acción de movimiento. En un segundo, cardinal 4.68055 m y diagonal 4.68054 m (tolerancia 0.03 m). Límites propios comprobados en cuatro direcciones. La prueba inicial expuso dependencia del delta implícito de move_and_slide al llamarlo fuera del callback; se cambió el motor a barridos con delta explícito, que se usan igual en runtime y pruebas.

**Golpe:** fuera de alcance no cambia pelota; ventana expirada no golpea una pelota que llega después; preparación de 0.025 s rechazada; pelota a 3 m rechazada. Contacto válido registra último golpeador y una sola strike, sin mover posición ni reiniciar reloj/RNG. No se permite segundo contacto del mismo jugador en la misma alimentación.

**90 trayectorias físicas:** posiciones Z=0.7/5/9 m; alturas 0.3/0.9/1.8 m; direcciones lateral izquierda/centro/derecha y profundidad corta/larga; potencias 0.2/1. Ninguna tocó red y el primer piso fue rival, a menos de 0.4 m del destino (máximo observado ≈0.00018 m, válido solo para el modelo actual). No es validación de realismo de un tiro deportivo.

**Integración:** conductor automático de 30 s, diez alimentaciones en tres zonas, diez contactos. Pausa congela jugador/pelota; reanudación funciona incluso al pausar antes del primer paso del lanzamiento. Pérdida de foco pausa y P reanuda. F8 aísla modos y vuelve con pelota esperando. Panel dentro de viewport en 720p/360p.

**Eventos y captura:** grabación de seis segundos con Input.parse_input_event/Input.action_press, dos intentos y dos contactos. Se inspeccionaron captura 720p y captura compacta 640×360; el panel inicial reducido se compactó para dejar visible la cancha. Son eventos sintéticos, no un ensayo humano ni de mando físico.

**Regresiones E2:** 13 casos de pelota, veinte semillas de calibración y recorrido completo aprobados. Se mantienen 2.00 m de retorno del globo y máximo 4.25 m de reja de esos fixtures. Comparación de caso de reja a 30/60/120 FPS programados coincide tras dos segundos; cámara aprobada de E1 conservada.

**Informe:** previews/player-checks.json. Comando de reproducción en PRACTICA.md. Sigue pendiente P34 con el usuario. Sin giro, golpes avanzados, rivales ni partido.


## Sesión 010 — 28/10/2026: controles de preparación automática

Motor 4.7.2.stable.official.ed1daf0bf, estado de trabajo de sesión 010; física 120 Hz. `player_checks.gd` aprobado: carga aproximadamente 90% fijada conserva valor tras 0.4 s; llegada a distancia 0.65 m/altura 0.9 produce tiro perfecto; cambiar dirección tras fijar modifica destino. Defensa de un tick devuelve con menos potencia y dirección limitada. Frenado desde carrera detiene en menos de 0.25 m; apuntado plantado no desplaza. Cancelación, caducidad, altura, contacto mientras mantiene, sin repetición y conservación de posición/reloj/RNG aprobados. Prueba de pausa/foco/F8 e interfaz conserva aprobación.

Dos escenarios deterministas: jugador (0,0,6.8), pelota (1.1,0.3,6.8), preparación 0.02 s y carga 1.0, direcciones adelante/derecha. Se calcula salida y simula hasta primer contacto: vidrio/reja antes del piso en ambos casos. No se declara cobertura de todos los ángulos/alturas ni arbitraje implementado. Informe `previews/player-checks.json` incluye potencia preparada/defensiva y primeras superficies.

90 trayectorias de ayuda nominal (sin aplicar sobrecarga al objetivo de esas pruebas) pasan red y aterrizan a menos de 0.4 m del destino. Integración sintética de 30 s: diez contactos en tres zonas. Captura real de seis segundos con eventos de teclado/action: dos contactos. Interfaz 1280×720 y 640×360 renderizada e inspeccionada. Mesa llvmpipe; sin validación de rendimiento o mando físico ni prueba humana de diversión.

Regresiones ejecutadas: ball_checks (13 escenarios), surface_calibration_checks (veinte semillas) y travel_checks (22 recorridos), todas aprobadas. Retornos globo 2.00 m/reja máximo 4.25 m. Importación editor sin errores de scripts tras corregir inferencia bool. Sin cambios en simulación pasiva; no repetida comparación FPS anterior.


## Sesión 011 — 28/10/2026: sobrecarga hacia abajo

Godot 4.7.2.stable.official.ed1daf0bf, paso 1/120 s. Jugador (0,0,6.8), pelota (1.1,0.3,6.8), preparación 0.02 s, dirección abajo. Dos cargas: 0.9 y 1.0. Se entra en LOCKED con contacto válido y se ejecuta `step`, luego se simula pelota hasta primer contacto. Esperado/observado: 90% → piso rival; 100% → red. Resultado reproducible sin RNG del golpe; registro en previews/player-checks.json. La asistencia nominal no anula el aplanamiento del arco.

`player_checks.gd`: dos casos nuevos, casos de fondo/lateral anteriores, 90 trayectorias nominales, diez contactos en 30 s y comprobaciones de control aprobadas. `ball_checks.gd`: 13 escenarios aprobados. Importación sin errores de scripts (avisos de puertos bloqueados por sandbox). No se cambió simulación pasiva ni coeficientes; sin nuevo render o evaluación humana del ajuste. La prueba de contacto exigido al 90% es defensa segura, no se etiqueta como tiro perfecto.


## Sesión 012 — presentación y audio del contacto

Motor 4.7.2.stable.official.ed1daf0bf; `impact_checks.gd` crea golpes reales normal/perfecto/defensivo preparando 42/86/1 ticks a 120 Hz, jugador (-2.4,0,6.8) y llegada (0,0.9,-0.65) relativa al jugador. Se verifica pose de pala <0.0001 m del contacto en callback, una presentación/solicitud de audio por hit, WAV correspondiente importado, retorno a reposo, movimiento disponible durante gesto y física sin cambios al animar. Sin sonido preparando; silencio/M, pausa y laboratorio comprobados. Informe previews/impact-checks.json, sin fallos. La espera de 0.25 s al cerrar ejecutores permite al mezclador liberar voces detenidas; sin fugas de audio al cierre final.

Capturas gráficas de preparación y tres clases inspeccionadas a 720p; brazo conectado y destello legible. HUD compacto 640×360 revisado. WAV propios: tres hashes distintos, mono PCM16 44.1 kHz, duraciones 0.12/0.14/0.18 s, sin saturación. Nivel del reproductor -8 dB. Informe audio-checks.json. Se verifican archivos y solicitud de reproducción; no se afirma evaluación auditiva humana ni latencia medida del equipo final.

`player_checks.gd`: 90 trayectorias nominales y diez devoluciones en conductor de 30 s, riesgos de fondo/lateral/red y controles aprobados. `ball_checks.gd`: 13 regresiones aprobadas. Importación sin errores después de tipar dos vectores explícitos. Render llvmpipe CPU con avisos Mesa/VSync conocidos. E3 aceptada por testimonio del usuario; presentación nueva pendiente de su valoración.


## Sesión 013 — pelota equilibrada sobre la cinta

Motor 4.7.2.stable.official.ed1daf0bf, física 120 Hz, semilla por defecto 42. Ejecutor `tests/net_tape_checks.gd`. Antes del cambio: 15 de 33 escenarios no llegaban al piso después de 5 s, todos caídas casi verticales sobre parte superior. Informe `previews/net-tape-before.json`, tomado antes de modificar respuesta.

Quince caídas: x [-4.25,-2.25,0.25,2.25,4.25], z [-0.006,0,0.006], centro a altura del panel + radio + 0.15 m, velocidad (0,-0.3,0). Dieciocho tiros reales calculados por controlador: tres posiciones x, alturas 0.3/0.9/1.8 y distancias de contacto 0.65/1.1, carga 1.0, dirección abajo, preparación/equilibrio 0.8 s. Dos roces adicionales con velocidad z ±2 m/s verifican conservación del sentido de cruce.

Después: 35/35 llegan al piso antes de 5 s, máximo 1.941 s desde lanzamiento; sin estado no finito ni agotamiento de impactos. Energía saliente de cada contacto ≤ entrante +0.001 m/s de tolerancia en rapidez. Primer contacto y sentido de ambos roces conservados. Informe `previews/net-tape-checks.json`. No se afirma captura exacta de la jugada del usuario ni validación visual de este ajuste.

Regresiones ejecutadas: `ball_checks.gd` (13), `player_checks.gd` (90 trayectorias, diez devoluciones/control/riesgos) y `travel_checks.gd` (22 recorridos), sin fallos. Retorno de globo 2.00 m y reja máximo 4.25 m conservados. Cambia solo respuesta de contactos superiores de red, sin modificar coeficientes de piso/vidrio/reja.


## Sesión 014 — derecha, revés y brazos fuera del torso

`tests/stroke_pose_checks.gd`, Godot 4.7.2.stable.official.ed1daf0bf, paso 1/120 s. Dieciocho casos: posiciones x -0.8/0/+0.8 m, alturas 0.3/0.9/1.8 m y 1/86 ticks de preparación. Contacto relativo (±0.8, altura, -0.4), central (0, altura, -0.65) al cuerpo en (0,0,6.8). Verifica selección automática, giro de torso/cadera en preparado, contacto <0.0001 m, sin cambio de velocidad de pelota ni posición del cuerpo por animación y retorno de pivotes al reposo.

En preparación/contacto/40 pasos de seguimiento se muestrean 13 puntos de cada segmento de ambos brazos contra envolvente conservadora de torso (cápsula radio 0.24 m, eje local y [-0.01,0.21]). Margen adicional de radio de cada brazo; tolerancia de unión del hombro 0.008 m. Se verifica además separación de centro de pala ≥0.445 m respecto al eje. Mínimo margen de antebrazo observado 0.0591 m, sin fallos. No cubre toda combinación de altura/distancia ni reemplaza observación humana de biomecánica.

Capturas cercanas de preparación/contacto/seguimiento de ambos lados renderizadas e inspeccionadas: se mejoró flexión de codo, silueta de torso y unión del cuello tras revisión. Seis PNG pose-*.png; el zoom es exclusivo de prueba. `impact_checks.gd` (tres clases/audio/silencio/pausa) y `player_checks.gd` (90 trayectorias/diez devoluciones/controles) siguen aprobados. Importación sin errores de scripts. No se modificaron simulación de pelota ni materiales de cancha; no se repitieron recorridos/FPS pasivos.
