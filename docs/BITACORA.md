# Bitácora de desarrollo

## 27/10/2026 — Sesión 001: arranque

**Pedido:** instalar skills necesarias, crear carpeta/proyecto y documentar plan, decisiones y avances.

**Preparado:** nombre provisional Pádel Arcade; documentos de visión, etapas, decisiones, arquitectura, pruebas, entorno, skills y fuentes; instrucciones de continuidad; dos skills propias; proyecto Godot mínimo con escena estática y referencia visual aportada fuera del runtime.

**Acuerdos recuperados:** PC antes que móvil; cámara de la foto algo más atrás; referencia Virtua Tennis; desarrollo individual; comenzar con Godot.

**Comprobación inicial:** Python y Git disponibles; Godot no encontrado en PATH. El directorio del chat no es un repositorio Git utilizable.

**Skills:** creadas con Skill Creator, validadas e instaladas en la carpeta personal; hashes SHA-256 coincidentes con las fuentes. La validación se ejecutó con `/usr/bin/python3` porque el Python por defecto no incluye PyYAML. El entorno requirió permiso sobre la carpeta padre para poder crear los destinos. No se descargaron skills de terceros.

**Control de versiones:** repositorio local inicializado en `main`, sin remoto. Primer punto de recuperación: commit `Iniciar proyecto de padel y documentar plan de desarrollo`.

**Verificación de archivos:** enlaces Markdown locales resueltos, referencias internas y ruta principal de escena coherentes, imagen idéntica al adjunto por SHA-256 y skills válidas. Revisión estática, sin motor.

**Límite:** no se ejecutó gameplay ni importación del motor. La escena no tiene física ni controles.

**Continuación:** P05 y después E1. MVP, estilo, formato de partido y detalles de control siguen siendo propuestas para validar, no características implementadas.

## 27/10/2026 — Sesión 002: cancha y laboratorio de cámara

**Pedido:** continuar con los siguientes pasos, manteniendo control por etapas.

**Hecho:** Godot 4.7.2 portátil descargado de distribución oficial; importación y ejecución; cancha provisional con líneas, red y cerramientos; cuatro figuras; pelota de trayectoria visual; tres cámaras; atenuación de cerramiento cercano; controles de comparación y lanzador local. Se consultaron las secciones de geometría de FIP y documentación Camera3D/Viewport.

**Iteración visual:** el primer encuadre dejaba la cancha demasiado pequeña; se bajó/acercó la cámara, ajustó iluminación y cambió atenuación a alpha de material. Se generaron seis capturas a 720p/360p y se inspeccionaron vistas principales.

**Pruebas:** importación sin errores de scripts, encuadre geométrico de extremos/101 puntos por trayectoria en tres cámaras y dos resoluciones (0 fuera), pausa/reinicio/alpha. Ver PRUEBAS.md y JSON. Mesa usó render por CPU con avisos de driver; no se mide rendimiento de PC objetivo.

**Documentación:** estado, plan, decisiones, arquitectura, entorno, fuentes y pruebas actualizados. P05/P10–P14 completados a nivel de blockout; P15 y datos del equipo P06 siguen pendientes.

**Límites:** sin colisiones, golpes, IA ni reglas. Trayectoria programada y pelota visual ampliada; lateral sin puertas. Falta validación humana de cámara y legibilidad móvil. No se inició E2 antes de revisar el encuadre.

**Continuación:** revisar vistas 1/2/3 con el usuario y después P20. Punto de recuperación de esta sesión guardado en Git al cierre.
