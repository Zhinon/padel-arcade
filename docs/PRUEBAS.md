# Plan y registro de pruebas

## Estado actual

Solo se pueden comprobar los archivos preparados y el formato de las skills. Importación, ejecución, cámara y gameplay requieren Godot y siguen pendientes. Los casos siguientes son el plan de validación, no resultados aprobados.

## Escenarios mínimos

| ID | Etapa | Escenario | Resultado a comprobar |
| --- | --- | --- | --- |
| T00 | E0 | Importar y ejecutar escena inicial | Sin errores del motor; piso y cámara visibles |
| T10 | E1 | Cuatro jugadores y pelota en extremos | Se distinguen y no quedan tapados |
| T11 | E1 | Globo y pelota junto al fondo cercano | Seguimiento visual posible en 16:9 y ventana pequeña |
| T20 | E2 | Caída vertical, impacto frontal y oblicuo | Respuesta consistente con parámetros fijados |
| T21 | E2 | Velocidad máxima contra piso/pared/red | Sin atravesar superficies ni quedar atrapada |
| T22 | E2 | Impacto cerca de esquina | Orden de contactos estable, sin doble conteo |
| T23 | E2 | Mismo lanzamiento a 30/60/120 FPS | Trayectorias equivalentes dentro de tolerancia fijada en P20 |
| T30 | E3 | Preparación temprana/tardía y fuera de alcance | Contacto o fallo comprensible; nunca golpe remoto |
| T31 | E3 | Mantener y soltar botón | Como máximo un impacto autorizado por golpe |
| T40 | E4 | Base/globo/remate/volea | Diferencias de altura, tiempo y destino observables |
| T50 | E5 | Pelota al medio de pareja | Receptor asignado y compañero cubriendo |
| T51 | E5 | Globo y rebote de fondo | Recuperación sin bloqueo recurrente |
| T60 | E6 | Piso rival → vidrio versus vidrio rival directo | Resultado conforme a regla confirmada; separar servicio/intercambio |
| T61 | E6 | Segundo pique sin devolución | Un solo fin de punto y marcador actualizado una vez |
| T62 | E6 | Saque, falta, doble falta y repetición | Transiciones según variante elegida en P60 |
| T63 | E6 | Partido y revancha | Termina y reinicia sin estado residual |
| T70 | E7 | Ejecutable fuera del editor | Inicia y permite completar partido |
| T80 | E8 | Táctil e interrupción en teléfono | Control cómodo y reanudación coherente |

Antes de automatizar reglas, consultar FIP y registrar la variante/simplificación adoptada. No tratar una hipótesis de esta tabla como reglamento ya implementado.

## Registro por ejecución

Fecha y responsable; ID del caso; versión del motor; revisión de código; escena/build; equipo; posición/velocidad inicial y semilla si aplica; entradas; esperado; observado; aprobado/fallido/pendiente; evidencia y siguiente acción. Unidades y tolerancias se fijan con la implementación.

Gravedad de fallos: impide jugar, altera reglas, dificulta control/lectura o detalle visual. Corregir primero los que impiden jugar y los que cambian el resultado del punto.

## Prueba de diversión

En E4 jugar sesiones breves y anotar: ¿se entiende por qué se falló?, ¿se puede dirigir el tiro?, ¿hay decisiones útiles?, ¿la cámara deja seguir la pelota?, ¿dan ganas de repetir? Requiere evaluación humana; no se demuestra con un test automático.
