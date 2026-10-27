# Entorno y primeros pasos

## Situación comprobada al 27/10/2026 — sesión 002

- Python y Git disponibles por línea de comandos.
- Godot portátil descargado en `../../work/tools/godot/Godot_v4.7.2-stable_linux.x86_64` respecto de la raíz del proyecto. No se añadió al PATH ni se modificó la instalación del sistema.
- Carpeta del proyecto: `outputs/padel-arcade` dentro de este chat.
- Versión objetivo: **Godot 4.7.2 estable, edición estándar**, con GDScript; versión consultada en el archivo oficial. No se necesita edición .NET.
- Motor verificado: `4.7.2.stable.official.ed1daf0bf`. Proyecto importado y ejecutado; exportación de build aún pendiente.

## Preparación

1. Descargar la edición estándar para el sistema operativo desde el [archivo oficial de Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/).
2. Abrir el ejecutable del editor. No es necesario instalar complementos para la escena inicial.
3. En el administrador de proyectos, elegir **Importar** y seleccionar `game/project.godot`.
4. Esperar importación y abrir la escena principal. Ejecutar con F6 para la escena o F5 para el proyecto.
5. Registrar la versión exacta y errores/resultado en ESTADO.md y BITACORA.md. Si se usa otra versión, registrar antes el cambio y verificar compatibilidad.

La escena actual es un laboratorio visual de cancha/cámara, con cuatro figuras y una pelota animada por trayectoria. Sin colisiones ni golpes. Ver CAMARA.md para controles y capturas.

## Comandos comprobados en este entorno

Desde la raíz del proyecto:

```bash
./tools/run-godot.sh
./tools/run-godot.sh --editor
./tools/run-godot.sh --headless --editor --quit
./tools/run-godot.sh --headless --script res://tests/camera_checks.gd
./tools/run-godot.sh --script res://tests/camera_checks.gd -- --capture
```

El script guarda datos/cache en `.local/`, excluido de Git, para evitar escrituras fuera del proyecto. El ejecutable portátil tiene marcador `_sc_` para sus datos de editor. Para otro ejecutable usar `PADEL_GODOT_BIN=/ruta/a/godot ./tools/run-godot.sh`. En Windows/macOS se puede importar directamente con el editor oficial; este lanzador es para Bash/Linux.

El render gráfico funcionó con Mesa llvmpipe (CPU). Hubo avisos de driver iris/VSync; no se observan errores de scripts. No inferir rendimiento del equipo objetivo a partir de este entorno.

## Comandos equivalentes con Godot en PATH

Ejecutar desde la raíz `padel-arcade`; sustituir `godot` por la ruta real del ejecutable si hace falta:

```bash
godot --version
godot --headless --editor --path game --quit
godot --path game
```

La ejecución sin ventana ayuda a comprobar importación; no prueba encuadre ni sensación de juego. Revisar errores además del código de salida.

## Control de versiones

La carpeta se prepara como repositorio Git local independiente. No se configura remoto ni se publica código. Consultar `git status` desde la raíz para ver los archivos iniciales. Registrar el primer commit cuando estén comprobados los archivos y haya identidad Git configurada; no inventar nombre/correo.

Excluir `.godot/`, builds y archivos locales del editor. Versionar escenas, scripts, recursos, UID generados por Godot que correspondan y documentación. Los builds futuros tendrán carpeta `builds/` y versión identificable.

## Datos que faltan

- Sistema operativo para la primera build (no inferirlo por el entorno del chat).
- CPU, GPU, RAM y resolución del equipo donde se jugará.
- Mando disponible y horas semanales de trabajo.
- Teléfono de prueba y Android/iOS más adelante. Para iOS consultar requisitos de macOS/Xcode al llegar a esa etapa.

No se han instalado SDK de Android/iOS, paquetes externos ni assets de tienda.
