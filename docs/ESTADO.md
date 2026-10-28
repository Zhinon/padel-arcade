# Estado y próxima sesión

Actualizado: 28/10/2026, zona America/Argentina/Mendoza. Sesión 012.

## Dónde estamos

**E3 aceptada por el usuario; E4 activa.** Tras probar la versión con riesgo de red, el usuario dijo «yo creo que la sensacion de juego está buena». P34 cerrado por esa aceptación cualitativa; no se midió duración de su prueba. Se mantienen control, carga ideal cerca del 90%, defensa y riesgos direccionales aprobados.

**P42 implementado para golpe base:** preparación con pala/brazo, inclinación del cuerpo, contacto visual en la posición real y acompañamiento breve. Destello celeste normal, verde perfecto y ámbar defensa. Tres sonidos propios sintéticos provisionales, volumen -8 dB; M silencia/reactiva. No se añadieron bloqueos de control ni cambios en resolución de trayectoria.

Godot 4.7.2.stable.official.ed1daf0bf portátil. Git local main, sin remoto. P06 equipo objetivo/mando sigue pendiente.

## Comprobado en sesión 012

- ImpactFeedback consume el evento físico de golpe; 3 casos reales normal/perfecto/defensa verifican clasificación, pala coincidente con contacto (<0.0001 m), audio correspondiente, un efecto por golpe y vuelta a reposo.
- Presentación no altera posición del cuerpo ni velocidad de pelota; se puede mover durante acompañamiento. Preparar sin contacto no suena. M, pausa y F8 aíslan/limpian efectos; silencio persiste.
- WAV mono PCM16 44.1 kHz: contenido distinto, duración/energía válidas y margen frente a saturación. Despacho de audio comprobado; valoración auditiva humana pendiente.
- Pruebas de jugador: 90 trayectorias nominales, diez devoluciones sintéticas, carga/defensa/riesgos/cancelación. 13 regresiones de pelota aprobadas. Cámara y coeficientes de rebote sin modificar.
- Capturas de preparación y tres contactos inspeccionadas a 720p; ventana pequeña y demostración actualizadas. Render Mesa llvmpipe CPU, sin medición de rendimiento objetivo.

## Límites

Animación geométrica provisional sin esqueleto ni biomecánica final; no hay rival, arbitraje, puntos, giro o tiros avanzados. Otros personajes estáticos; pelota sin colisión con cuerpos. Sonidos sintéticos sin muestras externas; no equivalen a grabaciones de pádel. Mando solo probado sintéticamente. No se repitieron recorridos/FPS pasivos porque no se cambió esa física.

## Próximo paso

**Probar presentación con el usuario:** distinguir tres impactos, volumen, claridad de preparación y gesto. Mantener sensación de control aceptada. Después P40, comenzando por globo del jugador, antes de remate/volea y rival de laboratorio.

## Abrir

`./tools/run-godot.sh`. R recibe; WASD/flechas mueve o apunta preparando; Espacio carga/soltar fija; nueva pulsación tras fijar cancela; T cambia zona; P pausa/continúa; M audio; F8 laboratorio. Guía PRACTICA.md.

## Cierre

Actualizar plan, pruebas y bitácora, registrar decisiones y guardar punto de recuperación Git.
