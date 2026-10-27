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
