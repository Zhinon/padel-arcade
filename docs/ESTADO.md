# Estado y próxima sesión

Actualizado: 27/10/2026, zona America/Argentina/Mendoza. Sesión 002.

## Dónde estamos

Etapa activa: **E1 — revisión de cancha y cámara**. P05 y P10–P14 completados como prototipo visual. P15 pendiente de revisión del usuario. P06 (equipo objetivo) sigue pendiente.

- Godot portátil **4.7.2.stable.official.ed1daf0bf** descargado y ejecutado.
- Cancha visual con piso, líneas, red y cerramientos simplificados; no tiene accesos ni colisiones todavía.
- Cuatro figuras provisionales y pelota de lectura ampliada con trayectoria programada, sin física.
- Tres cámaras y transparencia del cerramiento cercano con controles de laboratorio.
- Repositorio local `main`, sin remoto; cambios de sesión guardados al cierre.

## Verificación y límites

Importación sin errores de scripts. Pruebas geométricas en 1280×720 y 640×360 para las tres cámaras: 0 puntos fuera de cuadro. Pausa, reinicio y variación de alpha comprobados. Se generaron seis capturas con el render real y se inspeccionaron las vistas principal, lejana y reducida.

El entorno usa render por CPU (Mesa llvmpipe) con avisos de driver/VSync; no sirve para afirmar rendimiento en la PC del usuario. No hay gameplay ni prueba reglamentaria. En 640×360 la pelota llega a unos 2.4–2.9 píxeles de diámetro; legibilidad móvil pendiente.

## Próxima tarea concreta

**P15: comparar las vistas de docs/CAMARA.md con el usuario.** La vista 1 es referencia; la 2 muestra más entorno. Ajustar altura/distancia si hace falta. Después avanzar al experimento P20 de trayectoria/colisión y laboratorio de rebotes.

Antes de estimar rendimiento/exportación, resolver P06: SO objetivo, equipo y mando. No asumir que el equipo del chat es el del jugador.

## Cómo abrir la demo

Desde la raíz: `./tools/run-godot.sh`. Controles: 1/2/3 cámaras; G cerramiento; Espacio pausa; R reinicio. No es todavía un juego controlable.

## Rutina de cierre

Actualizar PLAN.md, este estado y BITACORA.md. Registrar decisiones relevantes, pruebas reales y un punto de recuperación en Git.
