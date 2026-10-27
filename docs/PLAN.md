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
- [ ] P34 Probar 30 segundos con el usuario y registrar sensaciones. Integración automática de 30 s aprobada en sesión 007; no reemplaza esa prueba humana.

**Avance sesión 007:** movimiento, mapa de acciones, preparación/alcance y devolución física implementados. Noventa trayectorias y diez contactos en 30 s de integración automática aprobados; dos contactos mediante eventos grabados. Guía PRACTICA.md.

**Salida:** confirmar con el usuario control, alcance y comprensión de fallos (P34). No declarar diversión o comodidad validadas por el conductor automático de pruebas.

## E4 — Variedad y sensación de juego

Depende de E3. Objetivo: elegir un tiro cambia el intercambio.

- [ ] P40 Añadir globo, remate contextual y volea con resultados distintos.
- [ ] P41 Ajustar tiempos, potencia, precisión y asistencia.
- [ ] P42 Integrar animaciones y sonido provisionales sin cambiar autoridad del contacto.
- [ ] P43 Añadir rival simple de laboratorio y revisar diversión con el usuario.
- [ ] P44 Diseñar e implementar giro de pelota (topspin, slice y lateral) con pruebas separadas de vuelo y contacto; todavía no implementado.

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
