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
