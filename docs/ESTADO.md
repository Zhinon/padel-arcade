# Estado y próxima sesión

Actualizado: 27/10/2026, zona America/Argentina/Mendoza. Sesión 003.

## Dónde estamos

Etapa siguiente: **E2 — laboratorio de pelota**. Encuadre de E1 aprobado por el usuario. Laterales corregidos y renderizados con perfil de rejas 4/3/4 m. P06 (equipo objetivo) sigue pendiente.

- Godot portátil **4.7.2.stable.official.ed1daf0bf** descargado y ejecutado.
- Cancha visual con piso, líneas, red y perfil lateral de la variante de cristal FIP (extremos altos de 2 m de longitud); todavía sin accesos ni colisiones.
- Cuatro figuras provisionales y pelota de lectura ampliada con trayectoria programada, sin física.
- Tres cámaras y transparencia del cerramiento cercano con controles de laboratorio.
- Repositorio local `main`, sin remoto; cambios de sesión guardados al cierre.

## Verificación y límites

Importación sin errores de scripts. Pruebas geométricas en 1280×720 y 640×360 para las tres cámaras: 0 puntos fuera de cuadro. Pausa, reinicio y variación de alpha comprobados. Se generaron seis capturas con el render real y se inspeccionaron las vistas principal, lejana y reducida.

El entorno usa render por CPU (Mesa llvmpipe) con avisos de driver/VSync; no sirve para afirmar rendimiento en la PC del usuario. No hay gameplay ni prueba reglamentaria. En 640×360 la pelota llega a unos 2.4–2.9 píxeles de diámetro; legibilidad móvil pendiente.

## Próxima tarea concreta

**P20: comparar un modelo pequeño de trayectoria/colisión y definir el laboratorio de rebotes.** Conservar el encuadre aceptado. El cambio de rejas de sesión 003 está aplicado y sus capturas actualizadas.

Antes de estimar rendimiento/exportación, resolver P06: SO objetivo, equipo y mando. No asumir que el equipo del chat es el del jugador.

## Cómo abrir la demo

Desde la raíz: `./tools/run-godot.sh`. Controles: 1/2/3 cámaras; G cerramiento; Espacio pausa; R reinicio. No es todavía un juego controlable.

## Rutina de cierre

Actualizar PLAN.md, este estado y BITACORA.md. Registrar decisiones relevantes, pruebas reales y un punto de recuperación en Git.
