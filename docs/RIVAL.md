# Rival de entrenamiento — sesión 029

## Jugar

En práctica, pulsar **I** (mando: **LB**) activa/desactiva el peloteo. Se inicia una pelota hacia el jugador; los controles de movimiento, preparación, carga/fijación y dirección siguen siendo los mismos. El rival blanco se mueve y devuelve. Los dos personajes decorativos se ocultan mientras se pelotea; esto todavía no es dobles ni un partido reglamentario.

**R** reinicia la jugada y coloca ambos jugadores en sus posiciones iniciales. Tras segundo pique, pelota detenida/fuera o un fallo de trayectoria, se espera **1.8 s** y comienza otra jugada. Se muestra motivo, contactos del peloteo y mejor racha. No son puntos ni juegos. P/Escape y pérdida de foco pausan también rival y espera de reinicio. M silencia/reactiva ambos jugadores. I vuelve a práctica individual; allí R/H y T conservan entrenamiento por carriles. En peloteo, T recuerda cómo volver a ese modo. H permite un globo recibido, pero para aislar ajustes de especiales conviene práctica individual.

## Rival y límites

- Reacción inicial **0.24 s** tras el golpe humano; recálculo de posición cada **0.12 s**.
- Mismo PlayerMotor: velocidad 5.2 m/s, aceleración/frenado y compromiso al preparar; no se teletransporta para alcanzar pelotas.
- Pronóstico aproximado a 60 Hz hasta 2.8 s. Lee posición/velocidad y parámetros de piso/vidrio. No avanza la pelota real ni consulta el futuro de la semilla de reja. Puede equivocarse con cambios de trayectoria.
- Corre hasta una posición de intercepción alcanzable, se planta y prepara usando BasicShot. Busca carga **70%**, pero el contacto automático puede llegar antes y producir una defensa. Misma tolerancia de contacto y recuperación; no tiene alcance extra.
- Devuelve normalmente hacia el carril del humano, con precisión limitada por calidad. Si el humano está a menos de 3.2 m de la red, intenta globo. Plano puede convertirse en volea/smash según contexto. No intenta combo x3/x4.
- Tras devolver, recupera posición con velocidad normal. Pelotas cortas pueden obligarlo a subir y devolver exigido; tiros rápidos/abiertos pueden superarlo.

## Implementación

BasicShot y PlayerMotor tienen identidad/mitad configurables. El controlador calcula en coordenadas de su propia mitad; una rotación de 180° convierte posición, velocidad y destino al mundo. El evento de golpe y la pala conservan coordenadas físicas reales. ImpactFeedback selecciona derecha/revés con esa orientación. Se comparte la lógica, no se modifican los coeficientes de rebote ni la cámara.

TrainingRival controla decisiones, reacción, forecast y reinicio. Solo coloca jugadores explícitamente al comenzar una jugada nueva. La detección de fin distingue contactos desde el último golpe: segundo pique en mitad receptora, piso en mitad equivocada, cerramiento receptor directo sin piso, detención o salida de zona. Un roce de red no corta por sí mismo: puede pasar y seguir. Es lógica de entrenamiento, no árbitro completo, saque, puntuación ni juego exterior.

## Validación

Godot 4.7.2.stable.official.ed1daf0bf, 120 Hz. `rival_checks.gd` ejecuta 60 s de peloteo con conductor humano sintético que usa los controles/motor/golpes reales: **34 devoluciones del rival y 68 contactos consecutivos**. Es evidencia de integración, no de diversión humana. Mide desplazamiento máximo por paso, límites de mitad, predicción sin mutar pelota/reloj/RNG y reacción con demora.

Quince recepciones adicionales combinan plano/globo/chiquita/volea/smash con izquierda/centro/derecha. El rival devuelve planos y globos centrales; algunas voleas y remates lo superan. La chiquita lo hace avanzar y devolver defensivamente en los fixtures. No garantiza devolver todas las pelotas. Cinco pares de contactos espejados verifican trayectorias, destino, calidad, identidad y pala de plano/globo/chiquita/volea/smash.

También se prueba pelota imposible sin devolución remota, fallo real sin input y reinicio, pausa de temporizador, R manual, I/LB, pérdida de foco y aislamiento al entrar en laboratorio. Regresiones de golpes, poses e impactos ejecutadas. Informe `previews/rival-checks.json`.

[Peloteo](previews/rival-training.png) · [Contacto rival](previews/rival-contact.png) · [Ventana pequeña](previews/rival-small.png) · [Video](previews/rival.mp4). Captura con entradas sintéticas y audio silenciado, renderer local llvmpipe; sin benchmark de equipo objetivo.

Pendiente: probar comodidad/ritmo con el usuario, ajustar dificultad y variedad, mejores decisiones tras vidrio/reja, y después evaluar compañero/dos rivales. No se incorporó multijugador, partido o efecto de pelota.
