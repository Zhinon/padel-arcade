# Volea contextual — sesión 028

## Control y práctica

Se usa **J / A del mando**, como el plano: mantener prepara/carga, soltar fija, contacto automático. K/B conserva el globo. No se añade un botón.

Para probar: colocarse en el carril de recepción, aproximadamente a **3 metros de la red**, pulsar **R** y enseguida preparar J. Soltar cerca del 90% y apuntar mientras se espera. R conserva su trayectoria habitual; H sigue siendo el globo de smash. Para probar derecha/revés, colocarse un poco a un costado de la trayectoria. Con T se cambia el carril y se lanza otra pelota.

## Selección

Volea cuando una pelota activa viene hacia el jugador (velocidad z >0.1 m/s), en su mitad (z>=0.25), entre **0.45 y 2.1 m** de altura y aún no picó en su mitad desde el último golpe. Historial anterior al último golpe no bloquea una nueva volea; un pique en mitad rival tampoco. Una pelota que ya picó en esta mitad conserva golpe de fondo/chiquita. Una pelota más alta conserva la ventana previa de smash. Solo el plano activa esta variante; combinación especial mantiene su comportamiento anterior.

Alcance horizontal provisional **1 m**, sin mover al jugador ni ampliar la autoridad de contacto. Calidad favorece distancia 0.6 m, altura 1.25 m, preparación y equilibrio. Llegada tardía permite una devolución exigida dentro del alcance, con potencia y colocación limitadas.

## Resultado y gesto

Destino nominal a 4.5 m de la red rival, con dirección/profundidad según calidad. Volea preparada usa velocidad horizontal nominal 10–17 m/s según potencia efectiva, ajustando tiempo de vuelo para margen de red de centro 1.2 m. Son parámetros arcade ajustables; no simula efecto cortado. Una volea baja puede necesitar arco ascendente para superar la red. Volea exigida usa devolución suave existente. Con potencia efectiva inferior a 0.18, un contacto bajo o de mala calidad pierde margen de red después de la asistencia: puede quedar en la red. Un tiro suave bien preparado a altura cómoda conserva margen. El 100% conserva sobrecarga determinista: abajo puede tocar red; muy profundo puede tocar directamente vidrio de fondo y muy abierto puede tocar vidrio/reja lateral rival antes del piso. No hay probabilidad aleatoria de fallo.

Preparación compacta delante del cuerpo, derecha/revés seleccionados automáticamente y acompañamiento corto de 0.16 s. Pala coincide con contacto físico, recuperación preparada 0.14 s (exigida conserva 0.28 s). Se reutilizan sonidos/destellos por calidad. No cambia física de pelota, cámara ni controles existentes.

## Verificación

Godot 4.7.2.stable.official.ed1daf0bf, 120 Hz. `volley_checks.gd`: 54 trayectorias (z jugador 1.5/3/5, altura 0.5/1.25/2, offset lateral ±0.4, tres direcciones) y tres R reales. Fixtures estáticos hasta contacto y vuelo físico después en la matriz; feeds reales no recolocan pelota al contacto. Primer contacto piso rival con error <0.25 m. Tres R con 90.625% y calidad ~0.880: contacto a 1.706 m y salida horizontal ~15.68 m/s.

Verificados: devolución tardía más débil/menos dirigida, poca carga suave, sobrecarga corta toca red, tiro muy débil/bajo toca red, suave cómodo pasa y sobrecargas profundas/laterales tocan cerramiento antes del piso, selección después de pique/entre golpes/K/smash/baja/saliente, un contacto y recuperación configurada. Segmentos de brazos muestreados contra torso/cabeza en contacto/acompañamiento, tolerancia conservadora 0.008 m. Presentación no modifica cuerpo o velocidad física. Son pruebas técnicas; no prueban comodidad humana ni todos los casos posibles.

[Preparación](previews/volley-preparation.png) · [Contacto](previews/volley-contact.png) · [Video](previews/volley.mp4) · Informe `previews/volley-checks.json`. Capturas/video con entradas sintéticas, sin audio; renderer local llvmpipe, sin benchmark de equipo objetivo.

Pendiente: valoración humana del ritmo y gesto, rival de entrenamiento y efecto cortado real.
