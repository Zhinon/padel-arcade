# Laboratorio de pelota — sesión 006

Desde sesión 007 la escena abre en práctica E3 (PRACTICA.md). Este laboratorio de gravedad y colisiones sigue disponible con F8 o --lab. La cámara y la geometría lateral aprobadas se conservan. Los jugadores todavía son figuras sin control ni colisión.

## Abrir y probar

Desde la raíz del proyecto en Linux:

```bash
./tools/run-godot.sh -- --lab
# Abrir directamente el globo:
./tools/run-godot.sh -- --scenario=7
```

| Tecla | Acción |
| --- | --- |
| F1 | Caída vertical |
| F2 | Tiro que pica y llega al vidrio de fondo; lanzamiento inicial |
| F3 | Reja lateral |
| F4 | Tiro bajo contra la red |
| F5 | Esquina de vidrio |
| F6 | Tiro rápido de 60 m/s |
| F7 | Globo |
| Espacio | Pausar/reanudar la física |
| R | Repetir el lanzamiento seleccionado con la misma semilla de reja |
| N | Nueva semilla y relanzamiento: probar otra respuesta de la reja |
| L | Activar/desactivar repetición automática; apagada de inicio para observar hasta reposo |
| 1/2/3 | Cambiar cámara |
| G | Atenuar el cerramiento cercano; la colisión no cambia |

El título de la ventana muestra escenario y último contacto. La estela dibuja posiciones recientes; las marcas indican contacto con piso (celeste), vidrio (verde), reja (naranja) o red (rojo). Se limpian al relanzar. No se añaden todavía reglas de punto.

![Laboratorio físico](previews/ball-lab.png)

[Globo completo hasta detenerse, calibración sesión 006](previews/lob-lab.mp4).

[Video histórico F2, calibración sesión 005](previews/ball-lab.mp4).

[Comparación de reja con semillas 42 y 43, cuatro segundos por variante](previews/fence-lab.mp4).

## Modelo elegido (P20)

Se compararon las responsabilidades de estas alternativas, sin construir dos motores completos:

| Alternativa | Ventaja | Costo para este proyecto |
| --- | --- | --- |
| RigidBody3D y materiales físicos | Integración y contactos administrados por el motor | Menor control directo del orden de rebotes y futura trayectoria de tiro; requeriría adaptar la captura de contactos |
| CharacterBody3D con integración y barrido de movimiento | Velocidad y respuesta controladas, contactos ordenados y relanzamientos explícitos | Hay que implementar gravedad, respuesta y reposo |
| Colisiones analíticas propias | Predicción controlada | Duplicaría detección de contactos, esquinas y geometría |

Se eligió **CharacterBody3D con move_and_collide**, integrado en pasos físicos de 1/120 s. Es física de prototipo con gravedad y rebotes, no una trayectoria animada. El barrido lo realiza Godot; después del impacto se resuelve el tiempo restante y puede haber más de un contacto en el mismo paso. Presupuesto máximo: ocho impactos; si se agota, se descarta el tiempo restante conservadoramente y se registra. No ocurrió en las pruebas.

No se implementa todavía efecto de giro, deformación de pelota ni viento. La reja añade desvíos laterales y verticales acotados sobre la reflexión amortiguada, con un generador reiniciado por semilla. La malla usa una superficie sólida equivalente para colisión, no colisiones con cada alambre. Las aberturas superiores permiten salir por encima del cerramiento.

## Parámetros iniciales (ajustables, no mediciones de material real)

| Parámetro | Valor |
| --- | --- |
| Gravedad | 9.81 m/s² |
| Radio físico y visual provisional | 0.105 m, ampliado para lectura; no reglamentario |
| Velocidad máxima de lanzamiento/simulación | 60 m/s |
| Restitución normal piso / vidrio / reja / red | 0.68 / 0.62 / 0.36 / 0.12 |
| Retención tangencial piso | 0.94 |
| Retención tangencial vidrio / reja | 0.82 / 0.65 |
| Fricción tangencial en cada pique | Impulso limitado μ=0.18 × impulso normal |
| Desaceleración de rodadura | 2.8 m/s²; detención en tiempo finito |
| Desvío de reja por impacto | Ángulos muestreados en ±22° lateral / ±16° vertical |
| Semilla de reja inicial | 42; N cambia variante y R la repite |
| Retención tangencial red | 0.65 |
| Resistencia aérea | Amortiguación exponencial, coeficiente 0.04 s⁻¹ |
| Reposo | Se asienta al impactar piso por debajo de 0.8 m/s normal |

Los parámetros están expuestos en ball_simulation.gd. No se afirma fidelidad física reglamentaria ni ajuste final de diversión. Las condiciones iniciales de cada escenario están en launch_scenarios.gd, en metros y m/s.

## Registro de contactos

Cada contacto incluye secuencia, tiempo aproximado dentro del paso, superficie, collider, posición, normal, velocidades entrante/saliente, lado, último golpeador, semilla y ángulos de desvío de reja. Este último vale -1 porque aún no hay golpes de jugadores. No hay marcador ni ganador del punto. La gravedad se integra al comienzo del paso, por lo que el tiempo de impacto aproxima el movimiento dentro de esa discretización.

## Reproducir comprobaciones

```bash
./tools/run-godot.sh --headless --script res://tests/ball_checks.gd
./tools/run-godot.sh --headless --script res://tests/surface_calibration_checks.gd
./tools/run-godot.sh --headless --script res://tests/travel_checks.gd
./tools/run-godot.sh --headless --fixed-fps 30 --script res://tests/frame_rate_checks.gd -- --fps=30
./tools/run-godot.sh --headless --fixed-fps 60 --script res://tests/frame_rate_checks.gd -- --fps=60
./tools/run-godot.sh --headless --fixed-fps 120 --script res://tests/frame_rate_checks.gd -- --fps=120
python3 tools/compare-fps.py
./tools/run-godot.sh --headless --script res://tests/camera_checks.gd
```

Resultados: 13 escenarios físicos y controles de pausa/reanudación/reinicio/F4, cero fallos. Desde sesión 005, el lanzamiento de reja F3 con semilla 42 a dos segundos coincide a 30/60/120 FPS de render programados, tolerancia 0.00001 m y 0.00001 m/s. Esto verifica independencia del ritmo de render en ese caso, no rendimiento de hardware ni determinismo entre plataformas.

Los JSON están en previews/ball-checks.json y previews/ball-fps-*.json. Ver PRUEBAS.md para alcance y evidencia.


## Ajuste tras prueba del usuario — sesión 005

Se detectó que el antiguo F7 llegaba al vidrio antes del piso: primer contacto vidrio a ~1.952 s; luego piso a ~2.133 s. No era un globo de prueba adecuado para evaluar una devolución normal de fondo. El F7 actual reduce velocidad horizontal y ajusta altura: piso a ~2.092 s, vidrio a ~2.344 s y segundo piso a ~3.594 s, todavía en Z≈-4.50 m. No se agregó una prohibición artificial de volver al otro lado: se corrigieron lanzamiento y pérdida de velocidad.

Vidrio: restitución normal 0.82→0.68 y retención tangencial 0.98→0.90. Reja: 0.55→0.48 y 0.98→0.82, más desvío angular por impacto. Son valores de calibración de prototipo por feedback, no mediciones de materiales reales. La corrección del globo combina nuevas condiciones iniciales y amortiguación; no se atribuye todo el resultado a un solo cambio.

La variación de reja conserva la velocidad de la respuesta ya amortiguada y mantiene salida hacia el interior del cerramiento. La misma semilla y el mismo lanzamiento reproducen la secuencia; N permite variar. No se aplica azar por frame. En veinte semillas se observaron desvíos horizontales aproximadamente entre -19.9° y +22.7° para el tiro frontal ensayado. Pruebas y resultados en `previews/surface-calibration.json`.

**Efecto pendiente:** la pelota no tiene velocidad angular, fuerza de Magnus ni intercambio entre giro y velocidad en el contacto. No se simulan topspin, slice ni efecto lateral. La irregularidad de reja es una propiedad de superficie y no reemplaza ese sistema.


## Recorrido hasta reposo — sesión 006

La revisión anterior observaba la secuencia de los primeros piques, pero no limitaba la deriva posterior: midiendo el lanzamiento completo hasta detenerse, F7 volvía 9.75 m desde el primer impacto con vidrio, y F3 llegaba a 9.78 m desde reja en alguna de veinte semillas. Reducir solo el rebote de pared no había resuelto la conservación de movimiento horizontal en cada pique.

Ahora cada contacto con piso resta un impulso tangencial proporcional al impulso normal (μ=0.18), limitado para no invertir la velocidad. Se mantiene la retención 0.94 después de ese impulso. En rodadura se aplica desaceleración constante de 2.8 m/s², en lugar de amortiguación exponencial y un umbral mínimo. No se fija distancia máxima ni se teletransporta o congela la pelota después de cierta cantidad de piques.

Además se ajustaron restituciones de piso/vidrio/reja a 0.68/0.62/0.36 y retenciones de vidrio/reja a 0.82/0.65. Son parámetros de prototipo, no valores empíricos de una cancha real.

| Métrica del lanzamiento completo | Antes, commit 20e7267 | Sesión 006 |
| --- | --- | --- |
| F7: máximo retorno desde vidrio | 9.75 m | 2.00 m |
| F3: máximo retorno desde reja, 20 semillas | 9.78 m | 4.25 m |
| F3: máximo camino horizontal tras reja | 11.84 m | 4.35 m |

Se mide desplazamiento hacia el interior desde el primer impacto hasta reposo. Las cifras describen estos escenarios, no un límite universal: un tiro potente puede recorrer más que un globo normal. El F2, un tiro bajo más rápido, vuelve aproximadamente 8.02 m y queda antes de la red.

Para comprobar rodadura se lanzó una pelota ya apoyada a 3 m/s y se comparó la distancia con v²/(2a), tolerancia 0.03 m. Se verificó reposo sin deriva ni contactos adicionales. La repetición automática está apagada al abrir; R/F1–F7 relanzan, y L permite repetir si se desea. El título muestra “detenida” al terminar.

Informes: `previews/travel-checks.json` y `travel-comparison.json`. Los videos históricos anteriores no representan esta nueva fricción; los de globo/reja sesión 006 muestran el final de cada lanzamiento.
