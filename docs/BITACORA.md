# Registro de decisiones

Fecha inicial: 27/10/2026. Acordado refleja la conversación; decisión técnica inicial es reversible; propuesta todavía debe validarse.

| ID | Estado | Elección y motivo | Revisión |
| --- | --- | --- | --- |
| D01 | Acordado | PC primero, celular después | E8 |
| D02 | Acordado | Cámara como foto, algo más atrás para ver pared cercana | E1 |
| D03 | Acordado | Experiencia inspirada en Virtua Tennis, deporte pádel | E4 |
| D04 | Acordado | Una persona, aprendiendo el motor | Cada estimación |
| D05 | Acordado | Comenzar con Godot | Ante limitación concreta |
| D06 | Verificada | GDScript tipado y Godot estándar 4.7.2, ejecutado en modo portátil en sesión 002 | Al actualizar motor |
| D07 | Técnica inicial | Renderer Compatibility como punto de partida sencillo | E1 y prueba móvil; medir |
| D08 | Propuesta | Humano + compañero IA contra dos rivales IA | Antes de E5 |
| D09 | Técnica inicial | Separar pelota, reglas, entradas y presentación | E2–E3 |
| D10 | Propuesta | Arte estilizado y cerramiento cercano atenuable | E1 |
| D11 | Técnica inicial | Dos skills propias versionadas; visuales existentes según tarea | Primeras sesiones |
| D12 | Pendiente | Modelo de simulación y tolerancias | P20 |
| D13 | Pendiente | Teclas, potencia, ayudas de contacto | E3–E4 |
| D14 | Pendiente | Jugador fijo o cambio automático/manual | E5 |
| D15 | Pendiente | Formato del partido, puntuación y reglas omitidas | P60 |
| D16 | Pendiente | SO de primera build, PC de referencia y teléfono | P06/P80 |
| D17 | Técnica inicial | “Pádel Arcade” es solo nombre de trabajo | Antes de publicar |

Para cambiar una decisión: añadir fecha, contexto, alternativas relevantes, elección, consecuencias y tareas afectadas. Conservar la anterior como sustituida. No convertir propuestas técnicas en preferencias confirmadas del usuario.


## 27/10/2026 — decisiones de prototipo

- **D18, técnica inicial:** mantener Godot y sus datos dentro del espacio del chat. Motivo: entorno con directorios personales restringidos. No modificar instalación del sistema. Impacto: usar tools/run-godot.sh.
- **D19, propuesta visual:** cámaras 1/2/3 a (0,10,18), (0,12,21), (0,9,17), FOV vertical 52°, objetivo (0,0.5,0). Referencia inicial: vista 1, todavía sin elección del usuario. Impacto: P12/P15.
- **D20, simplificación explícita:** figuras y cancha son blockout; cerramiento lateral simplificado sin puertas, sin colisiones. La pelota recorre una curva programada y tiene radio visual 0.105 m para facilitar lectura. No interpretar como física, reglamento o arte final. Impacto: P10/P11 y futuro P20.
- **D21, técnica inicial:** atenuación cercana mediante alpha de materiales y desactivación de sombra de esas piezas, para evitar oclusión visual con Compatibility. Conserva la indicación de pared; el futuro collider debe ser independiente. Impacto: P13/E2.


## Incorporaciones de sesión 002

- Archivo oficial Linux estándar descargado desde el enlace de distribución de Godot 4.7.2 citado arriba; versión confirmada ejecutando el binario. Herramienta local, no asset del juego.
- [Camera3D](https://docs.godotengine.org/en/stable/classes/class_camera3d.html) y [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html): proyección, encuadre y captura.
- FIP, secciones The Court/Net: geometría interior y referencias principales de líneas/red. El blockout lateral no reproduce todavía todas las variantes de cerramiento y accesos.
- `scripts/court.gd` y `scripts/camera_lab.gd`: geometría, personajes provisionales y colores creados en el proyecto, sin assets externos.
- `docs/previews/*.png`: capturas de la escena renderizada con Godot, no concept art ni fotografías.


## 27/10/2026 — Sesión 002: cancha y laboratorio de cámara

**Pedido:** continuar con los siguientes pasos, manteniendo control por etapas.

**Hecho:** Godot 4.7.2 portátil descargado de distribución oficial; importación y ejecución; cancha provisional con líneas, red y cerramientos; cuatro figuras; pelota de trayectoria visual; tres cámaras; atenuación de cerramiento cercano; controles de comparación y lanzador local. Se consultaron las secciones de geometría de FIP y documentación Camera3D/Viewport.

**Iteración visual:** el primer encuadre dejaba la cancha demasiado pequeña; se bajó/acercó la cámara, ajustó iluminación y cambió atenuación a alpha de material. Se generaron seis capturas a 720p/360p y se inspeccionaron vistas principales.

**Pruebas:** importación sin errores de scripts, encuadre geométrico de extremos/101 puntos por trayectoria en tres cámaras y dos resoluciones (0 fuera), pausa/reinicio/alpha. Ver PRUEBAS.md y JSON. Mesa usó render por CPU con avisos de driver; no se mide rendimiento de PC objetivo.

**Documentación:** estado, plan, decisiones, arquitectura, entorno, fuentes y pruebas actualizados. P05/P10–P14 completados a nivel de blockout; P15 y datos del equipo P06 siguen pendientes.

**Límites:** sin colisiones, golpes, IA ni reglas. Trayectoria programada y pelota visual ampliada; lateral sin puertas. Falta validación humana de cámara y legibilidad móvil. No se inició E2 antes de revisar el encuadre.

**Continuación:** revisar vistas 1/2/3 con el usuario y después P20. Punto de recuperación de esta sesión guardado en Git al cierre.
