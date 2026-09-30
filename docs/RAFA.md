# Rafa: actualizar OmaPacks y recibir la base compartida

Esta guía corresponde al **gestor 0.4.0 / configuración 1.2.2 Prueba**.
Selecciona 1.2.2 cuando aparezca publicada en OmaPacks. Esta revisión retira la
comparación obligatoria con la versión de Omarchy de Diego. La release anterior
1.2.0 conserva su requisito original. La prueba del Lenovo sigue pendiente.

1. **Comprobar juntos el punto de partida.** Ejecuta `omarchy version` y
   `~/.local/bin/omapacks --version`. La versión de Omarchy se registra para
   diagnóstico: **1.2.2 no exige igualar o superar la versión de Diego**. Se mantienen
   arquitectura x86_64, Hyprland ≥0.56.2 en Lua, herramientas nativas y dependencias.
   Si falta un requisito técnico, revisa el motivo concreto antes de seguir. Si Diego te entrega
   `Comprobar-OmaPacks.py`, ejecuta `python3 Comprobar-OmaPacks.py`: muestra solo
   versiones, origen y operaciones pendientes. No modifica nada ni necesita el
   proyecto de desarrollo. Con pendientes, revisad la recuperación antes de seguir.

2. **Actualizar el gestor.** Si ya tienes 0.3.3, abre
   **Update → Configuración compartida**, selecciona **v1.2.2 · Prueba** y acepta
   **Actualizar gestor** cuando el reporte lo solicite. Descarga una entrega estable
   firmada de `HeartyFM/omapacks-plugin` y después vuelve a revisar el pack.
   Para una instalación antigua o nueva: **Setup → Plugin → Update** sobre OmaPacks,
   o **Setup → Plugin → Add** con `https://github.com/HeartyFM/omapacks-plugin` si
   todavía no existe. Acepta la oferta **0.4.0**. Si cerraste la oferta, ejecuta
   `python3 ~/.config/omarchy/plugins/heartyfm.omapacks/bootstrap.py --interactive`.
   No hace falta desinstalar ni borrar la confianza. Origen de contenido esperado:
   `HeartyFM/omapacks-config`; huella:
   `SHA256:Y3eeDXbuQIbHZ4TYaWGMSQRV+Gg9yKqpjcXuyMlO6G0`.
   Verifica que `~/.local/bin/omapacks --version` muestre 0.4.0 y que conserve tu
   versión de contenido anterior. Este paso no instala el pack ni actualiza Omarchy.

3. **Revisar e instalar v1.2.2.** Abre **Install/Update → Configuración compartida**.
   Revisa las novedades, paquetes, código AUR/plugins, cambios de preferencias y
   conflictos. La retirada de Cursor, Foot, Moonlight y Signal aparece expresamente
   si están instalados; conserva sus datos. Puedes volver sin instalar.
   Flatpak puede pedir una primera preparación de infraestructura/remotes y luego
   otro plan: revisa ambos. Confirma únicamente el plan que quieras aplicar y las
   preguntas nativas de permisos. No se abren los juegos ni Spotify al instalar.

4. **Comprobar el resultado juntos.** Tras «Instalación completada correctamente»,
   ejecuta `~/.local/bin/omapacks support-report`: contenido 1.2.2 y sin pendientes.
   Comprueba barra, Games/About, terminal, captura Super+Shift+S, apps predeterminadas,
   cursor y monitores. Luego abre tú Steam, Discord, Minecraft Launcher, Sober
   (Roblox), CurseForge y Spotify. Comprueba Marketplace, ventana estrecha y widget
   musical. Inicios de sesión, reproducción y juegos se verifican aquí, no se dan por
   probados al instalar. hyprmoncfg queda disponible sin perfiles de Diego y sin
   activar su daemon. AirPods y configuraciones de hardware/arranque no se copian.

5. **Si aparece un fallo.** Conserva el mensaje de fase/recurso; no borres diarios
   ni encadenes instalaciones. Comparte `support-report` y el error concreto con
   Diego. Revisad «Restaurar archivos» antes de confirmar: no revierte paquetes,
   retiradas ni servicios. Elegir una release anterior calcula otro plan y no baja
   Arch/Omarchy. Si Spotify cambió de versión y el cristal no es compatible, se
   detiene: hace falta una receta revisada, nunca forzar el parche ni bajar Spotify.
