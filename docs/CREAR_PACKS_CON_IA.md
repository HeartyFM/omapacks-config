# Crear y publicar configuraciones OmaPacks con agentes

Lee primero `AGENTS.md`, `docs/MANIFEST.md` y las notas/evidencia de la release anterior. Trabaja en ciclos:
inspeccionar → implementar → probar → corregir. No declares resultados sin evidencia.

## Contrato del proyecto

- Gestor/plugin y contenido son entregas distintas. El repo de contenido existente
  es **HeartyFM/omapacks-config**, público. Consulta sus GitHub Releases para ver
  qué versiones están publicadas; no reutilices tags ni reemplaces sus assets.
  El plugin se prepara con `tools/plugin_bundle.py`; no confundir los repositorios.
- Rafa elige una **release completa**, no un módulo, código o catálogo. Cada release
  debe servir para instalar desde cero. El futuro pack de gaming será una release
  que conserve escritorio/defaults/menú y añada sus módulos. Omitir recursos
  administrados significa retirarlos: no publicar solo el delta.
- Mantener `id = "diego-rafa.shared"`. Incrementar versión de contenido y módulos
  afectados; `manager_min` es independiente. Los tipos de menú y defaults necesitan
  gestor **0.2.0**. No copiar el ejecutable del gestor dentro del contenido.

## Crear un candidato

1. Copia `packs/desktop-v1.0.0` a un nuevo directorio de `packs/`. Revisa el
   manifiesto, recursos y notas. Solo se empaquetan archivos propios declarados.
   No incluir fixtures ni artefactos de pruebas en este repositorio.
2. Inspecciona las versiones y archivos reales del equipo. Para Omarchy consulta
   las skills `omarchy` y `omarchy-visual-design`, sus referencias y los scripts
   instalados. Lee `/usr/share/omarchy`; nunca lo edites para personalizar.
   Lua y conf no son intercambiables. Documenta qué equipos/versiones se probaron.
3. Usa `hypr_include` para el drop-in compartido. No transportar monitores,
   escalado, GPU, cursor de hardware, energía, discos, teclado personal ni kernels.
   La sintaxis Lua es código revisable y no está aislada durante una instalación
   real. El motor valida tras aprobación, preserva accesos esenciales y recarga al final.
4. Menú: `omarchy_menu` solo admite entradas `omapacks.shared.*`, grupos y acciones
   tipadas. El recurso JSON se combina con la extensión local; no exportar el menú
   completo ni rutas de Diego. Defaults: `xdg_defaults` referencia un JSON de
   asociaciones MIME, terminal y editor admitidos. Declarar también sus paquetes.
   No copiar historiales, perfiles, autenticación, cookies, claves, partidas o ROMs.
5. Escribe `NOTES.md` pensando en Rafa: qué cambia, aplicaciones incluidas,
   compatibilidad, permisos, reinicios y límites. Se muestra directamente al
   seleccionar la release, encima de Instalar/Retroceder.

## Dependencias y futuros packs

Para Arch, `version` es el mínimo requerido: el plan resuelve las versiones exactas
con la base local y nunca baja paquetes. Si la base exige actualizar, usar la ruta
normal de Omarchy con aprobación. No `pacman -Sy`, locks eliminados ni sustitución
silenciosa por AUR.

AUR necesita commit completo de 40 caracteres, PKGBUILD/auxiliares revisados y
dependencias de compilación/runtime explícitas. No inventar commit o versión.
Construir como usuario, con confirmaciones del proveedor. Una firma OmaPacks
autentica nuestra receta; no certifica el código de terceros.

Flatpak necesita app, remote, ámbito, commit y permisos; declarar infraestructura
y adición de remotes. Entregas externas: formatos soportados, versión, arquitectura,
URL oficial existente, tamaño y SHA comprobados. No incluir binarios de terceros
ni descargar `main`/`latest` durante la aplicación.

Para Discord/Steam/Heroic/Wine, primero comprobar proveedores disponibles y licencias,
escribir recetas y pruebas específicas. No instalar juegos pesados solo para una demo.
No sobrescribir prefijos Wine, bibliotecas o partidas. Los protocolos de autenticación
se añaden con la receta de la aplicación correspondiente, nunca como enlaces rotos.
La importación se implementará después. Codex/mise no tiene proveedor en esta versión:
no ocultarlo con un script shell ni afirmar que el pack instala el agente personal.

## Validar y probar

Desde el checkout de desarrollo del gestor, sustituyendo RUTA por el candidato de este repo. Si solo tienes el gestor instalado, usa `omapacks validate RUTA`; las pruebas de desarrollo no vienen en el plugin:

```sh
bin/omapacks validate RUTA
python3 -m unittest discover -s tests -v
```

Probar instalación limpia, actualización, regreso, reinstalación, conflictos,
retirada de recursos, firma/hash inválidos y fallo de comprobación. Usa claves
efímeras para fixtures y elimínalas al terminar. `tools/desktop_probe.py` comprueba
la sintaxis del candidato 1.0.0 y defaults con comandos reales en un namespace
rootless. `tools/plugin_qml_probe.py` carga QML real con bootstrap simulado.
`tools/visual_probe.py journey`, `small`, `light` prueban la TUI en su propia ventana.

Un HOME temporal **no aísla** pacman, servicios o Hyprland. No probar paquetes/root
sobre el hogar personal: namespace/VM apropiado o aprobación concreta. Registrar
por separado unitarias, simulación, consultas reales, instalación real y cada equipo.
No declarar el Lenovo verificado sin probar allí. No marcar READY_FOR_RAFA_TEST
si el plugin no lleva origen/clave autorizados o aún no hay contenido descargable.

## Firmar y preparar publicación

Con la clave de publicación **ya autorizada**, fuera del repositorio:

```sh
bin/omapacks pack RUTA --output artifacts/entrega-NUEVA \
  --repo HeartyFM/omapacks-config --tag vVERSION --key RUTA_CLAVE_PRIVADA
bin/omapacks publish artifacts/entrega-NUEVA \
  --commit COMMIT_REAL_DE_40_CARACTERES --public-key RUTA_CLAVE_PUBLICA
```

Esos parámetros son marcadores explicativos, no nombres reales. Comprobar el commit
del repo de contenido. El primer comando produce índice, firma SSH y tar.gz; el
segundo muestra la publicación prevista. Presentar ese resultado, notas, diff y
pruebas a Diego antes de publicar cuando no exista autorización vigente.

Con autorización explícita, subir exclusivamente las fuentes revisadas al repo de
contenido, comprobar su SHA y repetir `publish` con `--yes`. Crea borrador, sube los
tres assets y publica al terminar; no reemplaza assets existentes. Si falla, revisar
el borrador. Nunca crear claves permanentes, credenciales, nuevos repos o cambiar
visibilidad sin autorización aplicable. Nunca guardar o distribuir el token de Diego.

Finalmente consultar y descargar **esa release real** con el cliente OmaPacks,
verificar firma/identidad/assets y registrar URL y evidencia de la publicación.
Un archivo local o servidor simulado no es una release publicada.

## Entrega

Enlaza el candidato, artefactos y pruebas. Indica gestor/proveedores probados,
publicación remota y pruebas de cada equipo por separado. La guía de Rafa permanece
en cinco pasos. Si falta aprobación, explica qué operación concreta falta; no dejes
trabajo local autorizado pendiente solo por no tener permiso para publicar.

El grupo raíz `omapacks.shared` declara `parent = "root"` explícitamente.
Omarchy infiere el padre de IDs con puntos; omitirlo dejaría el grupo bajo un padre inexistente.
