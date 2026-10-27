# Arquitectura inicial — propuesta

Este documento describe responsabilidades previstas. Solo existe la escena técnica `game/scenes/main.tscn`; los sistemas siguientes aún no están implementados. Crear carpetas y abstracciones cuando se necesiten.

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

## Experimento pendiente P20

Comparar una implementación física con cuerpo rígido y barridos frente a integración propia con pruebas de trayectoria. Elegir según control del tiro, robustez a velocidad alta y facilidad para predecir llegada en IA. No construir dos motores completos. Documentar la elección antes de desarrollar golpes.

## Preparación móvil

Las acciones de juego no referencian teclas directamente. Física y reglas no dependen de resolución. UI y cámara tienen parámetros independientes. Perfil de rendimiento y controles táctiles se validan en dispositivo; no quedan resueltos por estas decisiones.
