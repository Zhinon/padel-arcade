# Revisión de controles arcade — 28/10/2026

## Referencia y alcance

El usuario propone un diseño inspirado en Virtua Tennis 1/2: anticipar → correr → posicionarse → preparar → impacto automático → recuperar. Es una referencia de experiencia deseada, no una comprobación histórica del funcionamiento exacto de esos juegos. El usuario confirmó el 28/10/2026 la selección de potencia al soltar, el objetivo de tiro perfecto cerca del 90% y la defensa tardía débil. Implementados técnicamente en sesión 010; la sensación sigue pendiente de prueba humana.

Es viable con la arquitectura actual de Godot. La dificultad principal es ajustar la sensación mediante juego humano, no agregar todas las animaciones o estados de una vez.

## Diferencia con la versión anterior (sesión 007)

En sesión 007, Espacio cargaba y soltar abre la ventana de contacto; el jugador conserva 60% de movilidad preparando. La potencia depende del tiempo; posición y altura son filtros de contacto. Preparación menor a 0.10 s se rechaza. El objetivo de salida tiene asistencia fuerte.

El diseño propuesto requiere plantarse, usar el direccional principalmente para apuntar y golpear automáticamente al llegar la pelota. La calidad deberá considerar preparación, posición, altura y equilibrio. Una llegada tardía alcanzable debería permitir defensa débil, sin garantizar devoluciones imposibles.

## Acuerdos y detalles pendientes

1. **Elegir potencia con contacto automático.** Llegar temprano y mantener siempre termina en máxima carga. Acuerdo: mantener carga; soltar fija la potencia elegida, pero no ejecuta el golpe. El tiro perfecto exige llegar a tiempo, estar bien colocado, cargar aproximadamente al 90% y soltar; acertar la carga por sí solo no garantiza calidad. El personaje sigue preparado y permite apuntar hasta el contacto automático. Es un acuerdo de diseño para este juego, no una mecánica histórica verificada de Virtua Tennis. Deben definirse cancelación, caducidad y nueva pulsación tras recuperar para evitar golpes repetidos por mantener el botón.
2. **Ventana de contacto.** Priorizar una zona cómoda dentro de una ventana corta; no golpear siempre en el primer borde del alcance asistido. Ajuste de pies acotado, nunca grandes deslizamientos. Fallar depende de pelota y alcance, no solo de un temporizador arbitrario.
3. **Calidad comprensible.** Acuerdo: conservar una devolución defensiva si el contacto es posible, con poca potencia y menor capacidad de direccionamiento. Modelar ese menor control comprimiendo la intención hacia una devolución más central y segura, como propuesta técnica a probar. Evitar multiplicar penalizaciones hasta hacer inútil toda devolución exigida. Mostrar causas: tarde, desequilibrado o contacto incómodo. Los parámetros y umbrales son provisionales.
4. **Riesgo adaptado a pádel.** La línea de fondo no funciona como límite de aterrizaje del tenis: un pique en campo rival seguido de vidrio/reja puede seguir en juego. El impacto directo contra pared/reja rival antes del piso es falta. Modelar riesgo mediante trayectoria y margen real, sin sortear un porcentaje arbitrario de fallo. Acuerdo: el 100% aumenta el riesgo de impacto directo en cerramiento rival sin pique: fondo si se busca profundidad, lateral si se busca ángulo. No equivale a fallo obligatorio al alcanzar 100%; el resultado depende de carga, dirección y calidad del contacto. El 90% es la referencia de equilibrio deseada; anchura de esa zona y penalización por sobrecarga se ajustarán jugando. Fuente: [FIP, reglas 12–13, revisión 01/01/2026](https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf).

## Iteración propuesta

- **Primero:** estados explícitos, frenado al preparar, apuntado separado del movimiento, contacto automático y recuperación breve. Una sola devolución, con contraste preparado/emergencia. La liberación ya está acordada; definir cancelación/caducidad.
- **Después:** calidad continua por posición, altura y equilibrio; potencia elegible y riesgo de trayectoria. El objetivo de soltar cerca del 90% está acordado; tiempos, tolerancia y magnitudes siguen pendientes de calibración.
- **Luego:** mejorar animación y sonido, ampliar tipos de golpe y sumar rival. No hacen falta lanzamientos acrobáticos para validar el núcleo.

Mantener cámara y calibración de rebotes aceptadas. No añadir giro como efecto implícito de potencia.

## Validación prevista

Comparar misma pelota con jugador plantado, tarde y fuera de alcance. Comprobar que apuntar no permite correr a máxima velocidad, que soltar fija carga sin disparar, que solo existe un impacto por intento y que se recupera movimiento rápidamente. Probar máxima potencia con contacto bueno y malo sin errores aleatorios del golpe. Las pruebas automáticas verifican comportamiento; la satisfacción requiere prueba humana. No se ejecutaron pruebas del motor en esta revisión documental.

## Implementación sesión 010

El ciclo y los acuerdos ya están implementados. Provisionales: cancelación al pulsar de nuevo tras fijar, caducidad total 3 s, zona ideal 86–94%, preparación sin movimiento objetivo, ventana cómoda 0.06 s, recuperación 0.18/0.28 s. Emergencia comprime apuntado hacia el centro; sobrecarga extiende profundidad/ángulo según calidad. Ver PRACTICA.md y D46–D48 para los detalles actuales. La evaluación humana sigue pendiente; las propuestas previas de este documento se conservan como contexto.
