# Arquitectura inicial — propuesta

Este documento describe responsabilidades previstas. Existe un laboratorio visual en `game/scenes/main.tscn`, con `scripts/court.gd` para geometría y `scripts/camera_lab.gd` para figuras, cámaras y trayectoria de prueba. `tests/camera_checks.gd` verifica encuadre y controles del laboratorio. En E2 se añadieron `scripts/ball_simulation.gd` (CharacterBody3D con integración y barridos), `scripts/launch_scenarios.gd` (condiciones iniciales) y superficies StaticBody3D etiquetadas en Court. En E3 se incorporaron PracticeInput, PlayerMotor, BasicShot y PracticeHUD. Reglas, IA y partido de la tabla todavía no se implementaron. Crear carpetas y abstracciones cuando se necesiten.

## Responsabilidades

| Sistema previsto | Responsabilidad | No debe decidir |
| --- | --- | --- |
| Court | Geometría y superficies identificables | Ganador de punto |
| BallSimulation | Posición/velocidad, gravedad y contactos ordenados | Marcador |
| PlayerMotor | Desplazamiento y orientación | Puntuación |
| ShotController | Preparación, alcance, selección y petición de golpe | Animación como única prueba de contacto |
| TeamAI | Receptor, cobertura y elección de acciones | Teletransportar pelota/jugadores |
| RulesEngine | Interpretar secuencias y emitir resultado reglamentario | Dibujar efectos |
| MatchController | Servicio, punto, marcador y transiciones | Física de contactos |
| CameraRig | Encuadre y oclusiones visuales | Trayectoria de pelota |
| InputAdapter | Teclado/mando/táctil → acciones comunes | Reglas deportivas |
| Presentation | Animación, audio, marcador y feedback | Autoridad física |

## Convenciones iniciales

- Una unidad de mundo representa un metro; X es ancho, Y altura, Z largo de cancha.
- Centro de cancha en origen; red aproximadamente en Z=0. Piso provisional de 10×20 unidades basado en referencia FIP.
- Lados se identifican por equipo; no depender para siempre de “cercano/lejos”, porque habrá cambios de lado.
- Simulación a paso físico fijo; render puede variar. No prometer determinismo exacto entre plataformas.
- Parámetros de pelota, cámara y golpes ajustables, evitando números repetidos en scripts.
- GDScript tipado y nombres descriptivos. Preferir composición de escenas frente a grandes jerarquías de herencia.

## Flujo previsto de un punto

Entrada humana/IA → movimiento o petición de golpe → validación de alcance/tiempo → impulso o trayectoria autorizada → simulación → eventos de contacto → reglas → fin de punto → marcador → próximo servicio.

Los eventos necesitarán tiempo/orden, superficie, lado, posición y último golpeador. Evaluar impactos múltiples por el primer contacto y agrupar contactos persistentes para no duplicar piques.

## Decisión P20 — sesión 004

Evaluadas las responsabilidades de RigidBody3D, CharacterBody3D con barrido y detección analítica propia. Elegido CharacterBody3D con gravedad/respuesta controladas y move_and_collide para barrido, a 120 Hz. Da control de relanzamiento y secuencia de contactos sin duplicar la detección de Godot. No se hizo un benchmark de dos motores completos. Prueba pequeña y condiciones en LABORATORIO_PELOTA.md. Detección y apariencia son independientes: atenuar vidrio no desactiva su StaticBody3D.

## Preparación móvil

Las acciones de juego no referencian teclas directamente. Física y reglas no dependen de resolución. UI y cámara tienen parámetros independientes. Perfil de rendimiento y controles táctiles se validan en dispositivo; no quedan resueltos por estas decisiones.


## Ajuste de superficies, sesión 005

BallSimulation incorpora retención tangencial de vidrio/reja y RNG local para dispersión de reja. Se reinicia en launch con semilla explícita; se consume solamente al impactar reja. Cámara y ritmo de render no seleccionan números aleatorios. El registro de impacto añade semilla y ángulos de desvío. Este comportamiento no incorpora velocidad angular ni modelo de efecto.


## Fricción — sesión 006

BallSimulation resuelve ahora fricción tangencial de piso según impulso normal y desaceleración de rodadura de magnitud constante. La conservación/reducción de energía se comprueba por contacto y el reposo por distancia analítica. No hay condiciones que corten el viaje por cantidad de piques o por tipo de escenario. La repetición automática es un control del laboratorio, apagado de inicio.


## Práctica y golpe base — sesión 010

- PracticeInput traduce teclado/mando a acciones semánticas; no se leen teclas físicas en movimiento o resolución de golpe.
- PlayerMotor usa cápsula y barridos move_and_collide con delta explícito. Superficie plana, sin saltos; resuelve deslizamiento por contacto y limita a la mitad cercana. Prioridad física -10, antes de la pelota (0).
- BasicShot (prioridad 20) usa estados IDLE/PREPARING/LOCKED/STRIKING/RECOVERING/MISSED después de mover la pelota. Soltar fija carga; una ventana cómoda de contacto elige el impacto automáticamente. Muestrea el direccional durante preparación y fija al jugador mediante PlayerMotor. Calidad combina posición, altura, estabilización y tiempo; modifica potencia y dirección con un mínimo defensivo. Sobrecarga extiende el objetivo sin RNG. Objetivo rival y arco asistido se resuelven con gravedad/resistencia del modelo discreto actual.
- BallSimulation.strike conserva posición, reloj, historial y RNG; registra golpeador. launch limpia historial y habilita otra pelota. Contactos pasivos y golpes son eventos distintos.
- PracticeHUD muestra instrucciones/estado sin intervenir en simulación. Root coordina alimentación, pausa, foco y alternancia E2/E3.
- Capa de colisión: cancha 1, pelota 2, jugador 4. Jugador consulta cancha; pelota consulta cancha, no cuerpos. Evita introducir reglas de cuerpo antes de implementarlas.

No existe IA de jugador en runtime. El conductor que realiza contactos de prueba y mueve el actor automáticamente está únicamente en tests/.


## Presentación — sesión 012

ImpactFeedback observa `BasicShot.hit` y no modifica simulación. Prioridad 30 después de pelota y golpe: aplica pose de pala al contacto y solicita AudioStreamPlayer en el mismo evento; luego anima seguimiento, brazo y destello. PlayerMotor mantiene autoridad exclusiva del desplazamiento; se retiró su antigua rotación independiente de pala para no competir. Root coordina activación, alimentación, pausa y laboratorio. M controla silencio de efectos, sin mutar el bus global. Sonidos importados desde game/audio, generados por tools/generate-impact-audio.py.


## Avatar articulado provisional — sesión 014

Solo el jugador controlado usa HipsPivot y TorsoPivot, brazos Upper/Fore con codos y pies diferenciados. ImpactFeedback selecciona derecha/revés, gira pivotes y resuelve segmentos hombro→codo→mano; la mano libre acompaña revés. PlayerMotor conserva desplazamiento/colisión y no usa apuntado para orientar el avatar durante preparación. Pala se coloca exactamente en hit; preparación y seguimiento usan recorrido exterior al torso. No hay esqueleto importado ni nuevo sistema físico de articulaciones. Cámara cercana de stroke_pose_checks solo para revisión.


## Drive — sesión 016

ImpactFeedback distingue orientación cerrada de preparación y orientación abierta de contacto para drive. El codo se calcula con dos segmentos equilibrados y guía exterior al cruzar el torso; brazo libre usa solución reflejada para contrapeso. Las ramas de revés y reposo no cambian. Pelota y controlador siguen siendo autoridad del impacto; ningún giro difiere ni adelanta golpe físico.


## Intento fallido — sesión 017

BasicShot emite `missed` desde MISSED, con posición/disponibilidad de pelota, carga y motivo. El cruce del plano de contacto sin alcance resuelve fallo sin esperar caducidad; begin_prepare permite intento vacío que va directamente a MISSED. Mantener/soltar de una recepción válida conserva semántica anterior.

ImpactFeedback.present_miss elige zona virtual local y anima avance/seguimiento con su propio progreso, sin reutilizar señales de strike o sonidos de impacto. Reutiliza poses de derecha/revés pero separa duración (0.28 s) y marca miss_animation; normal hit limpia esa marca. Los consumidores físicos solo reciben hit/strike real; un abanicazo no puede devolver la pelota.


## Golpe suave — sesión 019

BasicShot.touch_weight mezcla intención corta según carga y componente abajo. target_for_aim incluye esa profundidad para marcador; resultado al contacto aplica control de dirección según calidad. solve_velocity conserva firma previa con argumentos opcionales touch/contact y añade arco corto resuelto por búsqueda de duración en modelo físico existente, con límite horizontal. Debilidad por potencia insuficiente y mala calidad reduce componente vertical después de asistencia. Evento hit añade touch y shot_type (chiquita/defense/drive); perfect reconoce también golpe suave preparado. Presentación consume clase existente sin nueva autoridad de contacto. Valores exportados, sin cambios en BallSimulation o cámara.
