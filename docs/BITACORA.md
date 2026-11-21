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


## 27/10/2026 — Sesión 007: primera práctica jugable

**Pedido:** avanzar tras aprobar la calibración de rebotes. Alcance: movimiento y primer golpe, antes de rivales/partido.

**Implementación:** InputAdapter con acciones de teclado/mando, jugador con cápsula y barridos/límites de mitad cercana, preparación y ventana de golpe, cálculo de velocidad hacia objetivo rival con margen de red, registro de strike que conserva historial/reloj/RNG. R alimenta, T cambia zona, P pausa, F8 alterna laboratorio. La escena abre en práctica y espera R. Física E2 sin cambiar coeficientes.

**Presentación:** aro del jugador, destino rival, movimiento procedural de pala y panel de controles/feedback. Se aplicaron criterios generales de UI/UX Pro Max; búsquedas no dieron una referencia específica Godot/juego. El panel se compactó en ventana pequeña tras inspección visual.

**Correcciones durante implementación:** tipo Vector2 explícito para entrada; movimiento con delta explícito al detectar diferencia en prueba fuera del callback; pausa restaura estado previo aun antes del primer tick; práctica no hereda el atajo L de repetición del laboratorio. Se aislaron modos en los ejecutores anteriores.

**Pruebas:** 90 trayectorias por red/aterrizaje, alcance/preparación/altura, una sola strike, movimiento diagonal, límites, pausa/foco/F8 e interfaz 720p/360p. Conductor de 30 s: diez contactos. Grabación de seis segundos con eventos de Godot: dos contactos. Regresiones de pelota/calibración/recorrido/FPS aprobadas, mismos 2.00/4.25 m de E2. Sin prueba de mando físico ni comodidad humana.

**Continuidad:** P30–P33 completados técnicamente, P34 pendiente con usuario. Después ajustar control antes de E4. Sin giro, tiros avanzados del jugador, rival, reglas ni marcador. Documentación y evidencia guardadas; punto de recuperación Git al cierre.


## 28/10/2026 — Sesión 008: revisión del diseño de golpes

**Pedido:** evaluar viabilidad de la descripción extensa inspirada en Virtua Tennis.

**Resultado:** viable; identificadas diferencias con el prototipo (soltar frente a contacto automático, movilidad preparando y calidad dependiente de contexto). Propuesta de liberar para fijar potencia, sin disparar; pendiente de definir con cancelación/caducidad. Riesgo de profundidad revisado contra reglas FIP 12–13 para evitar trasladar líneas de tenis al pádel.

**Registro:** REVISION_CONTROLES_ARCADE.md, tareas P35/P36 y estado actualizados. Sin modificaciones de código ni ejecución de pruebas del motor. Próxima porción: definir semántica de control y validar plantado/apuntado/contacto automático antes de ampliar tipos de tiro.


## 28/10/2026 — Sesión 009: confirmación de mecánicas

**Usuario:** acepta soltar para fijar potencia; define tiro perfecto llegando a tiempo y soltando cerca del 90%. Precisa que el riesgo al 100% es tocar directo el cerramiento rival de fondo o lateral sin pique. Confirma devolución tardía alcanzable con poca potencia y menos dirección.

**Registro:** D43–D45, revisión de controles, plan y estado actualizados para distinguir acuerdos de propuestas. Cancelación/caducidad y calibración siguen pendientes. Sin cambios de código ni pruebas del motor en esta sesión documental.


## 28/10/2026 — Sesión 010: preparación, fijación y contacto automático

**Pedido:** avanzar con los acuerdos de control D43–D45.

**Implementación:** estados de golpe, plantado con frenado, apuntado continuo, fijación de carga al soltar, impacto por llegada también si sigue manteniendo, recuperación rápida. Calidad por tiempo/posición/altura/equilibrio y defensa tardía débil con dirección central. Zona ideal 86–94%; sobrecarga reduce margen hacia fondo/lateral sin RNG. Cancelación al pulsar tras fijar y caducidad 3 s como decisiones técnicas provisionales. Sin alterar cámara o simulación pasiva.

**Correcciones:** tipo bool explícito tras error del compilador; prueba de carga con tolerancia por paso fijo; conductor de prueba espera alinearse antes de plantarse; se ajustó exceso lateral al detectar que aún picaba primero en piso. No se sustituyeron expectativas por resultados para aceptar ese caso: se corrigió la trayectoria.

**Validación:** importación, control/90 trayectorias/diez contactos sintéticos, dos sobrecargas hasta primer cerramiento y regresiones E2 aprobadas. Demostración de dos contactos y capturas 720p/360p actualizadas e inspeccionadas. Avisos Mesa/VSync del render CPU; sin errores de scripts. Se concedió acceso de red para servidor gráfico/puertos locales de Godot.

**Continuidad:** P35/P36 completados técnicamente; P34 pendiente de juego humano. Ajustar carga, alcance, defensa, plantado y recuperación antes de ampliar tiros/IA. Guía, estado, plan, arquitectura y decisiones actualizados; punto Git de cierre.


## 28/10/2026 — Sesión 011: sobrecarga corta que puede tocar red

**Pedido:** usuario conforme con control; solicita posibilidad de red al apuntar hacia abajo con 100%.

**Cambio:** menor altura de salida de tiro corto sobrecargado según carga/dirección/calidad. La ayuda de arco se calcula antes de la penalización, evitando que elimine el riesgo. Menos extensión profunda cuando apunta abajo. Aviso de sobrecarga específico. Cámara y rebotes sin cambios.

**Pruebas:** mismo contacto exigido 90% llega a piso rival, 100% toca red, ejecutados por contacto automático y física. Pruebas anteriores de control, fondo/lateral, 90 trayectorias y diez devoluciones aprobadas; 13 regresiones de pelota aprobadas. Importación sin errores de scripts con avisos del sandbox sobre puertos del editor. Sin nueva prueba visual/humana. Ajuste de altura calibrado tras detectar que una reducción fija inicial todavía pasaba la red.

**Continuidad:** probar este riesgo jugando; mantener P34 antes de avanzar a tiros/IA. Estado, plan, guía, decisiones y pruebas actualizados.


## 28/10/2026 — Sesión 012: pala, brazo y sonidos provisionales

**Pedido:** avanzar con presentación tras aprobación explícita de sensación de juego. Se registra cierre cualitativo de P34, sin inventar duración de prueba humana.

**Implementación:** ImpactFeedback desacoplado de física, preparación/pala/brazo e inclinación, contacto sincronizado y acompañamiento corto. Destello normal/perfecto/defensa; síntesis propia de tres WAV sin samples externos. M silencia. Pausa, relanzamiento y F8 limpian presentación sin cambiar control aceptado.

**Correcciones:** dos vectores tipados tras errores de inferencia; nombres explícitos de brazos al detectar que un nombre duplicado impedía hallar brazo derecho. Destello como ayuda sin profundidad para que no quede oculto por avatar. Ejecutores esperan al mezclador al cerrar tras detectar recursos de audio pendientes en pruebas muy rápidas. La primera grabación perdió foco y quedó pausada: se aisló esa notificación solo en el ejecutor y se forzó dibujado de captura; segunda grabación completa con dos contactos. El juego conserva pausa al perder foco.

**Validación:** tres clases de golpe real, coincidencia de pala, sonido solicitado, silencio, vuelta neutral, movimiento durante seguimiento y física intacta. Regresión jugador (90 trayectorias/diez contactos/riesgos) y 13 escenarios de pelota aprobados. Importación y capturas 720p/360p revisadas. Formato/contenido/energía WAV comprobados; escucha humana pendiente. Demostración actualizada con audio mezclado por eventos de captura, sin grabación del audio del sistema.

**Continuación:** probar presentación con usuario y ajustar volumen/claridad; después globo del jugador (P40). Plan, guía, fuentes, arquitectura, decisiones y estado actualizados; punto Git al cierre.


## 28/10/2026 — Sesión 013: equilibrio sobre la red

**Reporte:** carga 100% hacia abajo, toque en red y pelota queda arriba.

**Diagnóstico:** collider superior plano puede actuar como repisa. Se reprodujo equilibrio aislado: 15/33 casos sin piso después de 5 s, antes de cambiar código. No se reconstruyeron entradas exactas del usuario.

**Cambio:** asistencia localizada de caída para contactos superiores de escaso impulso transversal. Redirige fracción de energía vertical entrante, con tope de rapidez; no mueve posición ni usa RNG. Cara frontal y roces de cruce con impulso quedan intactos.

**Pruebas:** 35 casos después (incluye 15 caídas, 18 tiros al 100% y dos roces), todos llegan al piso; energía, finitud y presupuesto de impactos verificados. Regresiones de pelota/jugador/recorrido aprobadas, valores vidrio/reja conservados. Sin ventana o nueva valoración humana. Documentación e informes antes/después guardados; punto Git al cierre.


## 28/10/2026 — Sesión 014: revés con cuerpo de costado

**Pedido:** revisar muñecos antes del globo: giro de cuerpo en revés y evitar brazo atravesando torso.

**Cambio:** avatar controlado articulado con cadera/torso, codos y dos segmentos por brazo, manos de apoyo en revés, zapatos y apoyos visibles. Selección derecha/revés automática y estable. Preparación anticipa zona de contacto; pala y brazos rodean frente del torso durante seguimiento. Sin cambios en controles, tiempos, golpes o física.

**Revisión:** pruebas de 18 casos y capturas próximas; se ajustó posición del codo para evitar brazo excesivamente estirado, se definió silueta de torso para hacer visible giro y se agregó cuello. La cámara de juego permanece igual. Aprobadas regresiones de impacto/audio y jugador (90 trayectorias/diez contactos). No prueba humana ni rig final.

**Continuación:** usuario revisa derecha/revés y su recuperación; después globo. Documentación e informe de poses guardados, punto Git al cierre. Al abrir la práctica aparecieron errores X11 BadShmSeg; se detuvo y se reabrió con LIBGL_ALWAYS_SOFTWARE=1, sin repetición observada. OpenGL indirecto no funcionó y se detuvo. Sin cambios globales de driver/lanzador.


## 28/10/2026 — Sesión 015: brazos de reposo

**Pedido:** usuario conforme con golpes; brazos se veían quebrados en reposo.

**Causa:** la postura exterior del codo usada para evitar torso durante golpe se reutilizaba con mano/pala bajas, creando un quiebre poco natural. Se separó descanso y se mezcló al finalizar gesto; el primer retorno directo rozaba envolvente conservadora del torso, por lo que se difiere relajación de codo hasta que la mano vuelve al mismo lado. Revisión visual añadió uniones de hombro para cerrar huecos.

**Validación:** 18 casos de golpes y reposo inicial/posterior, codos aproximadamente 170° y 166°, sin inversión de flexión o estiramiento de segmentos. Capturas frontales/laterales inspeccionadas. Regresión de tres impactos/audio aprobada e importación sin errores de scripts. Sin cambios en control ni física; no prueba humana del nuevo reposo. Documentación actualizada y punto Git de cierre.


## 28/10/2026 — Sesión 016: revisión del drive

**Pedido:** usuario conforme con revés, drive se ve raro.

**Diagnóstico:** drive reutilizaba torso cerrado hasta impacto y preparación frontal de pala, obligando brazo a extenderse. Se guardó informe anterior con poses/métricas antes de modificar. Revisión cercana detectó también codo de brazo libre plegado de forma extraña.

**Cambio:** preparación de derecha al costado/atrás, apertura antes de contacto, codo de segmentos equilibrados y brazo libre de contrapeso; seguimiento más alto por delante. Se conserva guía exterior al cruzar para evitar clipping: primera versión sin esa mezcla falló los controles geométricos. Revés y reposo conservados, sin cambios de control/física.

**Pruebas:** 18 casos de poses, apertura previa al contacto, longitudes de brazo en drive cómodo, reposo y contacto exacto aprobados. Seis poses de revés en tres fases coinciden con registro previo. Jugador (90 trayectorias/diez devoluciones) e impacto/audio (tres clases) aprobados. Capturas de derecha de frente/perfil y vista cercana revisadas; importación sin errores de scripts. Opinión humana del nuevo drive pendiente.

**Continuidad:** usuario revisa drive; después globo si presentación resulta cómoda. Informe antes/comparación/actual y documentación guardados, punto Git al cierre.


## 28/10/2026 — Sesión 017: abanicazo al errar

**Pedido:** usuario conforme con drive; al errar quiere que igual tire paletazo al aire.

**Implementación:** evento de fallo separado, detección al pasar zona de contacto sin alcance y gesto local de derecha/revés sin impacto. Pulsación vacía y tardía también responden; cancelación mantiene su sentido. Recuperación corta y movimiento libre. Se comprueba que el intento gastado no capture otra pelota durante gesto.

**Pruebas:** cinco gestos (vacío, lateral izquierdo/derecho, altura, tardío), sin sonido/destello/strike ni cambio de pelota, un gesto y vuelta al reposo. Cancelación/caducidad/pausa/laboratorio probados. Revisión gráfica de cuatro gestos; caso tardío adicional sin ventana. Dieciocho poses válidas, tres impactos/audio y jugador (90 trayectorias/diez devoluciones) siguen aprobados. Dos variables de ejecutor tipadas tras error inicial de inferencia; importación final sin errores. Geometría de antebrazos en recorrido comprobada con tolerancia previa.

**Continuidad:** usuario prueba nuevo abanicazo; luego globo. Plan, guía, arquitectura, decisiones, estado e informes actualizados. Punto Git al cierre.


## 28/10/2026 — Sesión 018: investigación de chiquita

**Pedido:** usuario propone chiquita para representar golpe suave intencional. Se consultaron dos referencias primarias de The Padel School y se documentó propuesta de control/ trayectoria en CHIQUITA.md. Calidad de preparación independiente de carga, profundidad corta y asistencia limitada; porcentajes abiertos. P45 pendiente y continuidad actualizada.

**Validación:** revisión documental y de fuentes. Sin cambios de código, ejecución del motor o nuevas pruebas de gameplay.


## 28/10/2026 — Sesión 019: chiquita jugable

**Pedido:** avanzar tras investigación de chiquita. Implementados destino corto, arco bajo, mezcla de intención por carga/apuntado, feedback para golpe suave y calidad independiente de carga. HUD enseña alternativa a 90%. Física pasiva, cámara, controles y animaciones conservados.

**Ajustes:** primer ejecutor colocaba pelota de espera detrás del jugador cercano y provocaba fallo antes de contacto; corregida preparación del caso. Límite de velocidad elevaba arco y anulaba el fallo mínimo; separado límite horizontal de pérdida vertical por mal contacto, sin RNG. Calibración provisional a pique de 1.6 m y máximo horizontal 8 m/s.

**Verificación:** 54 trayectorias, 24 transiciones y tres feeds reales aprobados. Comparación misma carga temprana/tardía, contacto excelente suave, golpe potente y mínima carga que pega en red. Regresiones de jugador (90/diez), impacto/audio (tres), abanicazo (cinco) y cinta (35) aprobadas. Importación sin errores de scripts; captura nativa revisada, render llvmpipe. Sin prueba humana ni rival activo. Documentación y punto Git al cierre.


## 28/10/2026 — Sesión 020: recorrido entre piques

**Pedido:** usuario observa segundo pique largo y pide contraste en internet. NOX/TPS describen chiquita suave a los pies, sin distancia universal. Física primaria de Rod Cross explica papel de fricción/agarre; no se usó como medición de césped de pádel.

**Diagnóstico:** ejecutor anterior terminaba en primer pique. Ampliado a segundo, altura y velocidades. Baseline de código 78d5750: caso cómodo 4.02 m entre piques y feed habitual 3.70 m. Guardados informe/video previos.

**Cambio:** agarre efectivo por pendiente de entrada, compartido por todas las pelotas. Fricción 0.18→0.42; primer intento detenía globo antes del vidrio y falló regresiones. Se acotó pérdida adicional a 50% tangencial para conservar secuencia de globo. Resultado cómodo 2.65 m, feed 2.47 m; drive corto también pasa de 5.10 a 3.35 m. No se cambian restitución vertical, salida, rodadura o controles; no spin ni freno exclusivo de chiquita.

**Verificación:** 54 trayectorias, 24 transiciones y tres feeds, ahora con segundo pique. Trece escenarios de pelota, superficies (incluidos agarre/caída rasante), 22 recorridos/veinte semillas, 90 trayectorias/diez devoluciones y 35 contactos de cinta aprobados. Caso canónico coincide en posición/velocidad/eventos a 30/60/120 FPS. Importación sin errores de scripts, render llvmpipe y captura ambos piques inspeccionada. Video actualizado, documentación y punto Git. Calibración humana pendiente.


## 28/10/2026 — Sesión 021: plano y globo separados

**Pedido:** botones distintos para plano y globo. Se mantuvo Espacio/A plano y se añadió E/B globo. Tipo de golpe explícito, misma preparación/soltar fija/contacto automático. Cambio de botón reinicia carga del tipo nuevo, conserva preparación y filtra liberación vieja. Chiquita conservada en plano.

**Implementación:** destino y apex de globo según potencia efectiva, dirección limitada por calidad y sobrecarga al cerramiento. Solver usa integrador existente; no modifica cámara/pelota física ni añade spin. Presentación derecha/revés y audio reutilizados. HUD/guía actualizados.

**Verificación:** 54 trayectorias y tres feeds reales con E, mapa B, cambios/cancelación/liberaciones, mantener sin repetir, foco/pausa/R/laboratorio aprobados. Plano/control 90/diez, chiquita 54/24/tres feeds y segundo pique, tres impactos/audio y cinco abanicazos aprobados. Importación sin errores de scripts; vista nativa y HUD 640×360 revisados. Video de tres segundos generado, sin audio. Valoración humana y mando físico pendientes; documentación y punto Git al cierre.


## 28/10/2026 — Sesión 022: sensación de plano/globo aceptada

Usuario indica «lo sentí bien». Registrada aceptación cualitativa, sin inferir duración, dispositivo o casos específicos. Plan y continuidad pasan al remate contextual pendiente en P40, después volea. No cambios de código ni nuevas pruebas del motor; calibración restante sigue abierta.


## 28/10/2026 — Sesión 023: smash con botón de plano

**Pedido:** implementar smash. Ventana contextual alta y descendente, menor alcance y calidad propia; misma preparación/fijación. Trayectoria ofensiva por velocidad horizontal 13–26 m/s, defensa suave si exigido, sobrecarga a red/cerramiento. H/RB añade globo recibido para probar; R normal conservado.

**Presentación:** postura alta, pala arriba y apoyo libre; contacto exacto y seguimiento por waypoint sobre/lateral a cabeza. Primera versión rozaba cabeza y falló geometría; corregida sin cambiar tolerancia. Contacto inicialmente demasiado alto, ajustado a espera breve de altura cómoda; H ahora contacta a 2.447 m/calidad 0.976.

**Verificación:** 54 trayectorias, tres H reales, límites, defensa, sobrecarga y E sin smash; geometría torso/cabeza y preservación de física. Plano/control 90/diez, globo 54/tres, chiquita 54/24/tres y segundo pique, tres impactos/audio, cinco abanicazos y 18 poses anteriores aprobados. Importación sin errores, capturas juego/cercanas revisadas y video de cinco segundos. Documentación y punto Git. Evaluación humana pendiente; sin rival, salto, spin o x3/x4 garantizado.


## 28/10/2026 — Sesión 024: combo de smash x3/x4

**Pedido:** investigar y añadir x3/x4 con ambos botones, carga 90% y dirección. NOX/Canada Padel/FIP confirman secuencias y cerramientos. Lateral se asigna a x3, adelante a x4. Ventana 0.10 s de carga permite combo manteniendo switch previo si segundo botón llega tarde. Gate por altura/alcance, cerca de red, calidad y banda de carga; falla vuelve a ordinario.

**Implementación:** predictor puro de velocidad inicial, compartiendo impulso de piso sin modificarlo. Solo BallSimulation resuelve vuelo/rebotes reales. Sin liftado real, salto, juego exterior o puntos automáticos. H adapta globo cercano sin mover jugador. Presentación overhead y HUD integrados.

**Ajustes:** tipo de Array del predictor corregido tras error inicial de ejecución; primer barrido angular no encontraba x3 hacia lateral cercano desde x=2.65, refinado y podado por velocidad/ángulo para evitar exceso de coste. 36 salidas barridas y tres H reales completan secuencias. H se centró más delante para mejorar calidad de contacto cerca de red.

**Pruebas:** casos negativos de carga/posición/calidad/dirección, orden de botones invertido, liberación/switch/pausa y preservación de reloj/RNG aprobados. Regresiones de plano, globo, smash, chiquita/segundo pique, pelota, superficies, poses, audio y fallo aprobadas. Capturas juego x3/x4 y videos revisados. Documentación y punto Git; evaluación humana y mando físico pendientes.


## 28/10/2026 — Sesión 025: teclado J/K

**Pedido:** sustituir Espacio+E por botones contiguos. Elegidos J para plano/smash y K para globo; J+K especial. Actualizados adaptador, HUD, título, instrucciones de H, guías y ejecutores de pruebas. Espacio conserva pausa en laboratorio, mando A/B conservado. No cambia física ni tiempos.

**Verificación:** Godot 4.7.2, pruebas sin ventana: globo 54 trayectorias, smash 54/tres feeds, especiales 36/tres feeds y jugador 90/diez devoluciones, todas sin fallos. Verificado mapa J/K y ausencia de bindings viejos para golpes. Importación completada sin errores de scripts, con errores de socket del editor por sandbox; los ejecutores no los presentan. Sin nueva inspección visual o prueba humana. Reiniciar para cargar controles; comodidad del par y combo pendiente de usuario.


## 28/10/2026 — Sesión 026: facilitar prueba del especial

Usuario no consigue globo corto con R. Aclarado H y detectada desalineación lateral: H seguía carril fijo aun al moverse el jugador. Se alinea H con su posición lateral, sin mover cuerpo; R conserva trayectoria. Mensajes inicial y de feed explican normal/globo/carga especial. Documentados pasos: acercarse primero y después lanzar H. Pruebas de especiales 36/tres feeds con 0.65 s de reacción, smash 54/tres y jugador 90/diez aprobadas. Importación sin errores de scripts, socket de editor bloqueado por sandbox. Comodidad humana pendiente.


## 28/10/2026 — Sesión 027: dirección según intuición del usuario

Usuario valora práctica y esperaba W+D x3, S x4. Se implementa diagonal adelante (W+A/W+D) para x3 por lateral correspondiente y atrás (S) para x4; equivalentes en flechas/stick. HUD y guías actualizados. Sin cambios en físicas, carga o combo. Especiales 36/tres feeds, negativos de dirección, smash 54/tres y jugador 90/diez aprobados. Importación sin errores de scripts, socket de editor bloqueado por sandbox. Validación humana pendiente.


## 28/10/2026 — Sesión 028: volea contextual

**Pedido:** implementar volea como siguiente variedad antes de rival de entrenamiento. Selección contextual con J/A y pelota entrante aún sin pique propio desde último golpe. Altura 0.45–2.1 m y alcance 1 m; solver más directo para preparada, defensa suave existente para exigida, sobrecarga conservada. Globo, smash y golpes tras pique conservados. R no cambia; prueba desde unos 3 m de red.

**Presentación:** preparación delante del cuerpo y acompañamiento compacto 0.16 s, recuperación preparada 0.14 s. Contacto visual mantiene evento físico, audio/destello por calidad. HUD reconoce volea. Sin nuevas físicas/spin, botones o rival. Error de indentación inicial del HUD corregido antes de ejecutar pruebas.

**Verificación:** 54 trayectorias/tres feeds R, selección por historial/altura/botón, defensa/carga/riesgo, contacto y geometría corporal aprobados. Regresiones jugador, globo, smash, especiales, chiquita, poses, audio e intento fallido aprobadas. Importación final sin errores de scripts; render llvmpipe, capturas revisadas y video 2 s. Primer intento gráfico no pudo acceder a display, resuelto con permiso de red local. Sin prueba humana ni rendimiento objetivo. Plan/documentación actualizados; siguiente P41 valoración de volea y P43 rival simple.

**Ajuste del usuario durante el desarrollo:** pidió aclarar volea suave/red y permitir sobrecarga a pared/laterales sin pique. Se añadió pérdida determinista de margen con potencia insuficiente y contacto bajo/mala calidad, aplicada después de asistencia. Se comprobaron seis vuelos específicos de debilidad, control y sobrecarga, incluidos ambos laterales y vidrio de fondo. Riesgos/documentación actualizados; no aleatoriedad.


## 28/10/2026 — Sesión 029: primer rival de peloteo

**Acuerdo:** usuario considera jugable el prototipo y acepta rival de entrenamiento antes de más golpes. Modo opcional I/LB, mismos controles y práctica individual conservada. Compañeros decorativos ocultos durante peloteo, un rival activo.

**Implementación:** motor/controlador de golpes adaptados a identidad y mitad opuesta mediante coordenadas locales, eventos físicos en mundo. Rival con reacción 0.24 s, replan 0.12 s, forecast aproximado sin modificar física/RNG, movimiento normal, plantado/carga/contacto comunes. Busca 70%, plano contextual y globo si humano sube. Fin de jugada básico y reinicio tras 1.8 s; R manual, pausa/foco/modos y audio conjunto. No dobles, árbitro completo o puntos.

**Verificación:** 60 s sintéticos con 34 devoluciones/68 contactos, quince recepciones, cinco pares espejados y negativos de alcance/reacción/reinicio aprobados. Regresiones de golpes, poses, impactos, pelota y cámara aprobadas. Constante de foco y activación de presentación de fixture corregidas. Importación final limpia. Capturas y video 6 s revisados; HUD largo corregido y ventana pequeña verificada. Documentación y punto Git. Pendiente prueba humana de tiempo para posicionar/cargar y dificultad antes de avanzar a parejas.


## Publicación en GitHub — 20/11/2026

Preparada una copia pública con historial sin la foto de referencia de licencia no establecida. README actualizado con estado jugable, tecnología y demostración del rival. Sin modificaciones de gameplay; no se ejecutó el motor para esta publicación.
