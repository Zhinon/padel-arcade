# Plano y globo — sesión 021

Primera versión jugable, 28/10/2026. Parámetros provisionales; valoración humana pendiente.

## Controles

| Golpe | Teclado | Mando configurado |
| --- | --- | --- |
| Plano | Mantener/soltar J | A |
| Globo | Mantener/soltar K | B |

Ambos plantan al jugador, permiten apuntar con el mismo direccional, cargan mientras mantenés y fijan al soltar. Contacto automático al llegar pelota, incluso manteniendo. La chiquita sigue siendo variación del plano: 20–40% y abajo.

Otra pulsación del mismo botón cancela una preparación fijada. Otro botón cambia el golpe seleccionado, inicia carga nueva desde cero y conserva tiempo plantado/equilibrio. Soltar el botón anterior no fija la carga del nuevo. Después de contacto se necesita una pulsación nueva para otro intento. R, pausa y cambio a laboratorio limpian preparación. Mando físico pendiente: mapa A/B comprobado con evento sintético.

## Globo

La carga elige altura y profundidad, no simplemente velocidad horizontal. Parámetros exportados: apex 3.0–5.5 m y profundidad base 4.0–8.0 m, modulados por calidad/potencia efectiva. Direccional lateral coloca; arriba pide profundidad, abajo acorta. Destino nominal limitado a 3–9 m de red. Trayectoria resuelta usando gravedad/arrastre y pasos físicos existentes; ningún cambio de posición para llegar a destino.

Caso cómodo sintético con pelota (0,0.9,6.15): carga 25% alcanza 3.65 m y pica a 5.00 m de red rival; ~90% alcanza 5.25 m y pica a 7.58 m. La ayuda no garantiza todos los contactos posibles cerca de red o en condiciones extremas. Defensa tardía tiene menor carga efectiva, menor dirección y destino más corto. Sobrecarga >94% extiende destino y puede llegar directo al cerramiento; conserva arco alto, sin reutilizar aplanamiento de riesgo de red del plano.

Presentación reutiliza poses provisionales derecha/revés y sonidos de clases normal/excelente/defensa. No hay rival que responda ni volea contextual. Desde sesión 023, el botón de plano permite smash contextual; ver SMASH.md. Giro de pelota pendiente. Cámara, física pasiva y segundo pique de chiquita conservados.

## Verificación

`./tools/run-godot.sh --headless --script res://tests/lob_checks.gd`.

54 contactos: jugador z=2/5/9 m, pelota relativa (0,h,-0.65), h=0.3/0.9/1.8 m, apuntado (±0.6,∓0.8) y neutro, cargas 30/90%. Se usan eventos de teclado K y contacto físico automático. Todos llegan primero a piso rival con error <0.25 m, apex visible en cámara actual. También tres feeds reales sin mover pelota al contacto; comparación de carga, defensa tardía y sobrecarga al cerramiento. Cambio de botones durante carga/fijada, liberación vieja, cancelación, mantener sin repetir, foco, pausa, R y laboratorio comprobados. No prueba humana ni mando físico.

Regresiones de plano/control (90 trayectorias/diez devoluciones), chiquita (54/24/tres feeds y segundo pique), impactos/audio (tres) y abanicazos (cinco) aprobadas. Importación sin errores de scripts; capturas nativas de vuelo y controles a 640×360 revisadas. El render usa llvmpipe y no mide rendimiento objetivo.

[Demostración de tres segundos](previews/lob.mp4), sin audio y con contacto sintético. [Captura](previews/lob.png). Informe: previews/lob-checks.json.


## Valoración humana — sesión 022

Tras la implementación, el usuario dijo «lo sentí bien». Sensación general aceptada como base; no se registraron duración de prueba, dispositivo o casos particulares. Mantener esta base al añadir remate/volea.


Controles actualizados en sesión 025 a J/K. Las capturas y videos de sesiones previas pueden mostrar Espacio/E.
