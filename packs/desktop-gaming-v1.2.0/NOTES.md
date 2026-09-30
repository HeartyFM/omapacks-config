## Resumen
Base de escritorio y juegos para Rafa: cristal, barra y menú de Diego, aplicaciones predeterminadas y Spotify OmarchyGlass. Las aplicaciones quedan instaladas para abrirlas cuando quieras.

## Apps y plugins
- Steam, Discord, Minecraft Launcher, Roblox mediante Sober y CurseForge.
- Spotify con Spicetify, Marketplace, tema OmarchyGlass, adaptación a ventanas estrechas y widget musical.
- Plugins habilitados de Diego: barra, menú, indicadores, controles de navegador, portapapeles, emojis, recordatorios, OSD, pruebas de red/disco, QR Wi-Fi, paneles de red/pantalla y Lock Screen Explorer.
- hyprmoncfg y su plugin: herramienta de monitores sin perfiles personales y sin habilitar ni iniciar su servicio. Su puesta en marcha será una decisión local de Rafa.
- AirPods, System Monitor y Context Indicator quedan excluidos. OmaSettings no está activo en Diego y deja de formar parte de esta release; se retira únicamente su copia administrada, si existía.

## Modificaciones
- Hyprland: bordes finos y rectos, blur suave, animaciones verticales y cursor visible. La selección de renderizador del cursor permanece local.
- Menú: Games/About, aplicaciones predeterminadas compartidas y ocultación reversible de quince accesos web.
- Limpieza revisable: retirar Cursor, Foot, Moonlight y Signal cuando estén instalados. Sin cascada de dependencias ni eliminación de datos personales; el plan muestra sus nombres antes de confirmar.
- Spotify se prepara sin abrirlo, sobre una copia privada. Ninguna aplicación de juegos se inicia al descargarla; no se añaden entradas de autoarranque.
- Al terminar se recargan Hyprland y la shell y se comprueban los accesos esenciales.
- Requiere Omarchy 4.0.4-1.1 o superior y gestor 0.4.0. Una versión de Omarchy inferior bloquea el pack: actualiza primero mediante su actualizador oficial. Versiones posteriores deben superar también la validación de configuración.
- No incluye hardware, perfiles de pantalla, dispositivos, GPU, energía, kernel, Limine, arranque ni preferencias de inicio.

## Recuperación y límites
Restaurar archivos no reinstala aplicaciones retiradas ni revierte paquetes. Spotify conserva la instalación del sistema y sus cuentas; las copias preparadas quedan bajo omapacks-data. Su parche de cristal exige los hashes revisados de Spotify 1.2.96.518; otra versión necesita una receta nueva, nunca offsets supuestos o un downgrade. Las verificaciones de instalación no prueban inicio de sesión, juegos ni reproducción. Rafa abrirá cada aplicación por primera vez. La compatibilidad del Lenovo debe comprobarse allí.
