# Smash contextual — sesión 023

Primera versión, 28/10/2026. Pendiente valoración jugable del usuario; plano/globo anteriores aceptados.

## Probar

1. **H** recibe un globo por la zona seleccionada; en mando configurado, **RB**. **T** cambia zona y lanza pelota normal; después H permite probar allí.
2. Ubicate en la trayectoria. En la zona inicial el globo llega al jugador sin tener que correr.
3. Prepará con **J/A** con anticipación y soltá cerca del **90%**. Direccional apunta mientras estás plantado.
4. Cuando la pelota desciende a altura alcanzable sobre la cabeza, sale smash automáticamente. **K/B** conserva globo y no se convierte en smash.
5. **R** vuelve a recibir pelota normal. H no es un botón de golpe, solo un lanzamiento de práctica.

## Condiciones y compromiso

Se reutiliza intención FLAT del botón de plano; no se añade botón de smash. Condiciones provisionales: pelota entre 2.15–2.65 m, descendiendo o casi en apex (velocidad vertical <=0.5 m/s), por delante o hasta 0.1 m detrás del jugador, en su mitad. Alcance horizontal 0.75 m; altura cómoda 2.4 m y separación ideal 0.4 m. No salto, estiramiento ilimitado ni desplazamiento automático del cuerpo.

Al entrar en zona de contacto puede esperar hasta 0.09 s para alcanzar altura más cómoda. Ejecuta antes si baja de 2.48 m o se acerca al plano del jugador. El caso H contacta a ~2.447 m con buena preparación, sin golpear apenas llega al borde superior. Pelotas altas fuera de alcance esperan o fallan: el avatar no atrapa pelotas de 3 m o a distancia horizontal de 1.5 m. Al bajar pueden volverse golpe plano si siguen alcanzables.

Tiempo total de preparación y estabilidad siguen contando tras fijar potencia. La calidad se calcula con altura/distancia propias del remate. Contacto exigido usa devolución suave y menos dirección, en lugar de potencia de ataque equivalente. Carga baja alta no se transforma en chiquita: mantiene intención de golpe por arriba con menos velocidad.

## Trayectoria

Smash preparado apunta a piso rival con destino del plano y velocidad horizontal nominal 13–26 m/s según potencia efectiva. Se calcula la velocidad con el mismo integrador de gravedad/arrastre; un golpe preparado fuerte desciende hacia el piso. Contactos de baja carga, profundos o exigidos pueden tener arco de devolución en vez de remate descendente. El smash normal no fuerza salida ni regreso. Desde sesión 024, el combo especial permite intentar x3/x4; ver SMASH_ESPECIALES.md.

Sobrecarga conserva pérdida de margen: apuntar corto puede tocar red, profundo/abierto puede llegar al cerramiento antes de piso. Sin sorteo arbitrario de error. Física pasiva, fricción de piso, vidrio, reja y red conservadas; giro pendiente. No hay puntos/arbitraje/rival activo.

## Presentación

Preparación con pala arriba/detrás de cabeza, torso de costado y brazo libre elevado. Pose de impacto coincide con pelota; acompañamiento pasa arriba y al costado antes de bajar, evitando cortar por la cabeza. Se reutilizan sounds/destellos normal, excelente y defensa; movimiento se recupera igual que antes. Rig geométrico provisional, sin animación esquelética de producción.

## Evidencia

smash_checks.gd: 54 trayectorias, jugador z=2/5/8.5, alturas 2.2/2.4/2.6, x relativo ±0.35, z relativo -0.35, tres apuntados, carga ~90%. Contactos reales automáticos con eventos de J; pelota estática de prueba se coloca en ventana antes de simular vuelo. Primer contacto piso rival, error <0.25 m, velocidad vertical inicial negativa. Tres feeds H reales sin colocar pelota en el impacto completan remate: altura ~2.447 m, calidad ~0.976, salida horizontal ~24.40 m/s y primer pique a 5.5 m de red rival.

También comparadas llegada tardía, cuatro situaciones imposibles/prematuras, K que conserva globo y riesgo 100% corto/profundo. Pose muestreada contra torso/cabeza en preparación, contacto y acompañamiento; mínimo registrado ~0.0031 m y tolerancia de penetración conservadora 0.008 m. Contacto de pala <0.0001 m y presentación no cambia cuerpo/pelota. No garantía exhaustiva de todas las geometrías posibles.

Regresiones: jugador 90/diez, globo 54/tres feeds, chiquita 54/24/tres feeds y segundo pique, tres impactos/audio, cinco abanicazos y 18 poses anteriores aprobadas. Importación sin errores de scripts. Capturas cercanas de preparación/contacto/acompañamiento y cámara de juego revisadas. Video de cinco segundos con H y entradas sintéticas, sin audio. Sin prueba humana del smash ni mando físico; llvmpipe no representa rendimiento objetivo.

[Demostración](previews/smash.mp4) · [Preparación cercana](previews/smash-preparation-close.png) · [Contacto](previews/smash-contact-close.png) · [Acompañamiento](previews/smash-follow-close.png). Informe en previews/smash-checks.json.


Controles actualizados en sesión 025 a J/K. Las capturas y videos de sesiones previas pueden mostrar Espacio/E.
