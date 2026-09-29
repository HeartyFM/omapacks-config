# Prueba completa 1.1.2 · escritorio, OmaSettings y captura

## Resumen
Prueba el escritorio compartido, el panel OmaSettings y las capturas completas.
Incluye el menú, la barra, la apariencia y las preferencias de aplicaciones de
1.1.0, también al actualizar desde 1.0.0. Es una release completa de prueba.

## Apps y plugins
- OmaSettings 1.3.0: panel de ajustes del escritorio. Se activa como servicio y se
  abre desde el lanzador de aplicaciones. No se sustituye la barra.
- Se conservan las aplicaciones y plugins del pack anterior. Las dependencias que
  falten en este equipo aparecen en el plan; OmaSettings requiere jq.

## Modificaciones
- Hyprland · Capturas: Super+Shift+S guarda una captura de pantalla completa,
  sin seleccionar una región. Cualquier acción previa se presenta como conflicto.
- Omarchy · Interfaz y paneles: se incorpora OmaSettings manteniendo otros plugins.
- Navegación y apariencia: incluye el menú con About, Learn y Games, la barra
  compartida y los ajustes de apariencia de Hyprland de 1.1.0. Al venir de 1.0.0
  estos elementos también cambian; el plan muestra los conflictos de tu equipo.
- Aplicaciones predeterminadas: conserva las asociaciones compartidas de 1.1.0;
  las preferencias personales se resuelven por recurso, con decisión y respaldo.
