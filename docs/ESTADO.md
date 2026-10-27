# Estado y próxima sesión

Actualizado: 27/10/2026, zona America/Argentina/Mendoza. Sesión 005.

## Dónde estamos

**E2 implementada y comprobada como laboratorio inicial.** Cámara aprobada por el usuario y laterales corregidos en E1. Pelota con gravedad, colisiones y rebotes diferenciados, siete lanzamientos, pausa/reinicio, estela y marcas de impacto. Vidrio más amortiguado y reja con desvíos controlados por semilla tras feedback del usuario. Figuras de jugadores todavía estáticas y sin colisión. Sin golpes, IA ni reglas de punto.

Godot portátil 4.7.2.stable.official.ed1daf0bf. Repositorio local `main`, sin remoto. P06 (equipo objetivo) continúa pendiente.

## Verificación

- Importación y ejecución con Godot, sin errores de scripts en las ejecuciones finales.
- 13 escenarios físicos aprobados: caída, vidrio, reja, red, esquina, tiro rápido, junta vidrio/reja, reja alta de esquina, salida por arriba, reposo, comparación de transparencia y repetición.
- Calibración de superficies: globo piso→vidrio→piso sin cruzar red antes del segundo pique; veinte semillas de reja, repetición estable y energía no creciente. Cero fallos.
- Comparación en procesos separados a 30/60/120 FPS programados (ahora escenario de reja F3, semilla 42): posición, velocidad y secuencia de superficies coinciden tras dos segundos, tolerancia 0.00001 m/m·s⁻¹.
- Pruebas existentes de cámara, pausa, reinicio y atenuación aprobadas. Se conserva un modo visual E1 solo para pruebas de encuadre.
- Captura de cuatro segundos del laboratorio; revisar LABORATORIO_PELOTA.md.

El entorno renderiza por CPU (Mesa llvmpipe): no hay medición válida de rendimiento del equipo objetivo. La pelota sigue ampliada a radio 0.105 m y los coeficientes son de prototipo. Hay dispersión de reja por semilla; todavía no hay giro, Magnus ni transferencia de efecto en rebotes. Accesos laterales pendientes.

## Próxima tarea concreta

Probar la demo con el usuario para detectar ajustes evidentes de velocidad/rebote. Después **P30/P31: acciones de entrada y movimiento de un jugador**, seguido de alcance y primer golpe (P32/P33). No añadir rivales ni marcador antes de poder devolver una pelota.

Antes de estimar rendimiento/exportación, resolver P06: sistema operativo, equipo y mando.

## Abrir

`./tools/run-godot.sh` desde la raíz. F1–F7 escenarios; Espacio pausa; R repite semilla; N nueva variante de reja; L repetición; 1/2/3 cámaras; G vidrio. Guía completa en LABORATORIO_PELOTA.md.

## Cierre de sesión

Actualizar plan, estado, pruebas y bitácora. Decisiones relevantes se conservan en DECISIONES.md; guardar un punto de recuperación en Git.
