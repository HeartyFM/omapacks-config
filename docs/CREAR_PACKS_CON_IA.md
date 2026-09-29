# Crear y publicar configuraciones OmaPacks con agentes

Lee primero `AGENTS.md`, `CURRENT_STATE.md` y `docs/MANIFEST.md`. Trabaja en ciclos:
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

1. Parte de la última release completa y de los cambios locales aún inéditos; no
   retrocedas automáticamente a 1.0.0. Crea un nuevo directorio en `content/`. Revisa el
   manifiesto, recursos y notas. Solo se empaquetan archivos propios declarados.
   `examples/v1` y `examples/v2` son fixtures, no publicaciones reales.
2. Inspecciona las versiones y archivos reales del equipo. Para Omarchy consulta
   las skills `omarchy` y `omarchy-visual-design`, sus referencias y los scripts
   instalados. Lee `/usr/share/omarchy`; nunca lo edites para personalizar.
   Lua y conf no son intercambiables. Documenta qué equipos/versiones se probaron.
3. Usa `hypr_include` para el drop-in compartido. No transportar monitores,
   escalado, GPU, cursor de hardware, energía, discos, teclado personal ni kernels.
   La sintaxis Lua es código revisable y no está aislada durante una instalación
   real. El motor valida tras aprobación, preserva accesos esenciales y recarga al final.
   La preferencia explícita de idiomas/variantes/alternancia XKB es un requisito
   distinto del hardware, pero todavía no está soportada por el esquema. Consulta
   `FUTURO_PACK.md`: no resolverla copiando input.lua, bindings.lua o abriendo todo
   input/unbind. El futuro pack deberá conservar todos los recursos de la release
   completa anterior y fijar `manager_min` cuando exista el adaptador probado.
4. Menú: `omarchy_menu` solo admite entradas `omapacks.shared.*`, grupos y acciones
   tipadas. El recurso JSON se combina con la extensión local; no exportar el menú
   completo ni rutas de Diego. Defaults: `xdg_defaults` referencia un JSON de
   asociaciones MIME, terminal y editor admitidos. Declarar también sus paquetes.
   No copiar historiales, perfiles, autenticación, cookies, claves, partidas o ROMs.
5. Escribe `NOTES.md` pensando en Rafa y siguiendo el contrato editorial de abajo.
   El reporte abre directamente al seleccionar la release. Instalar aprueba el plan
   mostrado; se conservan las decisiones nuevas de conflictos, permisos y código.

## Reporte editorial: instrucciones para la IA

La [skill local](../.agents/skills/crear-packs-omapacks/SKILL.md) incluye este contrato.
La IA puede redactar y editar `NOTES.md`; Diego revisa su contenido. La lista muestra
el apartado Resumen de las notas de publicación, hasta dos líneas; publica el mismo
NOTES.md para que coincida con el reporte firmado. Esa previsualización informativa
no autoriza operaciones ni sustituye la verificación al abrir. Se firma como
parte del pack. No escribir el reporte en código Python ni derivarlo de notas GitHub
sin autenticar. Las tres primeras secciones son obligatorias y siempre visibles
mediante desplazamiento, incluso si alguna no tiene novedades:

```markdown
## Resumen
Un párrafo breve: qué incluye este paquete y para qué sirve.

## Apps y plugins
- Nombre: propósito y forma de acceso.

## Modificaciones
- Omarchy · Interfaz o paneles: cambio concreto.
- Hyprland · Capturas o navegación: cambio concreto.
```

Sin elementos: «No se añadieron nuevos elementos». Sin modificaciones:
«No se declararon modificaciones». No omitir secciones vacías ni inventar cambios.
Las categorías son humanas y se usan donde correspondan; no es una lista obligatoria
que haya que rellenar. Más secciones solo si aportan información, después de las tres.
El pack de prueba OmaSettings/capturas no necesita ninguna adicional.

Usa párrafos breves, listas y español claro. No añadas ANSI o colores al archivo:
la TUI remarca los títulos con el color del logo del tema y mantiene el logo en
cada pantalla (marca compacta cuando no cabe). El reporte describe la intención de
la release completa. Los cambios reales en este equipo, dependencias pendientes,
permisos y advertencias se calculan debajo; nunca afirmarlos por la prosa.

Para esta prueba: OmaSettings fijado a commit/hash y `capture_shortcut` para
Super+Shift+S, pantalla completa y guardado. Xbox Controllers queda excluido por
instrucción de Diego. Ambos adaptadores necesitan gestor 0.3.2; no usar Lua arbitrario
para bindings ni copiar shell.json para activar el plugin. Consulta el contrato
normativo. El futuro teclado XKB y temas no quedan habilitados por esta ampliación.

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

Desde la raíz del gestor, sustituyendo RUTA por el candidato:

```sh
bin/omapacks validate RUTA
python3 tools/isolated_checks.py suite
```

Probar instalación limpia, actualización, regreso, reinstalación, conflictos,
retirada de recursos, firma/hash inválidos y fallo de comprobación. Usa claves
efímeras para fixtures y elimínalas al terminar. `tools/desktop_probe.py` comprueba
la sintaxis del candidato 1.0.0 y defaults con comandos reales en un namespace
rootless. `tools/plugin_qml_probe.py` carga QML real con bootstrap simulado.
`python3 -m tools.report_probe probe`, `small`, `light` prueban el recorrido
vigente en una ventana propia, con operaciones de fixtures dentro de bwrap.
`open` deja la demo para revisión humana; la automatización no implica aprobación.

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
verificar firma/identidad/assets y actualizar `CURRENT_STATE.md` con URL y evidencia.
Un archivo local o servidor simulado no es una release publicada.

## Entrega

Enlaza el candidato, artefactos y pruebas. Indica gestor/proveedores probados,
publicación remota y pruebas de cada equipo por separado. La guía de Rafa permanece
en cinco pasos. Si falta aprobación, explica qué operación concreta falta; no dejes
trabajo local autorizado pendiente solo por no tener permiso para publicar.

El grupo raíz `omapacks.shared` declara `parent = "root"` explícitamente.
Omarchy infiere el padre de IDs con puntos; omitirlo dejaría el grupo bajo un padre inexistente.

## Packs que requieren un gestor más nuevo

Desde OmaPacks 0.3.3, declara únicamente `manager_min` con la versión mínima real.
El reporte muestra automáticamente el requisito y la actualización disponible del
gestor desde su origen confiable. Explica en las notas si el pack necesita una función
nueva; no escribas que ya está instalado ni fuerces la actualización desde un recurso.
La IA no debe incluir scripts, URLs de gestores, claves nuevas o comandos shell para
actualizar OmaPacks. El gestor verifica una entrega propia firmada, pide aprobación
y vuelve a calcular el plan de contenido en un proceso nuevo. Si no existe una
versión estable suficiente, la instalación queda bloqueada sin aplicar el pack.
La entrega del gestor requerido debe publicarse y verificarse antes que el contenido.
Las instalaciones anteriores a 0.3.3 se actualizan primero con el plugin configurado.
