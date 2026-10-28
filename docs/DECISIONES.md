# Registro de decisiones

Fecha inicial: 27/10/2026. Acordado refleja la conversación; decisión técnica inicial es reversible; propuesta todavía debe validarse.

| ID | Estado | Elección y motivo | Revisión |
| --- | --- | --- | --- |
| D01 | Acordado | PC primero, celular después | E8 |
| D02 | Acordado | Cámara como foto, algo más atrás para ver pared cercana | E1 |
| D03 | Acordado | Experiencia inspirada en Virtua Tennis, deporte pádel | E4 |
| D04 | Acordado | Una persona, aprendiendo el motor | Cada estimación |
| D05 | Acordado | Comenzar con Godot | Ante limitación concreta |
| D06 | Verificada | GDScript tipado y Godot estándar 4.7.2, ejecutado en modo portátil en sesión 002 | Al actualizar motor |
| D07 | Técnica inicial | Renderer Compatibility como punto de partida sencillo | E1 y prueba móvil; medir |
| D08 | Propuesta | Humano + compañero IA contra dos rivales IA | Antes de E5 |
| D09 | Técnica inicial | Separar pelota, reglas, entradas y presentación | E2–E3 |
| D10 | Propuesta | Arte estilizado y cerramiento cercano atenuable | E1 |
| D11 | Técnica inicial | Dos skills propias versionadas; visuales existentes según tarea | Primeras sesiones |
| D12 | Pendiente | Modelo de simulación y tolerancias | P20 |
| D13 | Pendiente | Teclas, potencia, ayudas de contacto | E3–E4 |
| D14 | Pendiente | Jugador fijo o cambio automático/manual | E5 |
| D15 | Pendiente | Formato del partido, puntuación y reglas omitidas | P60 |
| D16 | Pendiente | SO de primera build, PC de referencia y teléfono | P06/P80 |
| D17 | Técnica inicial | “Pádel Arcade” es solo nombre de trabajo | Antes de publicar |

Para cambiar una decisión: añadir fecha, contexto, alternativas relevantes, elección, consecuencias y tareas afectadas. Conservar la anterior como sustituida. No convertir propuestas técnicas en preferencias confirmadas del usuario.


## 27/10/2026 — decisiones de prototipo

- **D18, técnica inicial:** mantener Godot y sus datos dentro del espacio del chat. Motivo: entorno con directorios personales restringidos. No modificar instalación del sistema. Impacto: usar tools/run-godot.sh.
- **D19, propuesta visual:** cámaras 1/2/3 a (0,10,18), (0,12,21), (0,9,17), FOV vertical 52°, objetivo (0,0.5,0). Referencia inicial: vista 1, todavía sin elección del usuario. Impacto: P12/P15.
- **D20, simplificación explícita:** figuras y cancha son blockout; cerramiento lateral simplificado sin puertas, sin colisiones. La pelota recorre una curva programada y tiene radio visual 0.105 m para facilitar lectura. No interpretar como física, reglamento o arte final. Impacto: P10/P11 y futuro P20.
- **D21, técnica inicial:** atenuación cercana mediante alpha de materiales y desactivación de sombra de esas piezas, para evitar oclusión visual con Compatibility. Conserva la indicación de pared; el futuro collider debe ser independiente. Impacto: P13/E2.


## 27/10/2026 — sesión 003: revisión del usuario y laterales

- **D19, aprobada por el usuario:** el encuadre actual sirve; conservar posiciones, FOV y objetivo de cámara. Sustituye el estado pendiente de la sesión 002.
- **D22, técnica aplicada:** corregir perfil lateral con variante de cristal FIP: vidrio de 3 m a lo largo de 4 m desde cada fondo; reja superior hasta 4 m en los primeros 2 m; altura total de 3 m en el resto del lateral. Motivo: el usuario detectó altura uniforme incorrecta. No adoptar la variante alternativa de pared escalonada. Accesos y colisiones siguen pendientes.


## 27/10/2026 — sesión 004: simulación inicial

- **D12, resuelta / D23:** CharacterBody3D con integración propia de gravedad y respuesta, usando move_and_collide de Godot para barrido. Alternativas y razones en LABORATORIO_PELOTA.md. No se implementaron dos motores completos.
- **D24:** paso físico 120 Hz, velocidad máxima 60 m/s y ocho impactos por paso como límite conservador registrado. Eventos ordenados con superficie/lado/último golpeador; sin reglas ni golpes todavía.
- **D25:** conservar radio físico/visual ampliado de 0.105 m durante laboratorio. Coeficientes distintos por superficie son ajustes iniciales, no datos medidos ni reglamentarios. Reja como panel sólido sin dispersión aleatoria; sin giro. Revisar antes de calibrar juego final.
- **D26:** abrir por defecto el laboratorio físico; conservar el modo de cámara E1 únicamente con `--camera-preview` para regresiones. Cámara y laterales aceptados sin cambios.


## 27/10/2026 — sesión 005: feedback de rebotes

- **D27, ajuste de D25:** vidrio con restitución normal 0.68 y retención tangencial 0.90; reja 0.48/0.82 más dispersión. Valores de diseño provisionales, sin pretensión de medición real.
- **D28, sustituye “reja sin dispersión” de D25:** desvíos angulares acotados por impacto con RNG local reiniciado por semilla. Semilla inicial 42, R repite y N cambia. Respuesta conserva energía de la reflexión ya amortiguada y no se dirige a través de la superficie. Se preserva repetibilidad para depuración.
- **D29:** corregir F7 porque antes tocaba vidrio antes que piso. Nuevo lanzamiento (1,9.8,-7.6) m/s: piso→vidrio→piso del lado rival antes de cualquier posible vuelta por red. No hay una regla artificial que impida retornos físicamente posibles.
- **D30, pendiente:** no confundir dispersión de reja con giro. Topspin/slice/lateral requieren velocidad angular, interacción con vuelo y fricción de contactos; se planifican en P44, sin implementación en esta sesión.


## 27/10/2026 — sesión 006: pérdida de recorrido

- **D31, ajuste de D27:** el recorrido completo seguía siendo excesivo. Incorporar impulso tangencial de fricción en piso μ=0.18, sin invertir movimiento, además de retención 0.94. Restitución piso 0.68, vidrio 0.62 y reja 0.36; retención vidrio 0.82 y reja 0.65. Valores de prototipo.
- **D32:** rodadura con desaceleración constante 2.8 m/s² para llegar a reposo en tiempo finito; sustituye amortiguación exponencial anterior. Sin corte artificial por cantidad de piques o distancia.
- **D33:** medir hasta reposo, no solo hasta el segundo pique. Objetivos de regresión limitados a lanzamientos de prueba: globo retorna menos de 4 m, reja menos de 5 m en veinte semillas; tiro bajo más rápido conserva más alcance pero no llega a red. No son límites insertados en simulación.
- **D34:** repetición automática apagada al abrir; R relanza y L activa repetición opcional. Permite observar el final sin confundir un reinicio con conservación de movimiento.


## 27/10/2026 — sesión 007: primer jugador y golpe

- **D35, técnica inicial por validar con el usuario:** práctica de un jugador en mitad cercana; WASD/flechas, Espacio mantener/soltar, R alimentación manual, T tres zonas, P/Escape pausa. F8 conserva laboratorio. No hay repetición automática ni rival.
- **D36:** acciones de entrada independientes de dispositivo con bindings teclado/mando. Mando solo comprobado sintéticamente; remapeo de interfaz pendiente. Pausa al perder foco.
- **D37:** preparación mínima 0.10 s, completa 0.8 s, ventana de contacto 0.20 s, recuperación 0.35 s. Alcance inicial 1.25 m y altura 0.22–2.1 m; una vez por intento y por pelota recibida. Ajustar con la prueba humana.
- **D38:** devolver mediante velocidad calculada para objetivo rival con margen de red; asistencia arcade declarada, sin teletransportar pelota ni alterar los coeficientes E2. Strike conserva reloj, posición, historial y RNG; launch inicia nueva pelota.
- **D39:** jugador con cápsula y barridos explícitos con delta, límites a su mitad y velocidad diagonal normalizada. Todavía sin choque pelota/cuerpo ni colisiones entre personajes; esas reglas no se infieren del movimiento.
- **D40:** panel nativo Godot con texto de controles/feedback y contador de contactos, compacto por debajo de 800 px. La búsqueda UX local no dio una guía específica de juego; se aplicaron criterios generales de legibilidad, contraste y feedback, no recomendaciones web de formularios como si fueran del motor.
- **D41:** las pruebas automáticas y la grabación no sustituyen la validación humana de comodidad/diversión. P34 queda pendiente hasta que el usuario juegue esta versión.


## 28/10/2026 — sesión 008: revisión del control deseado

- **D42, dirección propuesta por el usuario:** priorizar anticipación, posición y preparación con contacto automático, usando Virtua Tennis 1/2 como referencia de sensación. Requiere revisar D35/D37; la versión ejecutable todavía conserva esos controles.
- **Pendiente de definir:** soltar para fijar potencia sin ejecutar, cancelación y caducidad. Es una recomendación de esta revisión, no un acuerdo cerrado. Riesgo de tiro adaptado a paredes de pádel; detalle en REVISION_CONTROLES_ARCADE.md.


## 28/10/2026 — sesión 009: acuerdos de preparación y riesgo

- **D43, confirmado por el usuario:** mantener carga y soltar fija la potencia; el contacto se ejecuta automáticamente al llegar la pelota. Tiro perfecto: llegar a tiempo, buena posición, cargar cerca del 90% y soltar. Una carga correcta por sí sola no sustituye posición/equilibrio. Sustituye la propuesta pendiente de liberación de sesión 008; cancelación/caducidad quedan por definir.
- **D44, confirmado por el usuario:** sobrecarga al 100% implica riesgo de tiro directo al cerramiento rival sin pique: pared de fondo o lateral según dirección, ocasionando pérdida del punto. No se acordó que todo 100% sea fallo obligatorio; trayectoria y calidad determinan el resultado, sin sorteo arbitrario.
- **D45, confirmado por el usuario:** llegada tardía pero alcanzable permite defensa mala, de poca potencia y menor control direccional. Fallar se reserva a contacto imposible. Compresión de dirección hacia el centro es propuesta técnica por probar, no detalle aprobado todavía.


## 28/10/2026 — sesión 010: control automático implementado

- **D46, implementación provisional de D43:** estados explícitos; mantener carga, soltar fija, contacto automático también mientras se mantiene. Apuntado continuo hasta impacto. Otra pulsación tras fijar cancela; caducidad total 3 s; pausa cancela. Sin repetición por mantener. Frenado 60 m/s², objetivo de movimiento preparando cero. Sin asistencia de desplazamiento automático por ahora.
- **D47, parámetros para probar:** carga completa 0.8 s; zona ideal 86–94%. Calidad pondera distancia (30%), altura (20%), equilibrio (20%) y preparación (30%). Zona cómoda de contacto 0.65 m con espera máxima 0.06 s tras entrar en alcance. Preparación menor a 0.18 s o calidad menor a 0.55 produce defensa con potencia limitada a 0.32 y dirección comprimida hacia centro. Recuperación 0.18/0.28 s sin bloquear movimiento tras impacto. Sustituye mínimo de preparación/ventana al soltar de D37.
- **D48, implementación provisional de D44:** sobrecarga por encima del 94% extiende objetivo en profundidad/ángulo con factor mayor cuando empeora contacto. Sin RNG del golpe. Dos casos forzados verificados contra física: fondo y lateral antes de piso. No significa falta automática de todo 100%; arbitraje/resultado de punto siguen pendientes E6. Cámara y coeficientes E2 sin modificar.


## 28/10/2026 — sesión 011: riesgo de red en tiro corto

- **D49, pedido del usuario:** apuntar hacia abajo con 100% de carga debe poder producir red. El riesgo de sobrecarga (por encima del 94%) se reparte según el apuntado: hacia abajo reduce arco en vez de alargar profundidad; hacia adelante/laterales conserva riesgo de cerramiento. Calidad favorable conserva más margen, sin RNG de fallo ni obligación de que todo 100% falle.
- **Calibración técnica provisional:** factor de riesgo vertical 1.6 hacia una altura de centro de pelota de 0.45 m al cruzar red en máxima penalización. Se modifica velocidad vertical después de calcular arco nominal; no se altera gravedad, red o rebotes. Aviso específico de menor margen sobre red. Ajustar con juego humano.


## 28/10/2026 — sesión 012: aceptación del control y presentación

- **D50, confirmado por el usuario:** sensación de juego buena tras probar versión con riesgo de red. E3/P34 aceptados cualitativamente; conservar sus parámetros al mejorar presentación. No se atribuye una duración medida a esa prueba humana.
- **D51:** presentación separada en ImpactFeedback (prioridad física 30), consumiendo BasicShot.hit después del impacto. Preparación geométrica, pala en posición de contacto, brazo conectado y acompañamiento 0.24 s; destello 0.18 s como ayuda visual. No retemporizar pelota ni bloquear movimiento. Personajes y animación siguen provisionales.
- **D52:** impactos normal/perfecto/defensivo con WAV propios de síntesis determinista, sin muestras/licencias externas; volumen inicial -8 dB. Colores celeste/verde/ámbar. M silencia; pausa/alimentación/F8 limpian efectos y voces, silencio persiste en sesión. Sonido comunica clase de contacto, no resultado de punto; no suena en fallo sin contacto. Escucha y valoración del usuario pendientes.


## 28/10/2026 — sesión 013: evitar pelota sostenida sobre cinta

- **D53:** la cara superior plana de los paneles de red no debe sostener indefinidamente una pelota. Asistencia arcade localizada: si normal.y ≥ 0.5 y velocidad transversal reflejada ≤ 0.05 m/s, redirigir hasta 45% de la velocidad vertical entrante hacia z, máximo 0.35 m/s y siempre limitado por rapidez total entrante. Elegir lado por posición; en simetría exacta usar sentido entrante o +z. Sin RNG ni salto de posición. Conservar rebote frontal y roce que ya atraviesa con impulso. Valores provisionales, no modelo de deformación real de una red.
- **Límite de reproducción:** reproducido el equilibrio sobre cinta aislado; el usuario no proporcionó entradas/posición exactas de su tiro. Se ensayaron además 18 trayectorias generadas por carga 100% apuntando abajo.


## 28/10/2026 — sesión 014: poses de derecha y revés

- **D54, pedido del usuario:** el revés debe girar al personaje de costado; brazo/pala no deben atravesar el torso. Se mejora el muñeco actual antes del globo, manteniendo control y contacto aceptados.
- **D55, implementación provisional:** avatar controlado diestro con torso/cadera independientes, pies orientados y brazos de dos segmentos. Lado por x relativo de pelota con banda de estabilidad ±0.15 m; torso de costado en preparación/contacto y mano de apoyo en revés. Trayectoria de pala proyectada fuera del volumen del torso durante preparación/seguimiento; codos por delante y fuera de sus bordes. No modifica colisión física del jugador ni mueve pelota/cuerpo para alcanzar.
- **D56, alcance de validación:** 18 casos representativos, tres alturas y preparación corta/larga en ambos lados, con muestras de brazo y pala fuera del volumen conservador del torso. Exactitud de impacto, giro y recuperación verificados; revisión de capturas cercana. No equivale a rig final, límites biomecánicos completos o garantía para todas las pelotas dentro del collider del personaje. Personajes estáticos restantes no se rehicieron.


## 28/10/2026 — sesión 015: reposo relajado

- **D57, feedback del usuario:** golpes de derecha/revés quedaron bien; conservarlos. Corregir brazos con aspecto quebrado en reposo.
- **D58:** reposo separado del codo adelantado de golpe: brazos caen al costado con flexión suave, pala a derecha y mano libre baja. Retorno se mezcla en el último 40% del acompañamiento existente, relajando codo cuando la mano vuelve al mismo costado para evitar atravesar torso durante transición. Dos uniones visuales de hombro cubren separación entre manga y cuerpo. Sin cambio de poses de preparación/contacto, controles, duración de recuperación o física.


## 28/10/2026 — sesión 016: drive independiente del revés

- **D59, feedback del usuario:** revés se ve bien; drive sigue raro. Acotar ajuste al drive y conservar revés/control/reposo aprobados.
- **D60, presentación provisional:** drive lleva pala al costado/atrás al preparar y abre torso progresivamente al llegar pelota. En impacto delantero, yaw de torso usa 20% de orientación cerrada; detrás conserva orientación defensiva. Codo de brazo de golpe usa dos segmentos equilibrados con extensión de emergencia; al cruzar frente a torso se mezcla con guía exterior para evitar penetración. Brazo libre usa flexión exterior como contrapeso. Acompañamiento termina más arriba; duración/contacto/física sin cambios.
- **Validación:** comparación local de seis casos de revés conserva poses registradas de preparación/contacto/seguimiento; dieciocho casos actuales y reposo pasan. La mejora visual requiere valoración del usuario; sigue siendo muñeco geométrico provisional, no biomecánica de producción.


## 28/10/2026 — sesión 017: respuesta visual al fallo

- **D61, feedback del usuario:** drive ajustado bueno; sumar abanicazo cuando pulsa e intenta golpear sin llegar a pelota.
- **D62:** `missed` como evento separado de contacto. Activa gesto al pasar pelota preparada fuera de alcance/altura, al caducar, en pulsación tardía y sin pelota disponible (incluida pelota ya golpeada, sin permitir segundo impacto). No requiere soltar otro botón. Cancelación de preparación conserva función previa y no es fallo.
- **D63, presentación provisional:** abanicazo de 0.28 s, avance hasta zona local cómoda y acompañamiento de derecha/revés. No estirar brazo hasta pelota remota, no modificar simulación ni marcar contacto, no sonido/destello de impacto. Movimiento libre, recuperación corta existente y un solo gesto por intento. Pausa/R/F8 limpian presentación.


## 28/10/2026 — sesión 018: intención de chiquita

- **D64, orientación aceptada:** usuario quiere distinguir poca potencia deliberada de devolución débil por mala preparación; propone investigar la chiquita.
- **D65, propuesta pendiente de prueba:** carga baja fijada temprano más dirección corta permite buscar pies del rival. Calidad independiente de cantidad de carga; no exigir 90% para todo golpe excelente. Sin botón adicional inicialmente. Detalle y límites en CHIQUITA.md; no implementado ni calibrado.


## 28/10/2026 — sesión 019: primer prototipo de chiquita

- **D66, autorización:** usuario pide continuar con siguientes pasos tras propuesta de chiquita. Se implementa prototipo y se mantiene pendiente calibración humana.
- **D67, provisional:** carga <=40% y abajo completo produce chiquita; mezcla suave por carga (40–65%) y componente abajo (0.2–0.8). Objetivo de pique 1.6 m de red y centro de pelota sobre red 1.16 m, velocidad horizontal <=8 m/s. Parámetros exportados; no valores reglamentarios ni mediciones reales. Contacto alto/cercano puede flotar por límite de velocidad. Sin segundo botón ni ajuste al rival.
- **D68:** calidad sigue madurando después de fijar carga. Con buena calidad (>=0.85), carga 12–40% y chiquita completa se reconoce excelente golpe suave. El 90% permanece referencia de drive potente. Una mínima carga tardía puede perder margen de red mediante trayectoria determinista, sin RNG. Riesgo potente aprobado se conserva.


## 28/10/2026 — sesión 020: segundo pique y agarre del piso

- **D69, feedback:** segundo pique de chiquita demasiado largo. Ampliar validación más allá del primer pique y contrastar referencia deportiva, sin inventar distancia oficial.
- **D70, calibración provisional:** agarre efectivo por pendiente en toda colisión de piso. Fricción 0.18→0.42 al variar pendiente 0.35→0.85; pérdida extra limitada al 50% tangencial para no anular globos. Base y retención existentes conservadas. No excepción por tipo de golpe. La fricción también cambia otras caídas pronunciadas; prueba humana pendiente.
- **D71, alcance:** se conserva restitución vertical, arco de salida, gravedad y rodadura. Referencia de fricción/agarre no equivale a simular giro. Spin completo sigue P44 pendiente. Metas de segundo pique son criterios arcade para casos conocidos, no regla ni medición real.


## 28/10/2026 — sesión 021: dos botones de golpe

- **D72, pedido del usuario:** un botón para plano y otro para globo. Asignación provisional Espacio/A para plano, E/B para globo, conservando chiquita en plano con carga baja y abajo.
- **D73:** ambos mantienen preparación/fijación/contacto automático. Otro botón cambia tipo, reinicia carga y conserva tiempo de preparación/equilibrio. Liberación solo del botón seleccionado fija; repetir mismo botón tras fijar cancela. Sin contactos duplicados ni golpe por soltar.
- **D74, globo provisional:** apex 3.0–5.5 m y profundidad 4.0–8.0 m según potencia efectiva; dirección desplaza destino, limitado nominalmente a 3–9 m. Sobrecarga agrega riesgo de cerramiento antes del piso, sin bajar arco como plano. Sin cambio de física pasiva/cámara. Poses/sonidos existentes reutilizados; remate y volea aún pendientes.
