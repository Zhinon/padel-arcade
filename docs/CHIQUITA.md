# Chiquita y golpes de poca potencia

Primera implementación — 28/10/2026, sesión 019. Parámetros provisionales; valoración jugable del usuario pendiente.

## Referencia deportiva

[The Padel School: Use the Chiquita!](https://thepadelschool.com/resources/padel-tips/use-the-chiquita) describe una pelota lenta a los pies del rival, que lo obliga a devolver hacia arriba y puede facilitar avanzar a la red. Hay que elegir una pelota favorable; avanzar no es automático.

[The Perfect Padel Return](https://thepadelschool.com/resources/blog/the-perfect-padel-return) destaca colocación y control por encima del tipo de efecto. Podemos comenzar sin implementar spin.

## Acuerdo y propuesta

El usuario está de acuerdo con distinguir golpe suave deliberado de devolución pobre por llegar tarde, y propone la chiquita como referencia. El usuario autorizó avanzar. La siguiente asignación está implementada para probar, con calibración pendiente:

1. Llegar y plantarse con anticipación.
2. Cargar poco y soltar para fijar potencia, conservando la preparación hasta el contacto automático.
3. Apuntar hacia abajo para buscar profundidad corta; izquierda/derecha elige colocación lateral.
4. Producir trayectoria suave que descienda a la zona de los pies de un rival situado cerca de la red. No tiene que morir inmediatamente detrás de la red.

La calidad debe depender del tiempo total preparado, equilibrio, posición y altura al contacto, aunque se haya fijado poca carga. Soltar pronto no significa llegar tarde. El 90% sigue siendo referencia del golpe potente; no debe ser requisito para considerar excelente una chiquita.

## Cambio implementado

El solucionador anterior mantenía objetivos relativamente profundos. Ahora dirección abajo y carga baja mezclan progresivamente hacia un objetivo de pique a 1.6 m de la red rival y un arco bajo. Se resuelve con la misma gravedad y arrastre de pelota; velocidad horizontal inicial limitada a 8 m/s en chiquita completa. Contactos altos/cercanos pueden producir una pelota más flotada para respetar ese límite. Carga insuficiente más mal contacto reduce margen de red después de asistencia: puede fallar físicamente. Golpe potente conserva trayectoria y sobrecarga previas.

Buen contacto y potencia suave elegida: colocación controlada. Llegada tardía: potencia y dirección limitadas. Energía/arco insuficientes: posible red. Trayectoria demasiado alta o profunda: pelota atacable. Resultados explicables mediante trayectoria y contacto, sin sorteo arbitrario de error.

No añadir inicialmente otro botón, seguimiento automático del rival ni avance automático del jugador. Carga hasta 40% y dirección abajo completa dan chiquita; entre 40–65% se mezcla hacia golpe base. El componente abajo mezcla entre 0.2–0.8 (diagonal incluida). Se recomienda comenzar probando 20–40%. Los valores quedan abiertos a calibración. Excelente contacto con 12–40% puede recibir feedback perfecto sin exigir 90%.

## Primera validación propuesta

- Comparar carga baja fijada temprano con igual carga preparada tarde: la primera conserva mejor dirección y calidad.
- Probar desde distintas distancias y alturas: observar paso de red, zona de descenso, primer pique y velocidad; una zona objetivo representa los pies del rival.
- Verificar límites entre tiro corto válido, red y pelota flotada, sin alterar el golpe potente aceptado ni su riesgo de red al apuntar corto.
- Primero práctica sin rival; evaluar el efecto táctico de ganar la red cuando exista rival activo. La diversión y facilidad requieren prueba humana.

## Evidencia de sesión 019

`tests/chiquita_checks.gd`: 54 trayectorias (z de jugador 1.3/5/9 m, altura 0.3/0.9/1.8 m, tres direcciones, cargas 20/40%), 24 transiciones de carga/apuntado y tres lanzamientos reales por zonas. Todas llegan al piso rival cerca del objetivo (<0.25 m). Igual carga fijada temprano conserva más control que tardía. Intento mínimo exigido toca red. Caso cómodo: cruce a 1.162 m y primer pique a 1.600 m de red; golpe potente de comparación pica a 3.700 m. La pelota tiene radio 0.105 m.

Regresiones de jugador (90 trayectorias y diez devoluciones), tres impactos/audio, cinco abanicazos y 35 contactos de cinta aprobadas. Importación sin errores de scripts. Captura nativa de trayectoria revisada desde cámara de juego; no prueba humana ni rival táctico. Informe en previews/chiquita-checks.json.


## Segundo pique — sesión 020

El usuario observó demasiado recorrido después del primer pique. La prueba anterior terminaba en el primer contacto: validaba destino, pero omitía esta parte de la experiencia. Se amplió hasta el segundo pique, registrando separación horizontal, tiempo, altura máxima y velocidades de entrada/salida. Datos previos guardados en previews/chiquita-bounce-before.json (código 78d5750, ejecutor ampliado antes del ajuste) y video histórico chiquita-bounce-before.mp4.

Referencias de NOX y The Padel School confirman intención suave/corta a los pies; no proporcionan metros entre piques. Rod Cross, en Physics Today, explica pérdida horizontal por fricción y diferencias entre deslizamiento/agarre. Es referencia física de pelota de tenis, no medición de césped de pádel: no justifica un número exacto para nuestro juego.

Se calibra agarre efectivo del piso por pendiente de entrada: fricción base 0.18, hacia 0.42 entre pendientes 0.35–0.85. La pérdida extra se acota a 50% de velocidad tangencial; si la base ya pierde más se conserva. Después sigue retención 0.94. No depende de nombre del golpe y afecta también otras caídas pronunciadas. Restitución vertical 0.68, gravedad, vuelo de la chiquita y rodadura conservados. Aproximación arcade sin giro simulado, no modelo completo de deformación, spin o materiales.

| Caso reproducible | Separación antes | Separación ahora |
| --- | --- | --- |
| Chiquita cómoda sintética | 4.02 m | 2.65 m |
| Chiquita de lanzador habitual | 3.70 m | 2.47 m |
| Drive 90% apuntado corto | 5.10 m | 3.35 m |

Estos valores son resultados del prototipo, no distancias universales de pádel. Altura del rebote habitual ~0.73 m; no se redujo restitución vertical. Casos variados de chiquita dan 0.51–3.64 m entre piques. Criterio de calibración para los casos cómodo/feeds: 1.5–3.0 m, sin pared intermedia. Falta valoración del usuario del nuevo bote y de otros golpes afectados.

La primera prueba con mayor fricción anulaba avance de globo empinado antes del vidrio. El límite de pérdida extra conserva su secuencia piso/vidrio/piso. Regresiones de pelota, superficies, recorridos, control y cinta pasan; estados/eventos del caso canónico coinciden a 30/60/120 FPS con física a 120 Hz. Video actual chiquita.mp4 regenerado y revisión gráfica de ambos piques realizada.
