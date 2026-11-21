# Pádel Arcade — nombre provisional

Juego de pádel 3D para PC, con jugabilidad arcade inspirada en Virtua Tennis y adaptación posterior a celular. Desarrollo individual asistido por Codex. Documentación en español.

**Prototipo en desarrollo.** Incluye práctica individual y peloteo con rival de entrenamiento, física de pelota con rebotes en piso, vidrio, reja y red, carga de golpes, defensa, globo, chiquita, smash, remates x3/x4 y volea contextual. Todavía no incluye partido completo ni sistema de puntuación.

## Demostración

![Peloteo con rival de entrenamiento](docs/previews/rival-training.png)

[Video del rival de entrenamiento](docs/previews/rival.mp4) · [Práctica](docs/PRACTICA.md) · [Pruebas y límites](docs/PRUEBAS.md)

## Tecnología

Godot 4.7.2 y GDScript. Geometría y animación procedural, sonidos sintéticos propios y escenarios reproducibles de prueba. Desarrollo individual asistido por IA, con iteración y validación humana de la jugabilidad.

![Contacto de revés: vista cercana de revisión](docs/previews/pose-backhand-contact.png)

La vista cercana es de revisión; el juego conserva la cámara general de cancha.

En Linux: `./tools/run-godot.sh`. **WASD/flechas:** mover; **R:** recibir pelota; **H:** recibir globo para rematar; **J:** plano/volea/smash contextual; **K:** globo; **J+K juntos:** especial x3 W+A/D / x4 S cerca de red al ~90%; mantener carga y soltar fija (referencia 90%); contacto automático; **I / LB del mando:** pelotear con rival (R reinicia, nueva pelota automática al fallar); **T:** cambiar zona en práctica individual; **P:** pausa; **F8:** laboratorio.

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
