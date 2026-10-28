# Pádel Arcade — nombre provisional

Juego de pádel 3D para PC, con jugabilidad arcade inspirada en Virtua Tennis y adaptación posterior a celular. Desarrollo individual asistido por Codex. Documentación en español.

**Estado al 28/10/2026, sesión 016:** práctica con preparación que planta al jugador, carga fijada al soltar y contacto automático. Tiro preparado y defensa tardía diferenciados; sobrecarga con riesgo de cerramiento directo. Se conserva la física calibrada y el laboratorio anterior. Sensación de control aceptada por el usuario. Derecha y revés con giro de torso/cadera, codos y apoyos; tres sonidos provisionales; M silencia. Sin rival ni partido todavía.

![Contacto de revés: vista cercana de revisión](docs/previews/pose-backhand-contact.png)

La vista cercana es de revisión; el juego conserva la cámara general de cancha.

En Linux: `./tools/run-godot.sh`. **WASD/flechas:** mover; **R:** recibir pelota; **Espacio:** mantener para cargar, soltar para fijar (ideal 90%); contacto automático; **T:** cambiar zona; **P:** pausa; **F8:** laboratorio.

[Guía y video de práctica](docs/PRACTICA.md). [Laboratorio de rebotes](docs/LABORATORIO_PELOTA.md).

## Por dónde seguir

1. Leer [Estado y siguiente sesión](docs/ESTADO.md).
2. Probar la [práctica](docs/PRACTICA.md) y revisar controles antes de añadir tiros avanzados.
3. Seguir la [preparación del entorno](docs/ENTORNO.md) para abrir `game/project.godot`.
4. Registrar la prueba humana de E3 y ajustar antes de avanzar a E4.

## Mapa del proyecto

| Ruta | Contenido |
| --- | --- |
| `game/` | Proyecto importable en Godot |
| `docs/JUEGO.md` | Experiencia, controles propuestos y alcance |
| `docs/PRACTICA.md` | Controles, primer golpe y validación de E3 |
| `docs/LABORATORIO_PELOTA.md` | Controles, parámetros y evidencia de rebotes |
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
