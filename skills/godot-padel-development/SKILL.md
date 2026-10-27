---
name: godot-padel-development
description: Desarrollar y depurar Pádel Arcade con Godot y GDScript, incluyendo cancha 3D, cámara, pelota, golpes e IA de parejas. Usar para este juego; no para otros proyectos Godot por defecto.
---

# Desarrollo de Pádel Arcade

Localizar la raíz por README.md y game/project.godot; no asumir que coincide con el directorio actual. Leer AGENTS.md, docs/ESTADO.md, la etapa activa de docs/PLAN.md y las decisiones relevantes de docs/DECISIONES.md. Si no están accesibles, pedir la ubicación del proyecto en vez de inventar su estado. Consultar docs/ENTORNO.md para la versión fijada.

## Implementar

- Separar simulación de pelota, reglas, animación, cámara y dispositivo de entrada. Los botones expresan acciones para añadir controles táctiles después.
- Simular en pasos físicos fijos. Usar barridos o subpasos cuando un desplazamiento pueda atravesar una pared o la red; resolver el primer impacto si hay varias superficies en un paso.
- Emitir contactos ordenados con superficie, lado y último golpeador. Un contacto persistente no debe convertirse en dos piques por repetirse en frames consecutivos.
- Distinguir ayudas arcade de reglas deportivas. Confirmar las expectativas reglamentarias contra la fuente FIP registrada en docs/FUENTES.md antes de implementarlas.
- Exponer parámetros de pelota, golpes y cámara en recursos o Inspector. Preferir GDScript tipado y escenas por responsabilidad; no crear infraestructura genérica sin necesidad.
- Verificar API contra la versión fijada y documentación oficial. Explicar cambios como porciones pequeñas y comprobables para alguien que está aprendiendo el motor.

## Validar y continuar

Cuando el motor esté disponible, comprobar importación con `godot --headless --editor --path game --quit` desde la raíz y ejecutar el caso afectado. Adaptar el nombre del ejecutable al entorno real. Sin ventana no se puede validar diversión, animación ni legibilidad: complementar con juego real. Si falta el motor, registrar pruebas pendientes; no afirmar que compila.

Al cerrar una sesión actualizar docs/ESTADO.md, tareas afectadas de docs/PLAN.md y una entrada en docs/BITACORA.md. Cambios de alcance o arquitectura van en docs/DECISIONES.md. Anotar pruebas ejecutadas, resultados y siguiente paso reproducible.
