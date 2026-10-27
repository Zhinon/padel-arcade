# Skills del proyecto

## Selección

Se crearon dos skills pequeñas adaptadas al proyecto usando Skill Creator. No se descargó código de terceros ni se instaló Game Studio, cuyo enfoque de navegador no coincide con la elección de Godot.

| Skill | Uso | Estado al cierre de sesión 001 |
| --- | --- | --- |
| `godot-padel-development` | Simulación, escenas, controles, arquitectura y continuidad | Instalada y validada; copia fuente en `skills/` |
| `padel-gameplay-testing` | Escenarios físicos, reglas, golpes, parejas y cámara | Instalada y validada; copia fuente en `skills/` |
| Skill Creator | Crear y mantener las propias | Ya disponible |
| Imagegen | Referencias visuales y texturas cuando haga falta | Ya disponible |
| Impeccable / UI UX Pro Max | Marcador, menús y controles táctiles | Ya disponibles; elegir según tarea |

Crear estas skills no instala Godot ni agrega conocimientos reglamentarios verificados automáticamente. Sus procedimientos apuntan a las fuentes y documentos del proyecto.

## Copias y descubrimiento

Las fuentes versionadas están en `skills/`. Destinos personales previstos:

```text
/home/zhinon/.codex-personal/skills/godot-padel-development/
/home/zhinon/.codex-personal/skills/padel-gameplay-testing/
```

Instaladas el 27/10/2026 con permiso de filesystem concedido para crear las dos carpetas. Se verificó que los archivos instalados coinciden por SHA-256 con las fuentes del proyecto. No se modificaron otras skills.

Ambas copias pasaron `quick_validate.py` con `/usr/bin/python3` (PyYAML disponible allí). El descubrimiento de las skills personales estará disponible a partir del siguiente turno. En este proyecto también pueden leerse las copias locales indicadas en AGENTS.md.

Al actualizar una skill: editar la copia del proyecto, ejecutar `quick_validate.py`, sincronizar la copia personal y registrar el cambio. No reemplazar una skill existente sin revisar primero sus diferencias.
