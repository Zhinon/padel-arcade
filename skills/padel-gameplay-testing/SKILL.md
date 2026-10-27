---
name: padel-gameplay-testing
description: Diseñar y ejecutar pruebas de gameplay de Pádel Arcade para rebotes, golpes, secuencias reglamentarias, cámara e IA de parejas. Usar al implementar o corregir estas mecánicas; no para cambios solo documentales.
---

# Pruebas de gameplay de Pádel Arcade

Localizar la raíz y leer docs/PRUEBAS.md, docs/ESTADO.md y la decisión que define el comportamiento afectado. Distinguir regla deportiva, simplificación de prototipo y ajuste arcade. Consultar la fuente FIP en docs/FUENTES.md si la expectativa reglamentaria no está resuelta.

## Escenarios reproducibles

Registrar versión del motor, revisión o estado del código, escena, semilla si existe, posición y velocidad inicial de pelota, último golpeador, entradas y resultado esperado/observado. Usar unidades y tolerancias explícitas, sin exigir igualdad exacta entre flotantes ni prometer determinismo entre plataformas.

Priorizar según el cambio:

- Pelota: piso, vidrio, reja, red, esquinas y velocidades límite. Buscar penetraciones, eventos duplicados y diferencias al variar FPS de render manteniendo el paso físico.
- Reglas: comparar secuencias de contactos, como piso rival → vidrio frente a vidrio rival directo. Separar servicio e intercambio y confirmar la variante reglamentaria antes de fijar expectativas.
- Golpes: fuera de alcance, preparación temprana/tardía, dos jugadores próximos y un solo impacto por golpe. Medir dirección y altura como resultados observables.
- Parejas: un receptor asignado, cobertura y recuperación; evitar que todos persigan la pelota.
- Cámara: globos y pelota junto al fondo cercano o paredes; probar 16:9 y pantalla pequeña. Comprobar percepción humana además de geometría.

## Evidencia

Automatizar reglas puras y escenarios físicos repetibles cuando existan. Evaluar diversión, comodidad y lectura manualmente. Si falta ejecutor, documentar el caso pendiente sin crear un framework grande para una prueba aislada.

Para fallos guardar pasos mínimos, esperado/observado y gravedad. Tras corregir, repetir el caso y vecinos relevantes. Guardar resultados en docs/PRUEBAS.md y actualizar ESTADO.md y BITACORA.md. Una revisión estática no equivale a una prueba ejecutada.
