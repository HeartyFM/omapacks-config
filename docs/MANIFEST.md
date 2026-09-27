# Esquema de contenido 1

La implementación normativa es `omapacks/manifest.py`: rechaza campos desconocidos,
tipos inválidos, destinos ajenos al namespace, rutas relativas ambiguas y operaciones
excluidas. `examples/v1/pack.toml` y `examples/v2/pack.toml` son ejemplos ejecutables.

Una entrega completa tiene `pack.toml`, `config/` o `modules/` con recursos propios,
y `NOTES.md`. El empaquetador solo admite archivos declarados y texto propio; no
copia dependencias externas, archivos personales, enlaces ni todo `~/.config`.
No hay ejecución shell genérica desde TOML. Los programas propios se entregan como
archivos declarados o fuentes externas fijadas y revisadas con constructor explícito.

## Campos

| Campo | Contrato |
|---|---|
| `schema` | Entero 1. |
| `id` | Identidad estable del conjunto, por ejemplo `diego-rafa.shared`; no un catálogo. |
| `version` | Versión semántica del contenido; independiente del gestor. |
| `manager_min` | Versión mínima del gestor. Nunca se reemplaza el gestor desde el contenido. |
| `compatibility` | `architectures` (x86_64/aarch64), opcionalmente `omarchy_min/max`, `hyprland_min/max` y `hyprland_format` (lua/conf/any). Versiones mínimas/máximas inclusivas. |
| `modules` | Lista con `id`, `version`, `description`, `requires` y `conflicts`. Todos forman parte de la release elegida. Dependencias ausentes/cíclicas y conflictos se rechazan. |
| `packages` | Dependencias por proveedor (abajo). Una dependencia compartida se declara una vez, en un módulo que otros requieren. |
| `files` | `module`, `source`, `target`, `scope`, opcionalmente `mode` decimal y `kind`. |
| `downloads` | Entregas externas: identidad, versión, arquitectura, URL HTTPS, SHA-256, tamaño, formato y propósito. |
| `flatpak_remotes` | `name`, `scope`, URL HTTPS de `.flatpakrepo`, `sha256`, `size`. El archivo debe declarar Url HTTPS y GPGKey. La adición se revisa explícitamente. |
| `operations` | Solo servicios declarados: `kind="service"`, `scope`, `name`, `action` (start/restart/enable), `module`, `purpose`. El administrador autoriza los nombres al configurar el gestor. |
| `recipes` | Solucionador tipado `wine-prefix-init`: condición obligatoria `prefix-absent`, propósito, id, módulo, arquitectura win32/win64 y prefijo nuevo bajo `.local/share/omapacks-data/wine/`. Se evalúa la condición antes de actuar. |
| `checks` | `module`, `kind`, `required`. Tipos: file (destino, scope y SHA), version (programa permitido, `--version` fijo), hyprland y wine-prefix (prefix). Una comprobación requerida fallida impide marcar la release instalada. |
| `migrations` | `id`, `from`, `to`, `precondition`, `description`. Transiciones de época sin scripts; precondiciones `managed-files-clean` o `no-packages`. Recorrido desde época instalada, IDs no repetibles; inversa no declarada bloqueada. |
| `recovery` | `epoch`, `limitations` (texto explícito), `reboot` booleano. |

## Archivos y preferencias

`source` vive en config/ o modules/. `scope="user"` admite:

- `.config/omapacks-shared/...`
- `.local/share/omapacks-content/...`
- `.local/bin/omapacks-NOMBRE`

`scope="system"` admite exclusivamente `etc/omapacks/NOMBRE.conf`, datos de modo
0600/0644. El nombre además debe estar autorizado por Diego en settings. El helper
root recibe una sola escritura o retirada, verifica el estado esperado y no sigue
symlinks. No acepta shell ni una ruta arbitraria de `/etc`.

`kind="hypr_include"` administra un bloque delimitado en la configuración principal
Lua o conf y un recurso independiente bajo omapacks-shared. Conserva el resto del
archivo principal y lo conserva también al retirar el include. Requiere formato
explícito, comprobación Hyprland y accesos esenciales detectables. Se hace validación
con `Hyprland --verify-config --config`, respaldo antes de activar, reload y
configerrors después, más comprobación de bindings esenciales. No se convierte Lua
↔ conf. No se admiten fragmentos comunes con monitor, input, ejecución o unbind.
Los fragmentos Lua se revisan como código; el filtro no constituye un aislamiento.

Las configuraciones de otras aplicaciones se entregan como archivos propios. Si
una aplicación no soporta includes/drop-ins en esos destinos, esta versión no
inventa cómo activarlos ni sobrescribe su configuración principal.

Al bajar de release solo se retiran recursos administrados ya ausentes en el destino.
Si el usuario los modificó, aparecen como conflictos. Conservar/omitir un recurso
que impide alcanzar el estado deseado produce estado parcial, no una instalación
completa falsa. No se eliminan paquetes ni datos Wine/personales automáticamente.

## Proveedores

- **Arch:** `provider="arch"`, `name`, `version` mínima. Se consulta instalado,
  repositorios habilitados y resolución transitiva. Se mantiene una versión más
  nueva existente. Transacción agrupada y versiones concretas; no `pacman -Sy`.
  Si la base local indica actualizaciones pendientes, se pide la ruta oficial
  `omarchy update` y después otro plan. Sincronicidad con mirrors/red no se presupone.
- **AUR:** `provider="aur"`, nombre/pkgbase simple, versión mínima, `commit` Git
  de 40 caracteres, texto `review`, `build_dependencies` declaradas como paquetes.
  Se muestra PKGBUILD y auxiliares completos y se registran revisión/hashes.
  makepkg corre como usuario, sin `-s` ni sudo; pacman instala el resultado con sus
  confirmaciones. Paquetes divididos ambiguos se bloquean. Fuentes variables VCS
  limitan la reproducibilidad. No se afirma aislamiento ni seguridad de terceros.
- **Flatpak:** ID, `remote`, `scope` user/system, `version` como commit OSTree
  de 64 caracteres, descripción `permissions`. Muestra metadata real del remote.
  Si falta infraestructura o remote se aprueba esa preparación y luego se recalcula.
  En instalación inicial descarga sin desplegar, comprueba el commit local y
  despliega sin volver a descargar. Las actualizaciones fijan `--commit`.
  Mantiene visibles las confirmaciones nativas de runtimes y permisos adicionales.
- **Externos:** `format` appimage, tar, arch o source-tar. `id`, `version`,
  `architecture`, `url`, `sha256`, `size`, `purpose`, `module`; `target` salvo
  paquetes Arch. Descarga máxima 128 MiB. AppImage requiere cabecera reconocida;
  tar rechaza enlaces, traversal, entradas duplicadas y expansión excesiva.
  Paquetes Arch se inspeccionan con pacman y se instalan con `pacman -U`.
  No conversión automática deb/rpm.
- **Herramientas propias desde fuente:** source-tar añade `revision` Git fija,
  `build` make/cargo, `check` ruta de la salida compilada y la herramienta de
  compilación como paquete declarado. La TUI muestra las fuentes y pide aprobación
  para compilar. Después presenta otro plan con hashes de los archivos producidos.
  Cargo usa locked/offline. Código de compilación sin aislamiento; usuario normal.
- **Wine/emuladores:** se declaran paquetes y comprobaciones específicas. `--version`
  acredita el ejecutable, no juegos ni aplicaciones. La receta Wine crea únicamente
  un prefijo nuevo y verifica su estructura; nunca ejecuta Wine como root ni pisa
  prefijos, bibliotecas, partidas, claves o contenido protegido existentes.

Kernels, controladores, firmware, cifrado, particiones y arranque se rechazan también
en paquetes resueltos y servicios relacionados. No hay receta shell que eluda esto.

## Contrato de publicación y consulta

Assets fijos: `omapacks.json`, `omapacks.json.sig`, `omapacks.tar.gz`. Firma SSH
OpenSSH, identidad `omapacks-release`, namespace `omapacks-v1`; clave pública inicial
instalada una vez. Índice y todos los recursos autenticados. El seleccionador fija
repositorio/release ID/tag, asset IDs/tamaños/digests/updated_at; se revalida antes de
instalar. No usa main ni vuelve a resolver latest.

Releases ordenadas por published_at descendente; empate por ID numérico descendente.
Fechas ausentes/inválidas al final con etiqueta, sin sustituir por created_at.
Paginación de hasta 100 páginas ×100 releases; alcanzar el límite se informa como
incompleto. Timeout de red 15 s por operación de socket, presupuesto total de descarga
90 s, hasta 3 intentos y máximo 5 redirecciones. Caché fechada solo como listado:
instalar exige revalidación online. Un 404 no permite distinguir públicamente entre
repositorio privado oculto e inexistente, y se informa de esa limitación de GitHub.

Fuentes oficiales:
https://docs.github.com/en/rest/releases/releases
https://docs.github.com/en/rest/releases/assets
https://man.openbsd.org/ssh-keygen

## Menú, aplicaciones predeterminadas y activación (gestor ≥ 0.2.0)

- `omarchy_menu`: destino exacto `.config/omarchy/extensions/omarchy-menu.jsonc`;
  source es JSON con entradas `omapacks.shared` y descendientes. Campos: label,
  description, icon, parent, title, action. Acciones admitidas: grupos vacíos,
  `omarchy-launch-about`, `omarchy-launch-terminal` y `uwsm-app -- gtk-launch ID.desktop`
  con ID validado. No shell arbitrario, guards ni rutas personales. Combina únicamente
  las claves administradas; conserva comentarios/entradas ajenas incluso al bajar
  de release. La shell observa cambios mediante FileView; no requiere reiniciarla.
- `xdg_defaults`: destino exacto `.config/mimeapps.list`; source es JSON con `mime`
  (tipo MIME → desktop ID), `terminal` y `editor`. `preferences.py` enumera aplicaciones
  y dependencias admitidas. En esta versión, Kitty y Neovim son los selectores de
  terminal/editor soportados; MIME admite las ocho aplicaciones del candidato.
  Genera cambios acotados en mimeapps, xdg-terminals y el default editor de Omarchy.
  Conserva asociaciones ajenas, comentarios y terminales alternativos. Registra
  valores previos por clave para restaurarlos al retirar una preferencia.
  Comprueba el resultado con xdg-mime, xdg-terminal-exec y omarchy-default-editor:
  un archivo escrito no garantiza que otra preferencia del escritorio no lo oculte.

El candidato `content/desktop-v1.0.0` muestra ambos contratos. Su fuente no exporta
protocolos de autenticación ni el agente Codex/mise, proveedor aún no implementado.

Las recargas se calculan en el plan y se registran con fase starting/done. Dependencias,
archivos y comprobaciones previas terminan antes de la recarga explícita de Hyprland;
configerrors y bindings se comprueban después. Un fallo deja estado parcial. Hyprland
y la shell pueden observar escrituras automáticamente: no se promete activación atómica.

El grupo raíz `omapacks.shared` declara `parent = "root"` explícitamente.
Omarchy infiere el padre de IDs con puntos; omitirlo dejaría el grupo bajo un padre inexistente.
