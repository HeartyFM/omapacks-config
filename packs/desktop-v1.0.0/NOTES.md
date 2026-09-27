Escritorio compartido · 1.0.0

Primera configuración compartida para probar con Rafa; aún no verificada en el
Lenovo. Compatibilidad limitada a las versiones observadas; si Rafa tiene
otras, el gestor lo explica y bloquea la instalación antes de cambiar archivos.

Revalidado localmente el 27-09-2026 en Omarchy 4.0.4-1, Hyprland 0.56.2-2
y Lua/x86_64: sintaxis nativa, 52 defaults, modelo de menú y plan del equipo.
El rango declarado es Omarchy 4.0.0–4.0.4; los extremos tienen evidencia local,
no pruebas independientes de cada versión intermedia. No incluye todavía una
activación del pack en el escritorio personal ni una prueba en el Lenovo.

Qué cambia
- Bordes finos grises, esquinas rectas y desenfoque de las superficies de Omarchy.
- Texto del terminal opaco y transición vertical de espacios de trabajo.
- Submenú Compartido con Acerca del equipo y acceso al terminal local.
- Recarga final de Hyprland, comprobación de errores y de accesos esenciales.
  El menú usa su recarga automática nativa; no se reinicia la shell entera.

Qué se conserva
- Los defaults de la versión instalada de Omarchy, con un include de apariencia encima.
- El teclado, monitores, escalado, GPU y energía de cada persona.
- Asociaciones ajenas a las declaradas, comentarios y secciones personales.
- Entradas ajenas del menú, archivos personales y acceso al terminal/menú.

La extensión del menú es una selección portable, no una copia de las entradas de
juegos de Diego: varias apuntan a rutas privadas y aplicaciones aún ausentes.
Discord, Steam, Heroic y Wine se prepararán en una release posterior que también
incluya este escritorio. La herramienta de importación queda para después.

Aplicaciones predeterminadas
Firefox para la web, Kitty como terminal, Neovim como editor, Nautilus para carpetas,
imv para imágenes, Evince para PDF, mpv para vídeos y Zen para los tipos HTML que
Diego tiene asociados a Zen. El plan muestra cambios de preferencias y permite
conservar conflictos. Las aplicaciones ausentes y herramientas AUR se declaran
como dependencias; Zen requiere revisión de PKGBUILD y archivos auxiliares.
No se cierran ni reinician aplicaciones que ya estén abiertas.

No se transportan registros de autenticación de CurseForge, Claude o ChatGPT, ni
perfiles de navegador. Codex aparece como agente personal de Diego instalado con
mise: ese proveedor todavía no está implementado, así que no se modifica esa
preferencia ni se instala el agente mediante una orden improvisada.
