# Fuentes y assets

Consultadas el 27/10/2026. Revisar la documentación de la versión fijada antes de implementar API concretas.

## Motor y flujo de trabajo

- [Godot 4.7.2 estable](https://godotengine.org/download/archive/4.7.2-stable/): versión objetivo inicial.
- [Características de Godot](https://godotengine.org/features/): 3D y plataformas.
- [Licencia de Godot](https://godotengine.org/license/): MIT; revisar atribuciones al distribuir.
- [GDScript y lenguajes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_languages.html): lenguaje de inicio.
- [Estilo GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- [Control de versiones](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html).

## Deporte

- [Documentos oficiales de FIP](https://www.padelfip.com/documents/).
- [Rules of Padel, PDF oficial](https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf): referencia inicial para geometría y futura interpretación de reglas. El piso provisional usa las dimensiones interiores 10×20 m. El reglamento completo aún debe revisarse al implementar P60–P64.

No se declara conformidad reglamentaria del prototipo. Registrar por separado cada simplificación arcade y las variantes adoptadas.

## Registro de assets

| Archivo/elemento | Procedencia | Uso y permisos |
| --- | --- | --- |
| `references/camera-reference.png` | Imagen adjunta por el usuario en este chat | Referencia interna de cámara; autor/licencia de publicación no establecidos; no se incluye en el runtime |
| Piso y red provisionales de `main.tscn` | Geometría creada en el proyecto | Marcadores de escala; no son assets definitivos |

Virtua Tennis es una referencia declarada por el usuario de ritmo y controles. No se copiaron código, personajes, sonidos, interfaces ni assets de ese juego.

Al incorporar assets registrar autor, enlace original, licencia, atribución requerida y modificaciones. Antes de distribuir revisar qué archivos del paquete se incluyen; la foto debe quedar fuera del juego y de material promocional.

## Incorporaciones de sesión 002

- Archivo oficial Linux estándar descargado desde el enlace de distribución de Godot 4.7.2 citado arriba; versión confirmada ejecutando el binario. Herramienta local, no asset del juego.
- [Camera3D](https://docs.godotengine.org/en/stable/classes/class_camera3d.html) y [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html): proyección, encuadre y captura.
- FIP, secciones The Court/Net: geometría interior y referencias principales de líneas/red. El blockout lateral no reproduce todavía todas las variantes de cerramiento y accesos.
- `scripts/court.gd` y `scripts/camera_lab.gd`: geometría, personajes provisionales y colores creados en el proyecto, sin assets externos.
- `docs/previews/*.png`: capturas de la escena renderizada con Godot, no concept art ni fotografías.


## Revisión de laterales — sesión 003

Fuente: PDF FIP oficial citado arriba, The Court → Sides, variante 2 de cristal. Se implementaron las extensiones de reja de esquina y su transición al tramo central. Las dimensiones generales no implican homologación completa: accesos, espesor/tejido de malla y colisiones siguen siendo provisionales.


## Simulación — sesión 004

- [PhysicsBody3D.move_and_collide](https://docs.godotengine.org/en/stable/classes/class_physicsbody3d.html): desplazamiento con detección de colisión.
- [KinematicCollision3D](https://docs.godotengine.org/en/stable/classes/class_kinematiccollision3d.html): normales, posiciones y recorrido de contacto.
- Código de simulación, lanzador, estela y marcas desarrollado dentro del proyecto, sin assets externos. Restitución y radio ampliado son parámetros de diseño provisionales.
- `previews/ball-lab.png` y `previews/ball-lab.mp4`: captura del motor con avance temporal fijo; no constituyen medición de FPS del equipo objetivo.


## Calibración — sesión 005

Las pérdidas de velocidad, desvíos y lanzamiento de globo son valores de diseño ajustados tras observación del usuario. No se usaron coeficientes empíricos de una investigación como si fueran valores medidos del prototipo. Se conservó la variante geométrica de cancha ya documentada.

`previews/fence-lab.mp4` muestra el mismo lanzamiento contra reja con semilla 42 y después 43; `ball-lab.mp4` se regeneró con el vidrio calibrado. Capturas del motor con avance fijo, sin simulación de giro ni medición de rendimiento.


## Fricción y reposo — sesión 006

Parámetros de diseño ajustados por feedback, sin nuevas mediciones empíricas externas. Validación de rodadura contra distancia de parada v²/(2a). `previews/lob-lab.mp4` muestra ocho segundos hasta reposo; `fence-lab.mp4` se regeneró con dos lanzamientos de cuatro segundos. La captura F2 anterior permanece como histórica, identificada en la guía.


## Práctica — sesión 007

- [Input](https://docs.godotengine.org/en/stable/classes/class_input.html): mapa de acciones, teclado y mando.
- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): prioridades de procesamiento, entrada y notificaciones de foco.
- [CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html): cuerpo de jugador; el movimiento final usa barridos move_and_collide con delta explícito.
- PlayerMotor, BasicShot, PracticeInput, panel y aro/objetivo son código y geometría creados en el proyecto. No se incorporaron modelos, fuentes, sonidos o animaciones externas.
- `previews/practice.png`, `practice-640x360.png` y `practice.mp4`: capturas del motor con conductor sintético de prueba. El video no corresponde a un rival implementado.


## Presentación de golpe — sesión 012

- `game/audio/impact-normal.wav`, `impact-perfect.wav`, `impact-defense.wav`: creados en este proyecto mediante síntesis de ruido/transitorios/resonancia con semilla fija. No incorporan muestras, música o grabaciones externas. Generador reproducible: `tools/generate-impact-audio.py`. Assets provisionales del proyecto, sin atribución externa necesaria. Formato/energía en previews/audio-checks.json.
- Animación procedural, brazo, destello y código ImpactFeedback creados en el proyecto; capturas impact-*.png extraídas del motor. Video con audio mezclado desde eventos registrados y WAV originales (no captura del mezclador del sistema).
- API consultada: [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) y [Quaternion](https://docs.godotengine.org/en/stable/classes/class_quaternion.html), documentación oficial; integración ejecutada con Godot 4.7.2.


## Poses de derecha/revés — sesión 014

Pivotes, geometría articulada, codos, zapatos, cara y animación generados como código del proyecto, sin modelos/animaciones externos. Capturas pose-*.png provienen del ejecutor stroke_pose_checks con cámara cercana de prueba; no representan cambio de encuadre de juego.
