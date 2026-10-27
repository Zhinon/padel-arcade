# Entorno y primeros pasos

## Situación comprobada al 27/10/2026

- Python y Git disponibles por línea de comandos.
- `godot` y `godot4` no encontrados en PATH. Esto no descarta una instalación en otra ubicación.
- Carpeta del proyecto: `outputs/padel-arcade` dentro de este chat.
- Versión objetivo: **Godot 4.7.2 estable, edición estándar**, con GDScript; versión consultada en el archivo oficial. No se necesita edición .NET.
- El proyecto aún no fue importado, ejecutado ni exportado con el motor.

## Preparación

1. Descargar la edición estándar para el sistema operativo desde el [archivo oficial de Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/).
2. Abrir el ejecutable del editor. No es necesario instalar complementos para la escena inicial.
3. En el administrador de proyectos, elegir **Importar** y seleccionar `game/project.godot`.
4. Esperar importación y abrir la escena principal. Ejecutar con F6 para la escena o F5 para el proyecto.
5. Registrar la versión exacta y errores/resultado en ESTADO.md y BITACORA.md. Si se usa otra versión, registrar antes el cambio y verificar compatibilidad.

Se espera una escena estática con piso azul, marcador central de red y cámara elevada. No tiene pelota, jugadores, controles ni colisiones. La escena es una base técnica, no la cancha terminada.

## Comandos cuando exista ejecutable

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
