# Esquema de contenido 1

La implementación normativa es `omapacks/manifest.py`: rechaza campos desconocidos,
tipos inválidos, destinos ajenos al namespace, rutas relativas ambiguas y operaciones
excluidas. `examples/v1/pack.toml` y `examples/v2/pack.toml` son ejemplos ejecutables.

Una entrega completa tiene `pack.toml`, `config/` o `modules/` con recursos propios,
y `NOTES.md`. El empaquetador solo admite archivos declarados y texto propio; no
copia dependencias externas, archivos personales, enlaces ni todo `~/.config`.
Desde gestor 0.3.0 admite también bytecode Qt de un shader propio, acotado y
acompañado por su fuente declarada; no admite otros binarios en `files`.
No hay ejecución shell genérica desde TOML. Los programas propios se entregan como
archivos declarados o fuentes externas fijadas y revisadas con constructor explícito.

El candidato 0.3.2 conserva el esquema 1 y la compatibilidad anterior. Añade solo
`capture_shortcut` y descargas `omarchy-plugin`, que exigen `manager_min="0.3.2"`.
No abre `input`, `unbind`, comandos ni destinos genéricos. El teclado compartido y
la activación de temas siguen pendientes en [FUTURO_PACK.md](FUTURO_PACK.md).
Las releases anteriores conservan su `manager_min`; siempre se calcula un plan nuevo.

## Actualizar el gestor cuando lo requiere un pack (≥ 0.3.3)

`manager_min` sigue siendo el único campo: no añadir instaladores, claves, URLs o
acciones de actualización a `downloads`, `operations` ni al reporte editorial.
Tras verificar firma e integridad del contenido, se puede leer su identidad y
`manager_min` aunque tenga un esquema futuro. Es solo una vista previa: el motor
actual no valida ni ejecuta ese esquema. La TUI advierte que aún no se ha calculado
el plan del pack y permite actualizar el gestor, volver o consultar detalles.

El repositorio del gestor y la clave inicial proceden del instalador configurado,
no del contenido. Se exige una release estable superior a la instalada y suficiente
para el requisito, con assets `omapacks-manager.json`, `.json.sig`, `.tar.gz`.
Índice, repositorio, tag, versión, archivos y permisos se verifican mediante firma
OpenSSH en el namespace separado `omapacks-manager-v1` y hashes SHA-256. La entrega
no puede cambiar origen ni confianza. No se usan releases en caché/incompletas.

Antes de reemplazar se revalidan release, gestor, confianza, permisos configurados y
estado del contenido bajo el mismo bloqueo de operaciones. Se conserva una copia
del gestor anterior. Tras activar, un proceso nuevo vuelve a verificar la release
de contenido y calcula otro plan: no se hereda su aprobación. Cancelar la instalación
del pack después conserva el gestor actualizado. No se actualiza el checkout del
plugin ni el sistema Omarchy, ni se promete revertir paquetes. Una interrupción
abrupta queda registrada y requiere comparar las copias antes de recuperar.

Las versiones públicas antiguas no tienen este recorrido; primero se reinstala el
gestor nuevo por Add Plugin. Ver [RAFA.md](RAFA.md) y [ACTUALIZACION_GESTOR.md](ACTUALIZACION_GESTOR.md).

## Reporte editable y firmado

`NOTES.md` forma parte del índice firmado. En las nuevas releases, sus tres primeras
secciones deben ser `## Resumen`, `## Apps y plugins` y `## Modificaciones`, en ese
orden. Se mantienen aunque estén vacías; el lector muestra mensajes explícitos.
Se pueden añadir secciones después (máximo diez en total, títulos sin repetir).
La guía y la skill del proyecto definen el estilo editorial. No se admiten escapes
ANSI del contenido: los colores los elige la TUI. La prosa describe la intención;
el plan calcula el estado real, permisos, dependencias y conflictos del equipo.
Las releases antiguas sin ese formato reciben un resumen compatible de tres
secciones y conservan sus notas originales en Detalles.

## Campos

| Campo | Contrato |
|---|---|
| `schema` | Entero 1. |
| `id` | Identidad estable del conjunto, por ejemplo `diego-rafa.shared`; no un catálogo. |
| `version` | Versión semántica del contenido; independiente del gestor. |
| `manager_min` | Versión mínima del gestor. Desde 0.3.3, el reporte ofrece una actualización firmada del gestor como requisito previo, con autorización independiente. No admite código/URL de actualización en el pack. |
| `compatibility` | `architectures` (x86_64/aarch64), opcionalmente `omarchy_min/max`, `hyprland_min/max` y `hyprland_format` (lua/conf/any). Versiones mínimas/máximas inclusivas. |
| `modules` | Lista con `id`, `version`, `description`, `requires` y `conflicts`. Todos forman parte de la release elegida. Dependencias ausentes/cíclicas y conflictos se rechazan. |
| `packages` | Dependencias por proveedor (abajo). Una dependencia compartida se declara una vez, en un módulo que otros requieren. |
| `files` | `module`, `source`, `target`, `scope`, opcionalmente `mode` decimal y `kind`. |
| `capture_shortcut` | Preferencia exacta de captura descrita abajo; requiere gestor ≥ 0.3.2. |
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
- `.config/omarchy/plugins/omapacks.shared.NOMBRE/...` (con manifiesto y entry points declarados)

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

### Captura tipada (gestor ≥ 0.3.2)

```toml
[capture_shortcut]
key = "SUPER + SHIFT + S"
mode = "fullscreen"
output = "save"
```

Esta es la única combinación admitida. Requiere compatibilidad Lua y un check
Hyprland obligatorio. Genera la llamada nativa fija
`omarchy-capture-screenshot fullscreen save` en el drop-in administrado, tras los
ajustes de apariencia. El include se coloca al final al crearlo; si ya existe, se
conserva su posición. No altera bindings.lua ni input.lua. El motor consulta el
binding activo, muestra cualquier colisión, exige una decisión y revalida la
identidad antes de aplicar. También detecta la colisión cuando el include no cambia.
Variantes de submapa, release, longPress o mouse se bloquean para revisión manual.
Al conservar el atajo, también se conserva el drop-in: la release queda parcial.
Después de la recarga debe aparecer una sola acción con la descripción generada;
una configuración posterior que la oculte impide declarar éxito.
Retirar la preferencia elimina solo el código generado y vuelve a cargar los
archivos ajenos preservados. No restaura callbacks temporales o cambios externos
hechos sin archivo. No habilita `unbind`/`bind` en los fragmentos aportados por packs.

`kind="omarchy_shell"` (gestor >= 0.3.0) tiene destino fijo
`.config/omarchy/shell.json`. Su recurso JSON contiene únicamente `bar`,
`disabledPlugins=["omarchy.menu"]` y `cloneSourceRestores=[ID_DEL_MENU]`.
La barra y el menú utilizan plugins propios declarados y widgets nativos.
Se guarda el valor previo de la barra y cada pertenencia administrada de las listas;
otros plugins, idle y bloqueo se conservan. El retroceso restaura esos valores.
Una barra personal distinta requiere aprobar un reemplazo con respaldo.

`kind="omarchy_style"` tiene destino fijo `.config/omarchy/shell.toml` y solo
admite los tokens definidos de `[bar]` y `[menu]`. Mezcla claves y conserva
otras secciones/comentarios. Retirar el recurso restaura los valores previos.
La shell observa escrituras individuales: no se promete una activación atómica.
Después se verifican archivos, manifiestos nativos y se solicita rescanPlugins.

`kind="qt_shader"` permite exclusivamente `*.frag.qsb` de modo 0644 dentro de un
plugin `omapacks.shared.NOMBRE`, hasta 128 KiB, junto con su `*.frag` declarado.
La revisión de publicación debe recompilar la fuente con Qt Shader Baker y
comparar el resultado. No se ejecutan ni se permiten shaders ejecutables.

`kind="omarchy_menu"` conserva su namespace y admite además la organización
acotada About/Learn/Games y lanzadores `apps.ID` cuyo comando solo puede ser
`uwsm-app -- gtk-launch ID.desktop`. No admite `when` ni shell arbitrario.
El menú compartido filtra estos juegos mediante el catálogo nativo instalado.
Se conservan las otras entradas y los comentarios; desde 0.3.0 se guarda también
la entrada previa para restaurarla al retirar un override.

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
  Desde 0.3.1 un fallo de consulta no equivale a ausencia. El nombre pedido debe
  identificar un paquete concreto; si la consulta devuelve otro nombre, se bloquea
  para revisar la receta. No existe equivalencia global `mime-types=mailcap`.
  El fixture de la receta 1.1.0 registra Provides/Conflicts/Replaces reales y esa
  receta declara mailcap explícitamente, incluidas las dependencias de Zen.
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
- **Externos:** `format` appimage, tar, arch, source-tar u omarchy-plugin. `id`, `version`,
  `architecture`, `url`, `sha256`, `size`, `purpose`, `module`; `target` salvo
  paquetes Arch. Descarga máxima 128 MiB. AppImage requiere cabecera reconocida;
  tar rechaza enlaces, traversal, entradas duplicadas y expansión excesiva.
  Paquetes Arch se inspeccionan con pacman y se instalan con `pacman -U`.
  No conversión automática deb/rpm.
- **Plugin nativo externo (≥ 0.3.2):** `format="omarchy-plugin"`, los campos de
  descarga y `plugin_id`, `revision` de 40 caracteres. Solo admite archivo codeload
  GitHub fijado a esa revisión y destino exacto `.config/omarchy/plugins/<plugin_id>`.
  Rechaza IDs reservados, enlaces, raíces inesperadas, identidad/versión distintas
  y plugins sin servicio. No ejecuta scripts instaladores. Valida el manifiesto con
  el helper nativo después de aprobar código y antes de escribir. Conserva licencia;
  omite metadatos ocultos del repositorio, AGENTS/CLAUDE y preview.png.
  Administra archivos individualmente y solo la entrada `plugins` de ese ID y su
  pertenencia en `disabledPlugins`; no coloca widgets ni sustituye la barra.
  Detecta instalaciones ajenas o el mismo ID en otra carpeta, y las bloquea sin
  adopción automática. Revalida inventario e identidad; evita activar mezclas
  parciales de archivos conservados. Después solicita rescanPlugins y comprueba
  `enabled` en la lista real de la shell. Esto no certifica funcionamiento gráfico.
  El código QML corre con permisos del usuario, sin aislamiento. Al retirar restaura
  las pertenencias previas y elimina archivos propios sin cambios personales;
  datos/efectos que produzca el plugin quedan fuera de la restauración del gestor.
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
# Extensiones 0.4.0: base de Rafa

El esquema sigue siendo 1; estos campos requieren `manager_min = "0.4.0"`.
Referencia completa comprobable: `packs/desktop-gaming-v1.2.0/pack.toml`.

- `compatibility.omarchy_package_min = "4.0.4-1.1"` compara versión y sufijo numérico
  completo de `omarchy version`. Una versión ausente/inferior bloquea antes de los
  proveedores. No actualiza Omarchy ni sustituye la validación Hyprland posterior.
- `[[package_removals]]`: `module`, `name`, `reason`. Lista acotada a `cursor-bin`,
  `foot`, `moonlight-qt`, `signal-desktop`. Consulta y muestra solo los instalados;
  verifica `pacman -Rp` y ejecuta `pacman -R`, sin cascada ni datos personales.
  Revalida antes de retirar. No se reinstalan al restaurar archivos o bajar el pack.
- `[desktop_cleanup] hide = [...]`: quince IDs web acotados en `desktop_apps.py`.
  Genera overrides `Hidden=true` bajo aplicaciones del usuario; respalda y restaura
  el original al retirar, sin tocar accesos ajenos. No equivale a desinstalar apps.
- `[spotify] module = "spotify"; profile = "omarchy-glass"`: perfil tipado, sin
  comandos arbitrarios. Declara paquete nativo Spotify, descarga Spicetify tar y
  Marketplace zip, y los tres recursos propios requeridos por `spotify.py`.
  Prepara una generación privada bajo `.local/share/omapacks-data/spotify`, aplica
  Spicetify con `--no-restart`, verifica hashes y parches binarios revisados, y crea
  un lanzador manual. No abre/reinicia/mata Spotify ni edita `/opt/spotify` o cuentas.
  Requiere paleta y fuente nativas de Omarchy. Un Spotify no reconocido bloquea;
  no se aplican offsets por aproximación ni se baja el paquete. Conserva generaciones
  anteriores para recuperación; su limpieza no es automática. La activación manual
  vuelve a verificar recursos, cliente privado y compatibilidad.
- `downloads.format = "zip"`: extracción limitada a archivos regulares, sin enlaces,
  duplicados, traversal ni permisos especiales, dentro del namespace de contenido.
- `checks.kind = "desktop-entry"`, `name`, `required`: busca el acceso nativo/Flatpak
  según precedencia y ejecuta `desktop-file-validate`. **No prueba la aplicación**.

La shell permite activar plugins externos fijados, widgets y clones de los paneles
nativos declarados; combina membresías y conserva otros ajustes. Las mezclas de
código nuevo/conservado de un plugin se bloquean. Lock Screen Explorer solo admite
las opciones revisadas `design=dayline`, `boot=terminal` (animación del bloqueo).
hyprmoncfg no recibe perfiles ni activa su daemon. Arch/AUR no sustituyen formatos:
CurseForge usa `curseforge-appimage`, no un repaquetado automático de `.deb`.

Flatpak actualmente exige que el commit fijado siga siendo el del remote, incluyendo
al instalar de cero. Si cambia, requiere revisar otra receta; no promete recuperar
cualquier commit histórico de Flathub. Los permisos/runtimes conservan la confirmación
nativa. AUR muestra PKGBUILD/auxiliares y revisión; sus conflictos declarados con otros
paquetes bloquean una sustitución no prevista. Las compilaciones no están aisladas
durante una instalación real y nunca se ejecutan como root.

El diario guarda una vez `approved-plan.json` con el plan completo y utiliza un
resumen sin payloads de archivos para los eventos recuperables. Los diarios anteriores
siguen siendo restaurables. La consulta `support-report` no expone esos payloads.
