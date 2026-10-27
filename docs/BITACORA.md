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


## 27/10/2026 — Sesión 003: perfil lateral de rejas

**Pedido:** el usuario aprobó el encuadre y observó que los laterales tenían altura uniforme incorrecta.

**Revisión:** consulta del reglamento FIP, The Court → Sides, variante de cristal: extremo de 2 m hasta 4 m de altura; resto del lateral a 3 m. Mantener vidrio de 3 m en los 4 m desde cada fondo.

**Cambio:** añadir reja sobre vidrio en las cuatro esquinas, postes altos y travesaños separados por altura; reutilizar generación de malla para centro y esquinas. Mantener cámaras, personajes, trayectoria y atenuación cercana.

**Verificación:** Godot importó sin errores de scripts; seis capturas regeneradas; cámara principal inspeccionada. Comprobaciones existentes de cámara, pausa, reinicio y alpha aprobadas, sin puntos fuera de cuadro. Primer render bloqueado por socket gráfico; repetido con permiso local concedido.

**Continuidad:** P15 aprobado, próxima tarea P20. Persisten límites del blockout: sin accesos ni colisiones, malla visual simplificada y pelota sin física. Guardado en Git al cierre.


## 27/10/2026 — Sesión 004: laboratorio de rebotes

**Pedido:** avanzar al siguiente paso acordado: gravedad, colisiones y lanzamientos repetibles.

**Implementación:** colliders independientes y etiquetados para piso, vidrio, reja y red; CharacterBody3D con integración controlada y barridos move_and_collide; parámetros por superficie, reposo y registro ordenado de impactos. Física a 120 Hz. Siete escenarios F1–F7, reinicio/pausa/repetición, estela y marcas de contacto. El modo de trayectoria visual anterior se conserva únicamente para regresión de cámara.

**Decisiones:** se evaluaron responsabilidades de cuerpo rígido, cuerpo controlado y detección analítica sin implementar tres alternativas. Elegido cuerpo controlado para relanzamientos y eventos explícitos. Radio ampliado 0.105 m y valores de rebote son provisionales. Máximo 60 m/s y ocho impactos por paso; sin giro ni azar de reja.

**Validación:** importación sin errores de scripts; 13 escenarios físicos y controles aprobados; comprobación a 30/60/120 FPS programados en procesos separados, misma posición/velocidad/contactos tras 2 s. Cámara conservada y pruebas previas aprobadas. Video de cuatro segundos capturado con render real; entorno Mesa llvmpipe, sin afirmaciones de rendimiento. Resultados y tolerancias en PRUEBAS.md.

**Corrección de pruebas:** primer intento del ejecutor FPS accedía a escena sin terminar carga; se corrigió la sincronización y se repitieron los tres procesos exitosamente. Permiso de conexión gráfica local concedido para captura.

**Documentación:** guía LABORATORIO_PELOTA.md y estado/plan/decisiones/arquitectura/entorno/fuentes/pruebas actualizados. E2 completada como laboratorio inicial, con calibración jugable todavía pendiente.

**Continuación:** revisar sensación de rebotes con el usuario y luego movimiento/primer golpe (P30–P33). Todavía sin jugador controlable, rivales, reglas ni marcador. Guardar punto de recuperación de sesión en Git.


## 27/10/2026 — Sesión 005: calibración por feedback

**Pedido:** globo con vuelta excesiva, reja demasiado parecida al vidrio, mayor amortiguación del blindex y confirmar ausencia de giro.

**Diagnóstico:** F7 anterior chocaba primero con vidrio, no con piso. Se reprodujo el orden y se anotaron tiempos antes de modificar. Vidrio retenía demasiada velocidad para la sensación buscada y la reja era una reflexión sin dispersión.

**Cambio:** F7 ajustado, vidrio 0.68/0.90, reja 0.48/0.82 con desvíos laterales/verticales por semilla. R repite; N varía. Sin creación de energía ni salida de la perturbación a través de la reja. No se implementó giro y quedó explicitado como pendiente P44.

**Pruebas:** 13 regresiones físicas aprobadas; nuevo globo piso→vidrio→piso con segundo pique en lado rival; veinte semillas de reja con variación en ambos sentidos, repetibilidad y pérdida de energía; entrada N comprobada. Caso de reja a 30/60/120 FPS programados coincide tras dos segundos. Resultados en PRUEBAS.md. Cámara y jugadores no modificados.

**Continuación:** seguir calibrando con juego observado y después movimiento/primer golpe; los efectos se diseñarán por separado. Documentación y punto de recuperación de sesión guardados al cierre.


## 27/10/2026 — Sesión 006: fricción y reposo

**Pedido:** la pelota seguía picando/rodando demasiado después de reja o vidrio; el globo terminaba llegando a red.

**Diagnóstico medido:** hasta reposo, retorno de globo 9.75 m y máximo de reja 9.78 m en veinte semillas, pese a que el primer ajuste de segundo pique pasaba. Faltaba disipar suficiente movimiento tangencial en los contactos con piso.

**Cambio:** fricción tangencial por impulso en cada pique, rodadura con desaceleración constante, restituciones piso/vidrio/reja y retenciones revisadas. No se cambió el lanzamiento del globo ni se insertaron topes de distancia. Repetición apagada al abrir y título “detenida”.

**Resultado:** globo 2.00 m de retorno y reja máximo 4.25 m, con detención real. 22 lanzamientos de recorrido y estimación analítica de rodadura aprobados; 13 regresiones físicas y calibración de veinte semillas aprobadas. Render programado 30/60/120 coincide. Criterio de F2 ajustado por tratarse de un drive más rápido; detalle en PRUEBAS.md.

**Continuidad:** revisar sensación de esta versión antes de avanzar a movimiento/primer golpe. Giro sigue pendiente. Documentación, informes comparativos y videos de lanzamiento completo actualizados. Guardado en Git al cierre.
