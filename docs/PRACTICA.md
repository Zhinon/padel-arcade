# Práctica de preparación y contacto automático — sesión 014

Un jugador se mueve y devuelve pelotas de un lanzador. Se mantiene la cámara aprobada y la física calibrada de E2. Los otros tres personajes siguen estáticos; no hay rival, marcador ni partido.

![Jugador controlable y primer golpe](previews/practice.png)

[Demostración histórica de sesión 012, seis segundos](previews/practice.mp4): entradas sintéticas de Godot realizan dos contactos. Es una prueba grabada, no un rival o asistente que juegue por el usuario. El audio del video se mezcla con los WAV del juego según el registro de eventos, no se graba de la salida de audio del sistema.

## Empezar

Desde la raíz del proyecto en Linux:

```bash
./tools/run-godot.sh
```

1. El jugador naranja con aro es el que controlás. Al abrir, la pelota espera en el lanzador.
2. Pulsá **R**. La primera pelota llega por tu zona inicial, a la izquierda.
3. Movete con **WASD o flechas**. Llegá antes de preparar: al preparar el personaje frena y se planta.
4. Mantené **Espacio** para cargar y soltalo cerca del **90%** para fijar potencia. El contacto ocurre automáticamente al llegar la pelota, incluso si todavía estás manteniendo el botón. Apuntá con WASD/flechas mientras estás plantado.
5. **R** repite esa pelota. **T** cambia la zona de alimentación entre izquierda, centro y derecha y lanza.

Si aparece PAUSA al cambiar de ventana, pulsá **P** para continuar.

## Controles

| Acción | Teclado | Mando preparado en el mapa de acciones |
| --- | --- | --- |
| Moverse | WASD / flechas | Stick izquierdo |
| Cargar / fijar potencia | Mantener / soltar Espacio | Mantener / soltar A |
| Cancelar preparación fijada | Volver a pulsar Espacio | Volver a pulsar A |
| Recibir pelota | R | X |
| Cambiar zona y recibir | T | Y |
| Silenciar / reactivar impactos | M | Sin asignación todavía |
| Pausar / continuar | P o Escape | Start |
| Alternar laboratorio / práctica | F8 | Sin asignación todavía |
| Cámaras | 1/2/3 | Sin asignación todavía |
| Atenuar cerramiento cercano | G | Sin asignación todavía |

Los bindings de mando están configurados y se comprobaron con eventos sintéticos; falta probar un mando físico.

En ventana pequeña se muestran las instrucciones esenciales; las instrucciones completas están en esta guía. Los avisos informan preparación, contacto, pelota demasiado alta/baja o falta de alcance. El contador registra contactos de práctica, no puntos de un partido.

## Dirección y preparación

Durante la preparación, WASD/flechas o stick dejan de mover al personaje y pasan a apuntar. Izquierda/derecha buscan ángulo; adelante busca profundidad y atrás acorta. Podés cambiar dirección después de fijar carga, hasta el contacto. Sin dirección, el destino nominal está frente al jugador. El aro rival muestra la intención; la calidad y sobrecarga pueden modificar el destino final.

Carga completa: 0.8 s. Zona ideal inicial: **86–94%**, alrededor del 90%; el texto cambia de color para indicarla. Soltar conserva la carga sin disparar. Un tiro perfecto exige también posición, altura y equilibrio favorables. La potencia no depende solo del tiempo.

Si la pelota llega antes de soltar, se usa la carga disponible. Una llegada tardía alcanzable devuelve con poca potencia y dirección más central. Si no hay alcance o altura válida, no hay golpe remoto. El contacto prioriza una distancia cómoda dentro de una ventana corta de 0.06 s desde que entra en alcance.

Después de fijar, una nueva pulsación cancela y devuelve el movimiento. La preparación caduca a los 3 s desde su inicio o cuando la pelota queda atrás. Cada golpe exige nueva pulsación; mantener no encadena devoluciones. Pausar cancela la preparación.

Por encima del 94% se pierde margen progresivamente: al 100%, buscar profundidad o ángulo con mala posición puede producir un impacto directo en vidrio/reja rival antes del piso. Si apuntás hacia abajo (tiro corto), la sobrecarga reduce el margen de altura y puede tocar la red, especialmente con contacto exigido. Esta bajada del arco se aplica después de la ayuda de trayectoria para que no se corrija sola. La desviación se calcula con carga, dirección y calidad, sin sorteo de fallo. Todavía no hay árbitro ni marcador: la práctica muestra la trayectoria y el aviso de sobrecarga, no resuelve puntos.

La recuperación impide otro intento durante 0.18 s (0.28 s defensivo), pero devuelve el movimiento inmediatamente después del contacto. Todos estos tiempos y coeficientes son provisionales para probar la sensación.

## Movimiento y contacto

- Velocidad máxima 5.2 m/s, aceleración 25 m/s²; preparando la velocidad objetivo es cero, con frenado de 60 m/s². Puede quedar un pequeño desplazamiento de frenado; el apuntado no permite correr.
- Movimiento diagonal normalizado, con barridos de colisión y límites dentro de la mitad cercana. No hay salto ni cambio de lado.
- Alcance horizontal inicial 1.25 m; altura de contacto 0.22–2.1 m. Existe tolerancia limitada para una pelota que llega durante la preparación, no un golpe remoto.
- Pala y brazo con preparación y acompañamiento procedural, contacto sincronizado y breve inclinación del cuerpo; sin esqueleto o animación deportiva final. El cuerpo conserva movimiento durante el gesto.
- Un solo contacto por intento y un solo golpe del jugador por pelota recibida. R/T vuelven a habilitar una nueva pelota.
- La bola conserva posición, reloj, historial de contactos y estado aleatorio al golpearla. El golpe cambia velocidad y último golpeador; no es un relanzamiento oculto.

El cuerpo del jugador colisiona con la cancha. La pelota no rebota contra los cuerpos de los personajes: esa interacción y su regla deportiva quedan pendientes.

## Ayuda de devolución inicial

El golpe base calcula una velocidad de salida para aterrizar cerca del aro rival usando el mismo paso de gravedad y resistencia de E2. Ajusta duración si hace falta para intentar pasar la red con margen (altura de centro de pelota al cruzar: al menos 1.3 m en la predicción). Esto es asistencia arcade explícita.

La pelota sigue recorriendo la trayectoria mediante física y colisiones. Si hay un impacto intermedio, ya no se garantiza el destino previsto. No se implementaron globo/remate del jugador ni giro de pelota. Los lanzamientos F1–F7 siguen siendo pruebas del laboratorio.

## Presentación del impacto

Se distinguen tres resultados: **normal** (destello celeste y golpe seco), **perfecto** (verde y ataque más marcado) y **defensa** (ámbar y sonido más suave/opaco). El sonido se solicita una sola vez desde el contacto real; preparar, soltar sin contacto o fallar no produce impacto. La sobrecarga conserva su aviso de riesgo; el sonido depende de la calidad real del contacto, no implica punto ganado/perdido.

La pala coincide con el contacto, el brazo acompaña y el gesto vuelve al reposo en 0.24 s. El destello dura 0.18 s y se dibuja como ayuda de lectura aunque lo tape el avatar. Son sonidos originales sintéticos provisionales; falta evaluación auditiva con el usuario. **M** silencia/reactiva y conserva preferencia al pausar o cambiar laboratorio dentro de esta ejecución; aún no se guarda entre ejecuciones.

### Derecha y revés

El muñeco controlado es **diestro** en este prototipo. Pelota a su derecha: derecha; a su izquierda: revés. La selección es automática, sin botón adicional. Cerca del centro conserva el lado elegido para que no cambie de pose continuamente.

Torso y cadera se giran, los pies adoptan apoyo de costado y el brazo flexiona por el codo. En revés, la mano libre acompaña el agarre. La preparación aproxima la pala a la zona de contacto y el seguimiento rodea el frente del cuerpo. La pala sigue contactando en el evento físico original, sin esperar que termine una animación. Son poses geométricas provisionales, no un esqueleto deportivo final.

**Para probar el revés:** recibí con R y ubicá al jugador un poco a la derecha de la trayectoria de la pelota antes de preparar. No necesitás apuntar hacia la izquierda para elegir revés: el apuntado sigue seleccionando destino del tiro.

Capturas de revisión cercana: [revés preparado](previews/pose-backhand-preparation.png), [contacto de revés](previews/pose-backhand-contact.png), [derecha](previews/pose-forehand-contact.png). Solo el ejecutor usa cámara cercana; el encuadre de juego aprobado no cambia.

Capturas de sesión 012 (presentación anterior, históricas): [preparación](previews/impact-preparation.png), [perfecto](previews/impact-perfect.png) y [defensa](previews/impact-defense.png). Ejecutor `tests/impact_checks.gd`: contacto, clases de audio, neutralización, silencio, pausa/F8 y preservación de física.

## Laboratorio anterior

F8 abre el laboratorio E2. También se puede iniciar con:

```bash
./tools/run-godot.sh -- --lab
./tools/run-godot.sh -- --scenario=7
```

F1–F7 desde práctica entran al laboratorio y seleccionan escenario. Allí Espacio pausa, R repite, N cambia semilla y L controla repetición. En práctica Espacio golpea y P pausa. F8 vuelve a práctica con el jugador en posición inicial y la pelota esperando R.

## Comprobaciones y límites

- `tests/player_checks.gd`: movimiento, límites, carga fijada/automática, defensa tardía, cancelación, caducidad, alcance y altura, un solo impacto, conservación de posición/reloj/RNG al golpear, pausa, foco y F8.
- 90 trayectorias con varias alturas, posiciones, potencias y direcciones: cruzan red y primer pique rival a menos de 0.4 m del objetivo.
- Práctica automática de 30 s: diez alimentaciones en tres zonas y diez contactos. Es integración técnica; **la comodidad y diversión siguen pendientes de prueba humana**.
- Grabación a 30 FPS programados mediante eventos de teclado/action: dos golpes reales en el motor.
- Interfaz comprobada en 1280×720 y 640×360. No equivale a adaptación móvil.

```bash
./tools/run-godot.sh --headless --script res://tests/player_checks.gd
```

Informe: `previews/player-checks.json`. Coeficientes de rebote anteriores conservados; regresiones documentadas en PRUEBAS.md.
