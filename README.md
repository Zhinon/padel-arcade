# Pádel Arcade — nombre provisional

Juego de pádel 3D para PC, con jugabilidad arcade inspirada en Virtua Tennis y adaptación posterior a celular. Desarrollo individual asistido por Codex. Documentación en español.

**Estado al 27/10/2026, sesión 002:** laboratorio de cancha y cámara ejecutado con Godot 4.7.2. Cancha provisional, cuatro figuras, tres cámaras y trayectoria visual de globo. Pruebas de encuadre aprobadas; revisión del usuario pendiente. Todavía no hay física ni golpes.

![Cámara de referencia](docs/previews/camera-1-1280x720.png)

En Linux, ejecutar `./tools/run-godot.sh` desde esta carpeta. **1/2/3:** cambiar cámara; **G:** atenuar cerramiento cercano; **Espacio:** pausar trayectoria; **R:** reiniciar. [Comparar las cámaras](docs/CAMARA.md).

## Por dónde seguir

1. Leer [Estado y siguiente sesión](docs/ESTADO.md).
2. Consultar el [Plan por etapas](docs/PLAN.md) y la [visión del juego](docs/JUEGO.md).
3. Seguir la [preparación del entorno](docs/ENTORNO.md) para abrir `game/project.godot`.
4. Completar cancha y cámara antes de implementar golpes.

## Mapa del proyecto

| Ruta | Contenido |
| --- | --- |
| `game/` | Proyecto importable en Godot |
| `docs/JUEGO.md` | Experiencia, controles propuestos y alcance |
| `docs/PLAN.md` | Etapas, tareas y condiciones para avanzar |
| `docs/DECISIONES.md` | Acuerdos, propuestas y decisiones pendientes |
| `docs/ESTADO.md` | Punto exacto de continuidad y próxima tarea |
| `docs/BITACORA.md` | Cambios y comprobaciones por sesión |
| `docs/ARQUITECTURA.md` | División técnica prevista |
| `docs/PRUEBAS.md` | Escenarios y resultados |
| `docs/ENTORNO.md` | Herramientas, apertura y control de versiones |
| `docs/SKILLS.md` | Skills e instalación |
| `docs/FUENTES.md` | Fuentes y procedencia de assets |
| `docs/references/` | Imagen de referencia aportada |
| `skills/` | Copias versionadas de las skills propias |

## Forma de trabajo

Una tarea pequeña a la vez: implementar, probar, revisar juntos y documentar. Estimaremos fechas después de completar un ciclo real. Una etapa se termina por su evidencia, no por haber creado archivos.

Virtua Tennis es una referencia de experiencia. La fotografía es una referencia de cámara, no un asset para publicar dentro del juego. Personajes, audio y assets definitivos serán propios o tendrán permisos registrados.
