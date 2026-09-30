# Configuración compartida · OmaPacks

Releases completas de configuración para Diego y Rafa, independientes del gestor.
Para instalar OmaPacks, añade el [plugin](https://github.com/HeartyFM/omapacks-plugin)
desde **Setup → Plugin → Add Plugin** de Omarchy. No pegues este repositorio allí.

## Base 1.2.3 · gestor mínimo 0.4.2 · Prueba

Corrige la selección de proveedores Vulkan al instalar Steam. El gestor consulta
las bibliotecas y GPU del destinatario, completa Mesa/Vulkan para Radeon o Intel
en un plan revisable y conserva el bloqueo de NVIDIA. No copia la GPU de Diego
ni modifica kernel, arranque o Secure Boot. Mantiene todo el contenido de 1.2.2
y no vuelve a imponer un mínimo de Omarchy igual al de Diego.
[Guía para Rafa](docs/RAFA.md). Gestor 0.4.2 estable y pack 1.2.3 Prueba publicados y verificados mediante descarga
anónima, firmas y hashes. 194 pruebas locales y resolución real con pacman
completadas; la aplicación de paquetes y el Lenovo quedan pendientes.

## Base 1.2.2 · gestor mínimo 0.4.0 · Prueba

Conserva el contenido completo de 1.2.0 y elimina únicamente el requisito de que
Omarchy sea igual o posterior a la versión de Diego. Se mantienen x86_64,
Hyprland ≥0.56.2 en Lua, herramientas nativas, dependencias, firmas y verificaciones.
Las versiones de Omarchy anteriores ya no se bloquean por su número; todavía deben
cumplir esos requisitos técnicos. No incluye el trabajo Secure Boot aplazado.
Fuentes: `packs/desktop-gaming-v1.2.2`. [Guía de Rafa](docs/RAFA.md).
Los assets de la release 1.2.0 permanecen intactos con su política original.

## Base 1.2.0 · gestor mínimo 0.4.0 · Prueba

Fuentes completas en `packs/desktop-gaming-v1.2.0`: escritorio de cristal, blur,
bordes rectos, animaciones verticales, cursor visible, Games/About, defaults,
Spotify/Spicetify/Marketplace/OmarchyGlass y plugins habilitados de Diego.
Añade Steam, Discord, Minecraft Launcher, Roblox mediante Sober y CurseForge.
Las aplicaciones se abren manualmente, después de instalar.

Requiere **Omarchy 4.0.4-1.1 o superior**, x86_64 y Hyprland Lua compatible.
Incluye hyprmoncfg sin perfiles ni daemon; excluye AirPods, hardware, Limine y arranque.
La retirada de Cursor, Foot, Moonlight y Signal aparece expresamente en el plan y
no borra datos ni retira otras dependencias. OmaSettings deja de formar parte de esta
base porque no está activo en Diego; se retira solo su copia administrada.

[Guía para Rafa](docs/RAFA.md) · [Acompañamiento](docs/ACOMPANAR_RAFA.md) ·
[Notas completas](packs/desktop-gaming-v1.2.0/NOTES.md).
174 pruebas locales correctas; actualización del gestor desde 0.2.1/0.3.3 y recorrido
completo del pack en aislamiento. Spicetify/Marketplace se prepararon realmente sin
lanzar Spotify; sintaxis Hyprland y manifiestos de plugins verificados con herramientas
nativas. Paquetes/privilegios/IPC simulados, sin prueba del Lenovo todavía.
La receta Spotify exige hashes compatibles y los commits Flatpak fijados; un cambio
del proveedor puede requerir otra receta. No se fuerza una instalación incompatible.

## Prueba completa 1.1.2 · gestor mínimo 0.3.3

Fuentes en `packs/desktop-v1.1.2-test`. Conserva el escritorio completo 1.1.0
(menú, barra, apariencia y defaults) y añade OmaSettings 1.3.0 fijado por commit/hash
y Super+Shift+S para guardar una captura completa. Desde 1.0.0 también cambian menú
y barra; el plan identifica los conflictos personales de cada equipo.
Omarchy 4.0.4, Hyprland 0.56.2, Lua y x86_64. Prerelease de prueba.

[Actualizar y probar con Rafa](docs/RAFA.md). Flujo aprobado por Diego. Suite de
157 pruebas correcta y actualización 0.2.1 → 0.3.3 comprobada en namespace aislado.
También se probó Remove → Add y reinstalación conservando el estado.
Pack 1.0.0 → 1.1.2 → reinstalación → 1.0.0, recuperación y firmas verificadas.
Paquetes e IPC simulados: no equivale a instalar el pack en el Lenovo ni a comprobar
el panel OmaSettings o la captura allí. La prueba real sigue pendiente.

## Primera entrega: escritorio 1.0.0

Fuentes: `packs/desktop-v1.0.0`. Apariencia compartida de Hyprland, submenú Compartido
y aplicaciones predeterminadas; las dependencias se declaran y no se incluyen binarios.
Omarchy 4.0.0–4.0.4, Hyprland 0.56.2, Lua y x86_64. La compatibilidad se comprueba
antes de instalar. No se copian monitores, escalado, GPU, discos, energía ni datos personales.

Validaciones locales en Diego: sintaxis nativa aislada, 52 defaults y plan sin conflictos.
El gestor/plugin pasó 77 pruebas y su instalación inicial se probó en terminal real con
HOME temporal. Todavía no hay instalación del pack en la sesión personal ni pruebas en
el Lenovo. Arch/AUR/Flatpak y las recargas no están verificados de extremo a extremo en Rafa.

Las [releases](https://github.com/HeartyFM/omapacks-config/releases) llevan índice,
firma SSH y archivo de contenido. El plugin incluye la clave pública autorizada;
la privada permanece fuera de ambos repositorios.

## Crear otra release

Lee [la guía para agentes](docs/CREAR_PACKS_CON_IA.md) y el [manifiesto](docs/MANIFEST.md).
Copia el pack completo, cambia versiones/recursos, valida y prueba. Publica fuentes
revisadas en un commit y genera los tres assets firmados con el gestor. El comando
`omapacks publish` muestra una previsualización; `--yes` publica con autorización.
No se reemplazan assets ya publicados. Gaming e importación se prepararán después.

Desde el gestor 0.3.3, `manager_min` permite ofrecer una actualización firmada del
gestor cuando hace falta, con aprobación separada y un plan nuevo para el pack.
El contenido nunca elige otra URL, clave o instalador. [Contrato](docs/ACTUALIZACION_GESTOR.md).
