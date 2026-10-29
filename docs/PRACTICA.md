# Práctica de preparación y contacto automático — sesión 024

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
4. Mantené **J para plano** o **K para globo** y soltá para fijar carga. Probá cerca del **90%** para un golpe preparado, o **20–40% + abajo con J** para una chiquita. El contacto ocurre automáticamente al llegar la pelota, incluso si todavía estás manteniendo el botón. Apuntá con WASD/flechas mientras estás plantado.
5. **R** repite esa pelota. **T** cambia la zona de alimentación entre izquierda, centro y derecha y lanza.

Si aparece PAUSA al cambiar de ventana, pulsá **P** para continuar.

## Controles

| Acción | Teclado | Mando preparado en el mapa de acciones |
| --- | --- | --- |
| Moverse | WASD / flechas | Stick izquierdo |
| Plano: cargar / fijar | Mantener / soltar J | A |
| Globo: cargar / fijar | Mantener / soltar K | B |
| Smash contextual | J con pelota alta alcanzable | A |
| Especial x3/x4 | J + K juntos, fijar ~90% | A + B |
| Cancelar preparación fijada | Repetir J (plano) o K (globo) | Repetir A o B del golpe elegido |
| Recibir pelota | R | X |
| Recibir globo para rematar | H | RB |
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

La pelota sigue recorriendo la trayectoria mediante física y colisiones. Si hay un impacto intermedio, ya no se garantiza el destino previsto. Globo con K y smash contextual con J están disponibles; volea contextual y giro de pelota siguen pendientes. Los lanzamientos F1–F7 siguen siendo pruebas del laboratorio.

## Presentación del impacto

Se distinguen tres resultados: **normal** (destello celeste y golpe seco), **perfecto** (verde y ataque más marcado) y **defensa** (ámbar y sonido más suave/opaco). El sonido se solicita una sola vez desde el contacto real; preparar, soltar sin contacto o fallar no produce impacto. La sobrecarga conserva su aviso de riesgo; el sonido depende de la calidad real del contacto, no implica punto ganado/perdido.

La pala coincide con el contacto, el brazo acompaña y el gesto vuelve al reposo en 0.24 s. El destello dura 0.18 s y se dibuja como ayuda de lectura aunque lo tape el avatar. Son sonidos originales sintéticos provisionales; falta evaluación auditiva con el usuario. **M** silencia/reactiva y conserva preferencia al pausar o cambiar laboratorio dentro de esta ejecución; aún no se guarda entre ejecuciones.

### Derecha y revés

El muñeco controlado es **diestro** en este prototipo. Pelota a su derecha: derecha; a su izquierda: revés. La selección es automática, sin botón adicional. Cerca del centro conserva el lado elegido para que no cambie de pose continuamente.

Torso y cadera se giran, los pies adoptan apoyo de costado y el brazo flexiona por el codo. El drive prepara la pala al costado/atrás y abre el torso antes del impacto; el brazo libre acompaña de contrapeso. En revés, la mano libre acompaña el agarre. La preparación aproxima la pala a la zona de contacto y el seguimiento rodea el frente del cuerpo. La pala sigue contactando en el evento físico original, sin esperar que termine una animación. En reposo, los codos bajan y los brazos quedan relajados al costado; la pala permanece a la derecha. Al terminar el golpe vuelve gradualmente a esa postura. Son poses geométricas provisionales, no un esqueleto deportivo final.

**Para probar el revés:** recibí con R y ubicá al jugador un poco a la derecha de la trayectoria de la pelota antes de preparar. No necesitás apuntar hacia la izquierda para elegir revés: el apuntado sigue seleccionando destino del tiro.

Reposo revisado: [frente](previews/pose-rest-front.png) y [perfil](previews/pose-rest-side.png).

Drive revisado: [preparación de perfil](previews/pose-forehand-preparation-side.png), [contacto de frente](previews/pose-forehand-contact-front.png), [acompañamiento](previews/pose-forehand-follow-front.png).

Capturas de revisión cercana: [revés preparado](previews/pose-backhand-preparation.png), [contacto de revés](previews/pose-backhand-contact.png), [derecha](previews/pose-forehand-contact.png). Solo el ejecutor usa cámara cercana; el encuadre de juego aprobado no cambia.

Capturas de sesión 012 (presentación anterior, históricas): [preparación](previews/impact-preparation.png), [perfecto](previews/impact-perfect.png) y [defensa](previews/impact-defense.png). Ejecutor `tests/impact_checks.gd`: contacto, clases de audio, neutralización, silencio, pausa/F8 y preservación de física.

## Abanicazo al errar

Si preparás y la pelota se te pasa fuera del alcance o de la altura del golpe base, el personaje da un golpe al aire. También responde si pulsás J sin pelota disponible o llegás tarde. El gesto sigue el lado de la pelota; sin pelota usa el lado de golpe que tenía preparado.

El abanicazo dura aproximadamente 0.28 s, permite moverse y vuelve al reposo. No suena como impacto, no produce destello ni cambia pelota o contador de contactos. Un intento fallado no engancha la pelota después durante su animación. Cancelar una preparación fijada sigue cancelando sin abanicazo.

Para probarlo rápido, **pulsá J antes de lanzar con R**. Para probar un fallo real, prepará lejos de la trayectoria recibida. [Ejemplo de derecha al aire](previews/miss-forehand-forward.png).

## Laboratorio anterior

F8 abre el laboratorio E2. También se puede iniciar con:

```bash
./tools/run-godot.sh -- --lab
./tools/run-godot.sh -- --scenario=7
```

F1–F7 desde práctica entran al laboratorio y seleccionan escenario. Allí Espacio pausa, R repite, N cambia semilla y L controla repetición. En práctica J prepara plano, K prepara globo y P pausa. F8 vuelve a práctica con el jugador en posición inicial y la pelota esperando R.

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


## Probar la chiquita

Recibí con R y llegá temprano. Prepará con J, soltá al 20–40% para fijar poca potencia y mantené S/flecha abajo hasta el contacto automático. A/D permite colocación lateral; diagonal abajo también sirve. Seguir plantado después de soltar mejora preparación sin aumentar potencia. La pelota busca un pique corto cerca de la red rival; el aro indica destino aproximado. Un contacto preparado puede mostrar «¡Chiquita bien colocada!» y usar feedback de golpe excelente, aunque no tenga 90% de carga.

Compará con pulsar tarde: perdés dirección y una carga mínima exigida puede quedarse en red. Más de 40% se mezcla hacia golpe base (65% ya es base); 90% y 100% conservan comportamiento previo. Parámetros provisionales: ajustar según comodidad. Los rivales siguen estáticos, por lo que todavía no prueban la ventaja táctica de subir a la red.

[Demostración de chiquita, 2.5 segundos](previews/chiquita.mp4): trayectoria del motor con contacto sintético, cámara de juego y sin audio; no es un rival activo.


Segundo pique revisado (sesión 020): misma carga/controles, con mayor pérdida horizontal al caer con pendiente pronunciada. Feed habitual pasa de unos 3.70 a 2.47 m entre piques; afecta también otras pelotas en esas condiciones. Es calibración provisional: revisar sensación y comparar con golpe potente. [Video anterior](previews/chiquita-bounce-before.mp4) y [actual](previews/chiquita.mp4), sin audio y con entradas sintéticas. Reiniciar el juego para cargar esta versión.


## Probar el globo

Recibí con R, llegá antes y mantené K. Soltá cerca del 90% y elegí dirección mientras esperás el contacto automático. Más carga da un globo más alto y profundo; abajo acorta, arriba profundiza. Compará con 25–30% para uno más corto/bajo. Llegada tardía pierde profundidad y colocación. Al 100% existe riesgo de cerramiento directo.

Volver a pulsar K cancela globo fijado. Pulsar J cambia a plano y reinicia carga; soltar K después no fija el plano. Al cambiar de plano a globo sucede lo mismo. [Diseño y pruebas](GLOBOS.md) y [demostración](previews/lob.mp4). Reiniciá el juego para cargar controles nuevos.


## Probar el smash

Pulsá **H** para recibir un globo por tu zona. Llegá antes y prepará con **J**, soltando cerca del **90%**. La pelota alta y alcanzable se remata automáticamente con pala arriba. No necesitás otro botón; K sigue preparando globo. Para empezar, probalo en la posición inicial del jugador.

Tarde o mal ubicado, el remate pierde potencia/dirección o queda fuera de alcance. Al 100%, dirección corta puede ir a red y profunda al cerramiento. H es entrenamiento, no un botón para ejecutar remate: R conserva pelota normal. [Guía completa](SMASH.md) y [video de cinco segundos](previews/smash.mp4). Reiniciar juego para cargar versión nueva.


## Probar x3 y x4

Avanzá hasta quedar aproximadamente a 1–2 m de la red y pulsá **H**. Prepará con **J + K juntos** (ventana 0.10 s), soltá cerca del **90%** y elegí dirección mientras estás plantado:

- **Izquierda/derecha:** x3 hacia ese lateral, pasando primero por piso y vidrio de fondo.
- **Adelante (W/flecha arriba), sin lateral fuerte:** x4 por encima del fondo tras picar.

Mando: A+B. Primera liberación fija; la segunda no golpea otra vez. Si falta posición/calidad/carga, no hay dirección válida o no se encuentra salida, se devuelve de forma ordinaria. 100% no activa especial. Un botón tarde conserva cambio de plano/globo previo. El HUD identifica «Especial» para saber que reconoció el combo.

Primera aproximación arcade sin liftado real ni punto automático. [Diseño y fuentes](SMASH_ESPECIALES.md) · [video x3](previews/x3.mp4) · [video x4](previews/x4.mp4). Reiniciar para cargar versión nueva.
