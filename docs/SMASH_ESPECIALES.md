# Smash x3 y x4 — sesión 024

Primera versión arcade, 28/10/2026. Pendiente prueba humana del combo y salidas.

## Referencias

[NOX: remate por 3](https://noxsport.com/blogs/making-you-improve/como-hacer-el-remate-por-3-en-padel) explica la secuencia piso rival → vidrio de fondo → salida lateral y destaca posición, técnica y efecto liftado. [Canada Padel: Learn Padel](https://canadapadel.ca/learn-padel/) describe x4 como pique y salida por encima del fondo. [FIP, revisión 01.01.2026](https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf) distingue cerramiento de fondo de 4 m, laterales y juego exterior autorizado.

En nuestra cancha, extremos laterales de 2 m tienen altura total 4 m; los x3 buscan salir en la sección lateral de 3 m. No dar por hecho que todo lateral mide lo mismo. No hay arbitraje ni juego exterior implementados: una salida x3 no equivale aquí a declarar un punto automático.

## Control implementado

1. Acercate a la red, aproximadamente a 1–2 m, en la trayectoria del globo.
2. **H/RB** recibe globo de práctica. Cerca de red, H adapta profundidad para ofrecer contacto alto delante del jugador; no mueve al personaje.
3. Apretá **J + K** juntos; en mando, **A + B**. Ventana inicial de 0.10 s de carga; se conserva lo cargado por el primer botón. No se exige coincidencia exacta de frames.
4. Soltá cerca de **90%**. La primera liberación fija la carga; la segunda no ejecuta ni reinicia nada. El impacto continúa automático.
5. **W+A / W+D (diagonal hacia adelante)** intenta x3 por ese lateral. **S (atrás)** intenta x4. Con flechas o mando, usá las mismas direcciones. Centro, lateral solo, adelante solo y diagonales hacia atrás conservan golpe normal.

Carga admitida: banda existente 86–94%. Requiere calidad >=0.85, jugador a <=2.8 m de la red y contacto válido de smash. Fallar condiciones no concede un especial: usa remate/devolución según situación. El buscador también puede rechazar una salida si no encuentra trayectoria segura para esa geometría; no teletransporta ni garantiza el resultado.

Si el segundo botón llega después de 0.10 s de carga, sigue funcionando como cambio de tipo plano/globo y reinicia carga. Una pulsación de J o K cancela el especial fijado. Pausa, R/H y cambio de modo limpian flags para evitar combos fantasma.

## Trayectoria y límites

SpecialSmash busca una velocidad inicial que, con gravedad, arrastre y rebotes actuales, prediga la secuencia solicitada. Usa cálculo puro y el mismo impulso de fricción del piso; no lanza ni mueve la pelota real para probar candidatos, no modifica RNG ni respuesta del vidrio/reja. Después del contacto solo gobierna BallSimulation con barridos.

No se implementó aún el giro liftado real de x3. Esta versión reproduce la secuencia espacial mediante velocidad/ángulo y asistencia arcade; no representa una técnica biomecánica ni física de spin completa. En especial, el primer pique puede quedar más corto que la colocación típica con liftado. P44 sigue pendiente. Velocidades candidatas se limitan por max_speed existente; se busca la menor velocidad compatible con margen de salida, sin fuerzas extra después del impacto.

x4 mantiene piso rival → salida sobre fondo sin tocar vidrio/reja. x3 mantiene piso rival → vidrio de fondo → salida lateral antes de segundo pique; no se etiqueta como x3 una salida por esquina de 4 m. Presentación reutiliza postura overhead aprobada técnicamente; sonido/destello por calidad. HUD indica que es intento de x3/x4, no punto ganado. Plano, globo, smash normal y chiquita conservan sus botones individuales.

## Verificación

special_smash_checks.gd: 36 contactos, x de jugador -2.4/0/2.4 m, z=1.2/1.8 m, altura=2.4/2.6 m, offset de pelota (0.25,h,-0.35), direcciones diagonal adelante izquierda/derecha y atrás y carga ~90%. Preparación por eventos de teclado reales al adaptador; fixture de pelota estática hasta el contacto y vuelo físico barrido posterior. Salida x3 comprobada por encima de 3 m + radio en sección lateral de 3 m, con contactos exactamente piso/vidrio; x4 por encima de 4 m + radio, contactos solo piso. Pala coincide con pelota, búsqueda conserva posición, reloj y RNG.

Tres feeds H reales cerca de red, sin colocar pelota en impacto, completan izquierda/derecha/x4. Condiciones negativas: lejos, bajo, 50%, 100%, centro/adelante y mala calidad a 90% no dan especial. Orden de botones invertido, segundo botón tardío, liberación vieja, contacto único y limpieza al pausar comprobados. Coste de búsqueda registrado por caso: dato local, no benchmark del equipo objetivo.

Regresiones de plano/control (90/diez), globo (54/tres), smash (54/tres), chiquita (54/24/tres y segundo pique), pelota (13), superficies, 18 poses, tres impactos/audio y cinco abanicazos aprobadas. Impulso de piso extraído a helper sin variar cálculo; no nueva física de materiales. Capturas de juego y videos de tres segundos por tipo revisados; render llvmpipe, no prueba de diversión, mando físico o juego exterior.

[Video x3](previews/x3.mp4) · [Video x4](previews/x4.mp4) · Informe previews/special-smash-checks.json. Videos sin audio, con H y entradas sintéticas; cámara de juego conservada.


Controles actualizados en sesión 025 a J/K. Las capturas y videos de sesiones previas pueden mostrar Espacio/E.


### Globo corto para practicar (sesión 026)

Primero acercate con W hasta 1–2 m de la red y frená. Después pulsá **H**, que lanza un globo hacia tu posición lateral; R sigue siendo la pelota normal. Con J+K juntos prepará, soltá ambos al 90% y apuntá W+A o W+D para x3, o S para x4. No hace falta correr desde el fondo después de lanzar H. El globo se decide según dónde estás al lanzarlo.


Sesión 027: mapeo vigente W+A/W+D x3 y S x4, a partir de la intuición del usuario. Videos previos muestran dirección anterior.
