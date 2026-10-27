# Arquitectura inicial — propuesta

Este documento describe responsabilidades previstas. Existe un laboratorio visual en `game/scenes/main.tscn`, con `scripts/court.gd` para geometría y `scripts/camera_lab.gd` para figuras, cámaras y trayectoria de prueba. `tests/camera_checks.gd` verifica encuadre y controles del laboratorio. En E2 se añadieron `scripts/ball_simulation.gd` (CharacterBody3D con integración y barridos), `scripts/launch_scenarios.gd` (condiciones iniciales) y superficies StaticBody3D etiquetadas en Court. Las responsabilidades de jugadores, reglas y partido de la tabla todavía no se implementaron. Crear carpetas y abstracciones cuando se necesiten.

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
