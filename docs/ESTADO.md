# Estado y próxima sesión

Actualizado: 28/10/2026, zona America/Argentina/Mendoza. Sesión 009 (acuerdos de control).

## Dónde estamos

**E3 implementada técnicamente; pendiente revisión humana P34.** El usuario aprobó la calibración de rebotes de E2 antes de avanzar. La escena abre en práctica: jugador naranja con aro, entrada por acciones, movimiento, preparación/soltar y golpe base con ayuda de dirección. Lanzador manual R, tres zonas con T y avisos en pantalla. Los otros personajes están estáticos.

Godot 4.7.2.stable.official.ed1daf0bf portátil. Git local `main`, sin remoto. P06 (equipo objetivo/mando) pendiente.

## Comprobado

- Noventa trayectorias de devolución: red despejada y primer pique a menos de 0.4 m del objetivo.
- Sin golpe remoto, preparación demasiado corta rechazada, altura limitada, una vez por intento y por pelota del jugador. Golpear preserva posición, reloj e historial; cambia velocidad/último golpeador.
- Movimiento cardinal/diagonal equivalente, límites de cancha y preparación que reduce velocidad. Pausa/foco/F8 comprobados.
- Integración automática de 30 s: diez contactos en tres zonas. Grabación de dos contactos mediante eventos de Godot. No es prueba humana.
- Panel revisado en 720p y 360p; modo compacto en ventanas menores a 800 px.
- Física E2 sin cambiar coeficientes: 13 regresiones, calibración, recorrido y comparación 30/60/120 FPS programados siguen aprobados.

Todavía no hay rival, reglas de partido, giro ni tiros avanzados del jugador. La pala tiene animación procedural provisional. La pelota aún no interactúa con cuerpos de jugadores. Mando configurado pero no probado físicamente. Render local por CPU: sin afirmaciones de rendimiento del equipo objetivo.

## Próximo paso

**Revisar E3 con la referencia de control aportada por el usuario.** Acuerdos D43–D45 documentados en REVISION_CONTROLES_ARCADE.md: soltar fija carga, contacto automático, tiro ideal cerca del 90%, riesgo al 100% de cerramiento directo y defensa tardía débil con menos dirección. Definir cancelación/caducidad e implementar por partes; luego P34 de sensación humana. El ejecutable sigue siendo sesión 007: soltar ejecuta el intento. E4 queda después de validar este núcleo.

## Abrir

`./tools/run-godot.sh`. R recibe; WASD/flechas mueve; mantener/soltar Espacio golpea; T cambia zona; P pausa; F8 laboratorio. Si al cambiar de ventana se pausa, P continúa. Guía PRACTICA.md.

El laboratorio anterior se inicia con `-- --lab` o `-- --scenario=7`. Coeficientes y límites en LABORATORIO_PELOTA.md.

## Cierre

Actualizar plan, pruebas y bitácora, registrar decisiones y guardar un punto de recuperación en Git.
