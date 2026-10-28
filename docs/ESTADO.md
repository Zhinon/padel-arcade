# Estado y próxima sesión

Actualizado: 28/10/2026, zona America/Argentina/Mendoza. Sesión 016.

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

## Corrección de red — sesión 013

El usuario vio una pelota quedarse sobre la red tras cargar 100% apuntando abajo. Reproducido el equilibrio sobre la cara superior plana del collider: 15 de 33 escenarios iniciales no llegaban al piso tras 5 s. No se dispone de la secuencia exacta de entradas del usuario.

Se desvía una parte acotada de velocidad de impacto hacia un costado solo en contactos superiores casi equilibrados. Sin desplazar posición artificialmente, sin RNG y sin superar energía entrante. Contactos frontales y pelotas que cruzan con impulso conservan respuesta anterior. 35 casos corregidos llegan al piso, incluidos 18 tiros cortos al 100% y dos roces que siguen cruzando. Sin agotamiento del presupuesto de impactos.

Regresiones ejecutadas: 13 escenarios de pelota, 90 trayectorias/diez devoluciones y 22 recorridos; globo 2.00 m y reja máximo 4.25 m conservados. Validación sin ventana; no nueva revisión visual/humana del ajuste. Pruebas reproducibles en net_tape_checks.gd e informes net-tape-before/checks.json.

## Derecha y revés — sesión 014

A pedido del usuario se revisó el brazo que atravesaba el torso. Avatar controlado con pivotes de torso/cadera, brazos de dos segmentos y codos, apoyos y pies. Selección automática diestra de derecha/revés por lado de pelota con banda de estabilidad de 0.15 m. Revés con giro de costado y mano de apoyo; pala y antebrazos rodean el frente del torso. Seguimiento vuelve al reposo en los mismos 0.24 s. No cambia controles, alcance, carga, recuperación o instante de impacto.

Verificados 18 casos (ambos lados, tres alturas y dos preparaciones): contacto de pala <0.0001 m, brazos/pala fuera del torso en muestras de recorrido, giro de cadera/torso y regreso a reposo. Regresiones de impacto/audio y 90 trayectorias/diez devoluciones aprobadas. Capturas cercanas de preparación/contacto/seguimiento revisadas; cámara de acercamiento solo en ejecutor, no en juego. Animación sigue geométrica provisional; no se promete ausencia de clipping en todas las posiciones posibles. Evaluación visual humana pendiente.

## Reposo — sesión 015

El usuario aprobó los golpes de derecha/revés y señaló brazos con aspecto quebrado al descansar. Reposo ahora usa codos bajos y relajados, pala al costado y mano libre baja, separado del recorrido de golpe. La recuperación mezcla a esta pose al final y espera que las manos vuelvan a su lado antes de relajar el codo. Se agregaron uniones de hombro para evitar huecos visibles entre manga y torso.

Dieciocho casos de golpes conservan aprobación; reposo inicial y posterior a cada uno verificado con codos de aproximadamente 170°/166°, manos bajo codos y sin estiramiento de segmentos. Tres clases de impacto/audio aprobadas. Capturas de reposo frontal y lateral revisadas. Los golpes, controles y simulación no se modificaron; evaluación humana del reposo nuevo pendiente.

## Revisión del drive — sesión 016

Usuario conforme con revés; pide corregir drive todavía raro. Se encontró torso cerrado al contacto y pala preparando por delante como bloqueo, con brazo de golpe demasiado estirado y codo de brazo libre poco natural.

Cambio solo de drive: preparación al costado/atrás, apertura gradual del torso antes de impacto, codo con dos segmentos más equilibrados y brazo libre de contrapeso. Acompañamiento cruza delante y sube; reposo aprobado conservado. Pelotas detrás del cuerpo conservan orientación defensiva. No cambia física, contactos, control o recuperación.

Dieciocho casos de poses aprobados, incluidos giro antes del contacto, reposo y separación del torso. En contacto lateral cómodo, segmentos de brazo pasan de 0.605/0.516 m a 0.457/0.457 m. Preparación/contacto/seguimiento de los seis casos de revés registrados coinciden con versión anterior. Regresiones de jugador (90 trayectorias/diez devoluciones) e impacto/audio aprobadas; importación y revisión de vistas frontal/lateral/cercana realizadas. Evaluación humana del drive ajustado pendiente.

## Próximo paso

**Probar presentación con el usuario:** distinguir tres impactos, volumen, claridad de preparación y gesto. Mantener sensación de control aceptada. Después P40, comenzando por globo del jugador, antes de remate/volea y rival de laboratorio.

## Abrir

`./tools/run-godot.sh`. R recibe; WASD/flechas mueve o apunta preparando; Espacio carga/soltar fija; nueva pulsación tras fijar cancela; T cambia zona; P pausa/continúa; M audio; F8 laboratorio. Guía PRACTICA.md.

## Cierre

Actualizar plan, pruebas y bitácora, registrar decisiones y guardar punto de recuperación Git.
