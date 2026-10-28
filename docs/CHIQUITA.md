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
