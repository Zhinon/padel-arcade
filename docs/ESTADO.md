# Estado y próxima sesión

Actualizado: 28/10/2026, zona America/Argentina/Mendoza. Sesión 011.

## Dónde estamos

**E3 revisada con contacto automático; P34 de sensación humana pendiente.** Mantener Espacio planta/carga; soltar fija potencia; el direccional apunta y la pelota dispara el contacto al llegar. Zona ideal inicial 86–94%, con posición, altura y equilibrio favorables. Defensa tardía alcanzable débil y con menos dirección. Sobrecarga hacia fondo/lateral puede causar cerramiento directo sin pique; apuntar hacia abajo con sobrecarga reduce altura y puede tocar red. El usuario expresó conformidad con la sesión 010 y pidió este ajuste.

El lanzador espera R; T cambia entre tres zonas. Nueva pulsación tras fijar cancela; caducidad 3 s, pausa cancela preparación. Recuperación 0.18/0.28 s sin impedir movimiento después del contacto. Cámara y coeficientes de rebote E2 conservados.

Godot 4.7.2.stable.official.ed1daf0bf portátil. Git local main, sin remoto. P06 (equipo objetivo/mando) pendiente.

## Comprobado en sesión 010

- Importación del proyecto sin errores de scripts después de corregir un tipo explícito.
- Carga fijada sin impacto remoto, apuntado tras fijar, tiro perfecto preparado, defensa mínima, frenado en carrera, cancelación, caducidad, contacto mientras se mantiene y un solo golpe por pelota. Conservación de posición/reloj/RNG. Pausa/foco/F8.
- Dos casos de sobrecarga con mala calidad simulados hasta primer impacto: cerramiento de fondo y lateral antes del piso, sin RNG del tiro.
- 90 trayectorias de ayuda base, diez devoluciones en 30 s de integración sintética. No son pruebas humanas.
- Regresiones E2: 13 escenarios de pelota, calibración de veinte semillas y 22 recorridos hasta reposo aprobados; globo 2.00 m y reja máximo 4.25 m de retorno.
- Demostración de seis segundos mediante entradas de Godot con dos contactos. Capturas 720p/360p inspeccionadas; render llvmpipe CPU, sin afirmación de rendimiento objetivo.

## Límites

No hay rival activo, arbitraje, puntos, giro ni tiros avanzados. El mensaje de sobrecarga informa riesgo, no declara falta sin resolver la secuencia. Los otros tres personajes están estáticos. Pala procedural provisional; pelota sin colisión con cuerpos. Mando solo comprobado sintéticamente. No se repitió comparación FPS antigua: simulación pasiva y coeficientes no se modificaron.

## Verificado en sesión 011

- Nuevo riesgo gradual de red para apuntado hacia abajo y sobrecarga; no hay sorteo de fallo. Se aplica después de la ayuda de arco para que no lo corrija automáticamente.
- Mismo contacto exigido a 90% y 100% por el flujo de impacto automático: primer contacto piso rival frente a red, respectivamente. Casos anteriores de fondo/lateral conservados.
- Pruebas de control, 90 trayectorias nominales, diez devoluciones sintéticas y 13 regresiones de pelota aprobadas. Importación sin errores de scripts; el editor informó bloqueo de puertos locales por sandbox. No hubo render ni nueva prueba humana de este ajuste.

## Próximo paso

**P34: probar el nuevo ciclo con el usuario.** Evaluar plantado, apuntado, velocidad de carga, zona del 90%, alcance, defensa y recuperación. Ajustar aquí antes de E4. Los detalles técnicos provisionales están en D46–D49 y PRACTICA.md.

## Abrir

`./tools/run-godot.sh`. R recibe; WASD/flechas mueve o apunta preparando; Espacio carga/soltar fija; pulsar de nuevo tras fijar cancela; T cambia zona; P pausa/continúa; F8 laboratorio.

Laboratorio anterior: `-- --lab` o `-- --scenario=7`. Reglas y límites de física en LABORATORIO_PELOTA.md.

## Cierre

Actualizar plan, pruebas y bitácora, registrar decisiones y guardar punto de recuperación Git.
