# Estado y próxima sesión

Actualizado: 28/10/2026, zona America/Argentina/Mendoza. Sesión 028.

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

Animación geométrica provisional sin esqueleto ni biomecánica final; no hay rival, arbitraje, puntos o giro; chiquita, globo, smash y volea contextual disponibles. Otros personajes estáticos; pelota sin colisión con cuerpos. Sonidos sintéticos sin muestras externas; no equivalen a grabaciones de pádel. Mando solo probado sintéticamente. No se repitieron recorridos/FPS pasivos porque no se cambió esa física.

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

## Abanicazo — sesión 017

Usuario conforme con drive y pide gesto de pala aunque erre. BasicShot emite `missed` separado de `hit`: pelota preparada pasa fuera de alcance/altura, intento tardío, caducidad o pulsación sin pelota disponible. ImpactFeedback anima un golpe al aire local de derecha/revés (0.28 s), con movimiento libre y sin modificar pelota, emitir impacto ni destello. Cancelar continúa sin gesto. Mantener no encadena intentos; una vez fallado no engancha una pelota que entre después.

Cinco gestos comprobados: vacío, fuera de alcance izquierda/derecha, altura excesiva y pulsación tardía con pelota entrando posteriormente en alcance. También caducidad, cancelación, pausa/laboratorio y retorno al reposo. Capturas de cuatro gestos revisadas; nuevo caso tardío verificado sin ventana. Regresiones de 18 poses, tres impactos/audio y jugador (90 trayectorias/diez devoluciones) aprobadas; importación sin errores de scripts. Valoración humana del nuevo gesto pendiente.

## Chiquita — sesión 019

Primera chiquita con carga baja fijada y dirección abajo, sin botón nuevo. Hasta 40% mezcla hacia pique a 1.6 m de red rival; entre 40–65% vuelve gradualmente al golpe base. Dirección lateral conserva control según calidad. Preparación sigue acumulando calidad tras soltar; carga baja elegida temprano puede ser excelente (12–40% con calidad >=0.85). Tardía continúa defensiva; potencia insuficiente más mala calidad puede tocar red. Solución de arco bajo con límite horizontal 8 m/s, por lo que contacto alto/cercano puede flotar. Sin giro ni ajuste automático al rival.

54 trayectorias, 24 transiciones y tres feeds reales por zonas aprobados, además de 90 trayectorias/diez devoluciones, tres impactos/audio, cinco abanicazos y 35 contactos de cinta. Captura nativa revisada con cámara conservada; todavía no evaluación humana ni efecto táctico contra rival. Guía y parámetros en CHIQUITA.md.

## Segundo pique — sesión 020

Feedback del usuario: chiquita avanza demasiado tras primer pique. Medido hasta segundo: 3.70 m en feed habitual. Calibración general del agarre del piso por pendiente reduce a 2.47 m (caso cómodo 4.02→2.65 m). También afecta caídas pronunciadas de otros golpes, con restitución vertical y rodadura conservadas. Sin giro ni frenado por etiqueta de golpe. Más detalle, fuentes y límites en CHIQUITA.md.

Nueva comprobación de segundo pique, 54 trayectorias/24 transiciones/tres feeds, superficies, 22 recorridos, 13 escenarios, 90 trayectorias/diez devoluciones, 35 casos de cinta y comparación 30/60/120 FPS aprobados. Primera variante frenaba globo antes de vidrio; corregida con pérdida extra acotada. Captura revisada y video regenerado. Falta valoración humana; las distancias son calibración, no datos reales de chiquita.

## Plano y globo — sesión 021

Espacio/A prepara plano, E/B prepara globo. Ambos cargan/fijan al soltar y golpean al llegar pelota. Chiquita se mantiene en plano. Otro botón cambia tipo y reinicia carga conservando preparación; soltar anterior no afecta al nuevo, mismo botón tras fijar cancela. R/pausa/laboratorio limpian.

Globo tiene arco/profundidad propios, con calidad y sobrecarga al cerramiento. Ejemplo 25%: apex 3.65 m/profundidad 5 m; ~90%: 5.25 m/7.58 m. Cámara/física pasiva sin cambios, poses/sonidos provisionales compartidos. 54 trayectorias/tres feeds y controles probados; regresiones de plano, chiquita, impacto y abanicazo aprobadas. Captura nativa y HUD pequeño revisados. GLOBOS.md contiene parámetros, límites y evidencia; El usuario aprobó cualitativamente la sensación de plano/globo («lo sentí bien»), sesión 022. No se midieron duración ni casos concretos; mando físico pendiente.

## Smash contextual — sesión 023

Espacio/A remata pelota alta descendente entre 2.15–2.65 m, delante y dentro de alcance horizontal 0.75 m. Espera breve por altura ideal 2.4 m. E/B conserva globo. Preparación y calidad determinan ataque o devolución suave. Trayectoria ofensiva nominal 13–26 m/s horizontales, sobrecarga conserva riesgos. H/RB recibe globo para practicar; R pelota normal.

Presentación propia con pala alta y seguimiento sobre/al costado de cabeza. 54 casos, tres H reales, límites/defensa/riesgos y geometría torso/cabeza aprobados; plano, globo, chiquita, impacto, abanicazo y 18 poses previas mantienen pruebas. Capturas revisadas y video de cinco segundos; SMASH.md detalla parámetros y límites. Sin salto ni giro ni rival; smash todavía requiere valoración humana.

## x3/x4 — sesión 024

Usuario acepta cualitativamente smash y pide especiales. Espacio+E/A+B juntos (primeros 0.10 s de carga) arma especial, conserva carga inicial y fija al soltar. Lateral pide x3, adelante x4. Requiere smash alcanzable, jugador <=2.8 m de red, calidad >=0.85 y 86–94% de carga. Fallar condiciones o búsqueda devuelve golpe normal. H adapta profundidad cuando jugador está cerca para practicar sin recolocarlo.

Búsqueda pura elige velocidad inicial para piso/vidrio/salida lateral o piso/salida fondo. No modifica materiales o fuerza después de impacto; P44 spin real sigue pendiente. 36 salidas físicas y tres H reales aprobados, con negativos y controles. Regresiones de plano/globo/smash/chiquita, pelota/superficies, poses/audio/fallo aprobadas. Capturas y videos de tres segundos revisados. SMASH_ESPECIALES.md contiene referencias, parámetros y límites. Sin rival/puntos/juego exterior ni evaluación humana de especiales.

## Próximo paso

**Probar volea contextual con el usuario (P41):** colocarse a unos 3 m de red en carril de recepción, R y preparar J enseguida, fijar ~90%, apuntar. Comprobar gesto corto, respuesta y diferencia con defensa. Después P43 rival simple para encadenar intercambios; calibración humana de especiales sigue abierta.

## Abrir

`./tools/run-godot.sh`. R recibe; WASD/flechas mueve o apunta preparando; J plano y K globo, mantener carga/soltar fija; repetir botón elegido tras fijar cancela; H recibe globo para smash; T cambia zona; P pausa/continúa; M audio; F8 laboratorio. Guía PRACTICA.md.

## Cierre

Actualizar plan, pruebas y bitácora, registrar decisiones y guardar punto de recuperación Git.


## Controles actualizados — sesión 025

Por incomodidad del combo anterior, J prepara plano/smash y K prepara globo; J+K arma el especial. WASD/flechas conservados; mando A/B sin cambios. Espacio sigue pausando en laboratorio. Las secciones históricas y videos anteriores muestran los botones previos. Reiniciar el juego para cargar este cambio.


## Práctica del especial — sesión 026

Usuario no consigue globo corto usando R. R es pelota normal: para globo usar H, después de colocarse a 1–2 m de red. H ahora se alinea lateralmente con el jugador (hasta ±4 m), conservando profundidad adaptada. Antes seguía el carril de R/T, incluso con jugador desplazado. Mensajes inicial y de lanzamiento explican H y J+K. Tres feeds reales en distintos carriles permiten esperar 0.65 s antes de cargar J+K y fijar 90%, sin mover al jugador ni cambiar carga/física. Comodidad humana pendiente.


## Direcciones intuitivas — sesión 027

Usuario dice «ta bueno» y señala que esperaba W+D para x3 y S para x4. Se adopta W+A/W+D para x3 hacia ese lateral, S para x4; equivalentes en flechas y stick. Dirección lateral sola, adelante solo, centro o diagonal atrás conservan golpe ordinario. Cambia selección de especial, no trayectoria ni carga. HUD/guías actualizados; videos antiguos reflejan mapeo anterior. Pendiente probar comodidad de este cambio.


## Volea contextual — sesión 028

J/A intercepta antes del pique propio en vuelo entrante de 0.45–2.1 m; alcance 1 m, ideal 1.25 m. Trayectoria propia 10–17 m/s nominales con asistencia de red, gesto compacto y recuperación preparada 0.14 s. Llegada exigida conserva devolución suave/menos colocada y 0.28 s; 100% conserva riesgo. K/globo, pelota alta/smash y después del pique/plano-chiquita conservados. No efecto cortado ni cambios físicos. 54 trayectorias/tres R reales y regresiones aprobadas; render nativo/capturas revisados, valoración humana pendiente. Ver VOLEA.md.

Riesgos de volea verificados tras pedido del usuario: poca fuerza/contacto bajo puede tocar red; suave cómoda pasa; 100% profundo o abierto puede tocar directamente vidrio de fondo o cerramiento lateral rival antes del piso. Seis casos específicos guardados en informe.
