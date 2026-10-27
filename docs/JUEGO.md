# Visión y alcance

## Acuerdos del usuario

- PC primero, celular después.
- Juego 3D con cámara como la foto: elevada detrás de una pareja y algo más atrás para ver la pared cercana.
- Referencia de jugabilidad: Virtua Tennis.
- Desarrollo individual, sin experiencia previa con Godot, Unity ni Unreal.
- Comenzar con Godot tras aceptar la recomendación.

## Experiencia buscada

Intercambios ágiles, controles accesibles y decisiones tácticas claras: dónde ubicarse, cuándo preparar el golpe, dónde dirigirlo y cuándo usar un globo. El pádel debe reconocerse en los rebotes y la ocupación de espacios por las parejas.

Hipótesis: trayectoria consistente más ayudas moderadas de contacto puede dar una sensación arcade satisfactoria. Hay que probarlo; todavía no está validado.

## Primera versión jugable propuesta

- Un humano con compañero de IA contra dos rivales de IA.
- Una cancha y una dificultad inicial, con personajes provisionales.
- Movimiento, golpe base, globo, remate contextual y volea según altura/pique.
- Servicio, errores, marcador y partido corto completo.
- Teclado y mando; pausa y ajustes esenciales.

Es una propuesta de MVP (primera versión mínima jugable), revisable tras las pruebas. El formato de partido y las variantes de puntuación se decidirán antes del marcador.

## Primer experimento

Cancha → cámara legible → pelota con lanzamientos repetibles → un jugador que devuelve. El 1 contra 1 será solo un laboratorio; el objetivo sigue siendo parejas.

## Controles propuestos, por validar

| Acción | PC | Futuro móvil |
| --- | --- | --- |
| Movimiento | WASD/flechas o stick | Stick virtual |
| Golpe base | Mantener botón prepara; soltar pide golpe | Botón táctil |
| Globo | Segundo botón | Botón táctil |
| Remate | Tercer botón, con pelota alta alcanzable | Botón/contextual |
| Dirección | Movimiento durante preparación, con ayuda ajustable | Stick |
| Pausa | Escape / menú | Botón de interfaz |

No fijar todavía teclas de golpe. Probar si compartir movimiento y dirección causa frustración. Derecha/revés/volea se seleccionan por contexto; la animación acompaña el contacto aceptado por la simulación.

## Cámara y estilo

Cámara de perspectiva elevada y centrada detrás del fondo cercano. Empezar fija, comparar altura/distancia/FOV y probar transparencia del cerramiento que tape la acción. Añadir seguimiento o zoom solo si mejora la lectura. Evaluar pelota contrastada, sombra e indicador de aterrizaje.

Arte 3D estilizado y sencillo como propuesta inicial; la fotografía no implica fotorrealismo. Revisar estilo y cámara con el usuario en E1.

## Fuera del primer MVP

Online, pantalla dividida, carrera, torneos, editor de personajes, jugadores licenciados, múltiples estadios, comentaristas, monetización y publicación móvil. Salidas jugables fuera de cancha y golpes avanzados se aplazan hasta resolver las reglas iniciales.

## Objetivos de calidad propuestos

- Pelota legible en ambos fondos y globos.
- Respuesta de control consistente y fallos comprensibles.
- 60 FPS en una PC de referencia todavía por identificar.
- Una persona nueva puede iniciar intercambios con una explicación breve.
- Priorizar coherencia y diversión antes que fidelidad visual.


## Primera implementación de controles — sesión 007

Se implementó la práctica E3 con WASD/flechas y Espacio mantener/soltar. Movimiento al soltar dirige el destino del golpe. R alimenta y T cambia zona. Son elecciones técnicas iniciales para probar con el usuario, no preferencias confirmadas. Globo/remate y efectos del jugador siguen pendientes. Ver PRACTICA.md.
