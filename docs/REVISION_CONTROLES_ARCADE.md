# Revisión de controles arcade — 28/10/2026

## Referencia y alcance

El usuario propone un diseño inspirado en Virtua Tennis 1/2: anticipar → correr → posicionarse → preparar → impacto automático → recuperar. Es una referencia de experiencia deseada, no una comprobación histórica del funcionamiento exacto de esos juegos. Esta revisión no modifica el prototipo ni convierte propuestas de detalle en decisiones aprobadas.

Es viable con la arquitectura actual de Godot. La dificultad principal es ajustar la sensación mediante juego humano, no agregar todas las animaciones o estados de una vez.

## Diferencia con la versión actual

Hoy Espacio carga y soltar abre la ventana de contacto; el jugador conserva 60% de movilidad preparando. La potencia depende del tiempo; posición y altura son filtros de contacto. Preparación menor a 0.10 s se rechaza. El objetivo de salida tiene asistencia fuerte.

El diseño propuesto requiere plantarse, usar el direccional principalmente para apuntar y golpear automáticamente al llegar la pelota. La calidad deberá considerar preparación, posición, altura y equilibrio. Una llegada tardía alcanzable debería permitir defensa débil, sin garantizar devoluciones imposibles.

## Detalles por resolver antes de implementarlos

1. **Elegir potencia con contacto automático.** Llegar temprano y mantener siempre termina en máxima carga. Propuesta: mantener carga; soltar fija la potencia elegida, pero no ejecuta el golpe. El personaje sigue preparado y permite apuntar hasta el contacto automático. Es una opción de diseño pendiente, no una mecánica confirmada de Virtua Tennis. Deben definirse cancelación, caducidad y nueva pulsación tras recuperar para evitar golpes repetidos por mantener el botón.
2. **Ventana de contacto.** Priorizar una zona cómoda dentro de una ventana corta; no golpear siempre en el primer borde del alcance asistido. Ajuste de pies acotado, nunca grandes deslizamientos. Fallar depende de pelota y alcance, no solo de un temporizador arbitrario.
3. **Calidad comprensible.** Conservar un mínimo defensivo si el contacto es posible. Evitar multiplicar penalizaciones hasta hacer inútil toda devolución exigida. Mostrar causas: tarde, desequilibrado o contacto incómodo. Los parámetros y umbrales son provisionales.
4. **Riesgo adaptado a pádel.** La línea de fondo no funciona como límite de aterrizaje del tenis: un pique en campo rival seguido de vidrio/reja puede seguir en juego. El impacto directo contra pared/reja rival antes del piso es falta. Modelar riesgo mediante trayectoria y margen real, sin sortear un porcentaje arbitrario de fallo. Un golpe máximo bien preparado debe ser fiable; uno forzado puede perder margen, ir directo al cerramiento o dejar una defensa fácil. Fuente: [FIP, reglas 12–13, revisión 01/01/2026](https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf).

## Iteración propuesta

- **Primero:** estados explícitos, frenado al preparar, apuntado separado del movimiento, contacto automático y recuperación breve. Una sola devolución, con contraste preparado/emergencia. Definir también liberación/cancelación.
- **Después:** calidad continua por posición, altura y equilibrio; potencia elegible y riesgo de trayectoria. Los intervalos 70/90% son hipótesis para probar, no constantes definitivas.
- **Luego:** mejorar animación y sonido, ampliar tipos de golpe y sumar rival. No hacen falta lanzamientos acrobáticos para validar el núcleo.

Mantener cámara y calibración de rebotes aceptadas. No añadir giro como efecto implícito de potencia.

## Validación prevista

Comparar misma pelota con jugador plantado, tarde y fuera de alcance. Comprobar que apuntar no permite correr a máxima velocidad, que soltar no dispara si se adopta la propuesta, que solo existe un impacto por intento y que se recupera movimiento rápidamente. Probar máxima potencia con contacto bueno y malo sin errores aleatorios del golpe. Las pruebas automáticas verifican comportamiento; la satisfacción requiere prueba humana. No se ejecutaron pruebas del motor en esta revisión documental.
