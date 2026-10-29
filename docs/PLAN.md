# Plan de desarrollo

Actualizado: 27/10/2026. Sin fechas comprometidas. Identificadores estables para citar en bitácora.

`[x]` completado con evidencia; `[ ]` pendiente. Una tarea preparada pero sin verificar sigue pendiente.

## E0 — Preparación y continuidad

- [x] P00 Crear carpeta, índice e instrucciones de continuidad.
- [x] P01 Registrar acuerdos, propuesta de MVP y exclusiones.
- [x] P02 Crear dos skills propias y validar su formato.
- [x] P03 Instalar skills personales y verificar las copias (hashes coincidentes y formato validado).
- [x] P04 Preparar proyecto Godot y escena técnica mínima, sin gameplay.
- [x] P05 Descargar Godot portátil 4.7.2, importar y ejecutar con captura renderizada.
- [ ] P06 Registrar SO objetivo de primera build, CPU/GPU/RAM y teclado/mando disponibles.
- [x] P07 Crear repositorio local y primer punto de recuperación en `main`, sin remoto.

**Salida:** proyecto abre sin errores, skills disponibles y punto de recuperación. La preparación de archivos no cierra E0.

## E1 — Cancha y cámara

Depende de P05. Objetivo: ver claramente dónde se juega.

- [x] P10 Construir cancha provisional a escala, con líneas, red, vidrio y reja distinguibles; consultar FIP.
- [x] P11 Colocar cuatro figuras y pelota provisionales.
- [x] P12 Ajustar altura/distancia/FOV para incluir fondo cercano y cancha rival.
- [x] P13 Atenuar cerramientos que tapen la acción.
- [x] P14 Probar globos y posiciones extremas; guardar capturas y parámetros.
- [x] P15 Revisar encuadre con el usuario: aprobado en sesión 003; arte sigue provisional. Corregidos laterales a pedido del usuario.

**Avance sesión 002:** P10 es un blockout visual: dimensiones principales, líneas, red y cerramiento simplificado; aún sin accesos ni colisiones. P12 es un encuadre inicial, no elección aprobada. P14 incluye 101 muestras de trayectoria por cámara y capturas en dos resoluciones. Ver CAMARA.md y PRUEBAS.md.

**Salida:** encuadre aprobado por el usuario en sesión 003. Rejas laterales corregidas con la variante de cristal FIP y capturas regeneradas. E1 permite continuar hacia el laboratorio E2; arte y accesos siguen pendientes.

## E2 — Laboratorio de pelota

Depende de E1. Objetivo: rebotes coherentes antes de golpes complejos.

- [x] P20 Elegir y registrar modelo de trayectoria/colisión con una prueba pequeña.
- [x] P21 Implementar gravedad y contactos con piso, vidrio, reja y red; parámetros ajustables.
- [x] P22 Resolver esquinas, impactos rápidos y eventos repetidos.
- [x] P23 Añadir lanzador de escenarios, reinicio y visualización de contactos/trayectorias.
- [x] P24 Ejecutar casos físicos a 30/60/120 FPS de render, cuando el equipo permita.
- [x] P25 Calibrar tras revisión del usuario: globo, vidrio y reja; incorporar fricción en cada pique y verificar recorrido completo hasta reposo (sesiones 005/006).

**Salida técnica, sesión 004:** 13 escenarios aprobados, incluido tiro de 60 m/s, esquina, reposo y salida por encima de reja. Un lanzamiento canónico a dos segundos coincide en procesos separados a 30/60/120 FPS programados (física 120 Hz). Tolerancias y límites en LABORATORIO_PELOTA.md y PRUEBAS.md. La calibración de sensación de juego se revisa con el usuario y seguirá en E3/E4; no se afirma cobertura de todos los tiros posibles.

## E3 — Movimiento y primer golpe

Depende de E2. Objetivo: devolver con intención.

- [x] P30 Definir acciones independientes del dispositivo de entrada.
- [x] P31 Implementar movimiento, límites y orientación.
- [x] P32 Añadir alcance, preparación y ventana de contacto del golpe base.
- [x] P33 Dirigir devolución con ayuda ajustable y un solo impacto por golpe.
- [x] P35 Revisar control según documento del usuario: potencia/liberación aprobadas en D43–D45 (ideal cerca del 90%, riesgo al 100%, defensa débil). Definir cancelación/caducidad y revisar plantado, apuntado y contacto automático. Ver REVISION_CONTROLES_ARCADE.md.
- [x] P37 Corregir equilibrio indefinido sobre cinta: contactos superiores lentos caen sin ganancia de energía; 35 casos y regresiones aprobados (sesión 013).
- [x] P36 Implementar y verificar contraste preparado/emergencia, calidad de contacto y recuperación antes de ampliar tiros. No modificar física aceptada sin evidencia.
- [x] P34 Validar sensación con el usuario: expresó «yo creo que la sensacion de juego está buena» tras probar la versión con riesgo de red. Aceptación cualitativa; no se midió duración de esa prueba humana.

**Avance sesión 012:** E3 aceptada cualitativamente por el usuario. P42 implementado y verificado para golpe base: preparación, contacto, acompañamiento, sonido y destello. Próximo paso: probar presentación, después P40 globo.

**Avance sesión 011:** usuario conforme con control; agregado riesgo de red para apuntado corto sobrecargado, verificado con contacto automático y física. Pendiente revisar este ajuste jugando.

**Avance sesión 010:** P35/P36 implementados y verificados técnicamente: plantado, carga/fijación, apuntado continuo, contacto automático, defensa y riesgo determinista. P34 de sensación humana continúa pendiente.

**Avance sesión 007:** movimiento, mapa de acciones, preparación/alcance y devolución física implementados. Noventa trayectorias y diez contactos en 30 s de integración automática aprobados; dos contactos mediante eventos grabados. Guía PRACTICA.md.

**Salida:** confirmar con el usuario control, alcance y comprensión de fallos (P34). No declarar diversión o comodidad validadas por el conductor automático de pruebas.

## E4 — Variedad y sensación de juego

Depende de E3. Objetivo: elegir un tiro cambia el intercambio.

- [x] P40 Añadir globo, remate contextual y volea con resultados distintos. Sesión 021: globo implementado con E/B, separado de plano Espacio/A; 54 trayectorias/tres feeds y controles verificados. Sesión 022: usuario acepta sensación de plano/globo («lo sentí bien»). Sesión 023: smash contextual y entrenamiento H/RB implementados, 54 trayectorias/tres feeds y poses revisados. Sesión 024: especiales x3/x4 implementados como combo y dirección, 36 salidas y tres H verificados. Sesión 028: volea contextual implementada, 54 trayectorias y tres R reales verificados. Calibración humana de golpes en P41.
- [ ] P41 Ajustar tiempos, potencia, precisión y asistencia. Sesión 027: feedback positivo de práctica; direcciones de especial pasan a diagonal adelante x3 y atrás x4 según intuición del usuario, pendiente nueva valoración. Sesión 026: H se alinea lateralmente al jugador para probar especial cerca de red; tres carriles con reacción 0.65 s y carga 90% verificados. Sesión 025: por incomodidad del combo, teclado cambia a J plano/smash, K globo y J+K especial; pendiente valoración humana. Sesión 020: calibrado segundo pique mediante agarre general del piso; feed 3.70→2.47 m entre piques. Pruebas técnicas aprobadas; sesión 022 acepta cualitativamente plano/globo. Calibración restante y valoración específica del segundo pique pendientes.
- [x] P42 Integrar animaciones y sonido provisionales para golpe base normal/perfecto/defensivo, sin cambiar autoridad del contacto. Sesión 014: poses derecha/revés, giro de torso/cadera, codos y apoyos; 18 casos y capturas verificados. Sesión 015: reposo relajado separado, recuperación al costado y uniones de hombro; verificación frontal/lateral. Sesión 016: drive prepara al costado y abre torso antes del impacto; codos y contrapeso revisados, revés conservado en comparación de seis casos. Sesión 017: abanicazo sin contacto ante fallo o pulsación vacía; cinco gestos y regresiones aprobados. Sesión 023: pose overhead para smash, cabeza/torso muestreados y capturas verificadas. Sesión 028: gesto compacto y acompañamiento corto de volea; contacto y geometría verificados. Revisión auditiva/visual del usuario pendiente.
- [ ] P43 Añadir rival simple de laboratorio y revisar diversión con el usuario. Sesión 029: rival opcional I/LB implementado; 60 s automáticos, 34 devoluciones/68 contactos, quince recepciones y cinco pares espejados. Reinicio, pausa y límites verificados. Valoración humana pendiente; E4 sigue activa.
- [x] P45 Prototipo de chiquita: carga baja + abajo, calidad independiente de carga, destino corto/arco y riesgo de red por contacto insuficiente. Sesión 019: 54 trayectorias, 24 transiciones y tres feeds reales aprobados; regresiones conservadas. Calibración humana pendiente en P41. Ver CHIQUITA.md.
- [ ] P44 Diseñar e implementar giro de pelota (topspin, slice y lateral) con pruebas separadas de vuelo y contacto; todavía no implementado. Sesión 024 reproduce salidas x3/x4 mediante trayectoria asistida, sin simular liftado real.

- [x] P46 Prototipo de especiales x3/x4 con combo, dirección y condiciones de preparación. Sesión 024: 36 salidas físicas, tres H reales y regresiones aprobadas; prueba humana pendiente. Sin giro real ni arbitraje completo.

**Salida:** intercambio de 30 segundos con decisiones de tiro que el usuario quiera repetir. Si no es divertido, iterar aquí.

## E5 — Parejas e IA

Depende de E4. Objetivo: 2 contra 2 con responsabilidades claras.

- [ ] P50 Incorporar compañero y dos rivales; asignar receptor.
- [ ] P51 Predecir llegada y elegir posición/tiro con reacción limitada.
- [ ] P52 Añadir cobertura, recuperación y prevención de cruces frecuentes.
- [ ] P53 Decidir jugador fijo o cambio de jugador con el usuario.
- [ ] P54 Probar pelotas al medio, globos y rebotes de fondo.

**Salida:** intercambio de parejas sin persecución colectiva ni bloqueos recurrentes.

## E6 — Reglas y partido

Depende de E5. Reglas puras pueden adelantarse cuando E2 tenga eventos estables.

- [ ] P60 Fijar puntuación, formato corto y simplificaciones.
- [ ] P61 Modelar saque, recepción, intercambio, fin de punto y siguiente punto.
- [ ] P62 Resolver secuencias piso/pared/reja y red según servicio o intercambio.
- [ ] P63 Añadir marcador y condiciones de victoria.
- [ ] P64 Probar doble falta, segundo pique, fuera, repetición de saque y cambios de lado según variante elegida.
- [ ] P65 Completar partido y revancha sin reiniciar programa.

**Salida:** partido corto de principio a fin con resultados reglamentarios explicables y probados.

## E7 — Primera versión para PC

Depende de E6. Objetivo: build que pueda probar otra persona.

- [ ] P70 Crear inicio, pausa, reinicio, resultado y ajustes esenciales.
- [ ] P71 Integrar arte/audio coherentes con procedencia registrada.
- [ ] P72 Medir rendimiento en PC de referencia y optimizar según evidencia.
- [ ] P73 Revisar texto, legibilidad, feedback y teclado/mando.
- [ ] P74 Exportar al SO elegido y probar fuera del editor.
- [ ] P75 Probar con otra persona, corregir fallos que impidan jugar y generar build identificable.

**Salida:** MVP local con partido completo, instrucciones y limitaciones conocidas. Publicación en tienda es una decisión posterior.

## E8 — Adaptación móvil

Depende de validar el MVP de PC, salvo la prueba temprana P81.

- [ ] P80 Elegir Android/iOS y dispositivo mínimo real.
- [ ] P81 Si hay teléfono disponible, probar exportación de cancha durante E2–E4 para detectar riesgos temprano.
- [ ] P82 Diseñar controles táctiles, áreas seguras y tamaños.
- [ ] P83 Ajustar cámara, tamaño aparente de pelota y ayudas.
- [ ] P84 Medir rendimiento/consumo y ajustar transparencias, sombras y shaders en dispositivo.
- [ ] P85 Probar interrupciones, pausa/reanudación y partidos completos.
- [ ] P86 Generar build móvil y decidir distribución por separado.

**Salida:** partido cómodo en dispositivo objetivo con rendimiento medido. Exportar no equivale a adaptar.

## Riesgos y respuesta

| Riesgo | Etapa | Respuesta |
| --- | --- | --- |
| Pelota diminuta por cámara lejana | E1 | Comparar encuadres antes de producir arte |
| Pelota atraviesa pared | E2 | Barridos/subpasos y velocidad límite |
| Golpe visual contradice contacto | E3–E4 | Una autoridad de contacto |
| Compañero interfiere | E5 | Asignación de receptor y cobertura |
| Animaciones consumen demasiado trabajo | E4 | Pocas acciones y assets provisionales |
| Alcance excesivo para una persona | Todas | Mantener exclusiones y cerrar etapas |
| Móvil obliga a rehacer | E3/P81 | Entradas separadas y prueba temprana |

## Calendario

Tras P05/P06 y una primera iteración de E1 registrar horas reales y disponibilidad semanal. Estimar de una a dos etapas por vez con margen para aprender. Todavía no hay base para prometer fecha del juego completo.
