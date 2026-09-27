# Configuración compartida · OmaPacks

Releases completas de configuración para Diego y Rafa, independientes del gestor.
Para instalar OmaPacks, añade el [plugin](https://github.com/HeartyFM/omapacks-plugin)
desde **Setup → Plugin → Add Plugin** de Omarchy. No pegues este repositorio allí.

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
