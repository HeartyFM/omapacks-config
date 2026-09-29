# Actualización del gestor como requisito de contenido

Candidato: **gestor/plugin 0.3.3**, pack completo de prueba **1.1.2**.
Conserva las entregas congeladas 0.3.2/1.1.1. La aprobación de publicación de Diego
incluye esta ampliación; no autoriza instalar en su escritorio. Publicación y
verificación remota se registran en CURRENT_STATE.md al concluir.

## Recorrido y límites

Un `manager_min` superior abre el reporte firmado con sus tres secciones y un aviso
obligatorio. Todavía no existe un plan ejecutable del contenido. La acción
**Actualizar gestor** autoriza el código del gestor; Volver no lo cambia. Detalles
muestra origen, identidad y SHA-256. El proceso nuevo reabre el mismo ID de release
mediante una consulta vigente, verifica sus assets y calcula un plan sin aprobación.
Un fallo no instala contenido ni marca el pack como completado.

No se extiende el manifiesto con URLs, código o destinos del gestor. Se amplía el
significado de `manager_min` en la TUI, conservando el rechazo del motor a esquemas
incompatibles. El instalador ancla `manager_repository` y `publisher.pub` en la
copia instalada. El archivo de confianza del contenido no cambia. La firma del
gestor usa identidad `omapacks-manager` y namespace `omapacks-manager-v1`; una firma
de contenido no sirve como firma de gestor. Se verifica identidad y tamaño de assets
antes/después de descargarlos, después la firma, el hash del archivo comprimido,
los hashes de cada archivo y permisos ejecutables. Solo se admiten rutas propias
del gestor. También se comprueba que bundle, versión, origen y clave coincidan.

Se elige una release estable suficiente, nunca un downgrade ni una prerelease
implícita. Consultas incompletas/en caché bloquean. Una operación parcial de contenido,
un gestor distinto del proceso actual, cambio de archivos, origen o confianza obliga
a revisar el estado. Instalador, desinstalador, motor y actualizador comparten bloqueo.
La copia candidata debe arrancar con `--version` antes de activarse.

## Recuperación honesta

Se conserva el gestor previo bajo `.local/share/omapacks-manager-backups/ID`.
`manager-update.json` registra preparación, resultado y ubicación. Un fallo detectado
durante el reemplazo restaura esa copia. Un cierre abrupto entre renombrados puede
requerir reinstalar desde el plugin confiable: conservar ambas carpetas y el registro,
comparar versión registrada y archivos reales antes de actuar. No borrar evidencia
para reintentar. Esta recuperación no modifica el contenido, no revierte paquetes
ni promete un rollback del escritorio. El instalador general conserva su diagnóstico
por fases y su limitación documentada sobre configuración/menú.

## Preparación y evidencia

El bundle normal incluye la política. `tools/manager_release.py` empaqueta solo sus
rutas permitidas y firma tres assets propios, separados de los tres assets del pack.
Nunca reemplaza un directorio de entrega existente. Publicar primero el gestor
compatible y comprobar su descarga anónima; después el pack como prerelease.

Regresiones en `tests/test_manager_update.py`: actualización firmada real en hogar
confinado, cancelación, retorno al reporte en proceso nuevo, conservación de estado,
confianza y accesos, bloqueo concurrente/parcial, plan obsoleto, fuentes/clave/rutas
rechazadas, firma/hash/namespace inválidos, downgrade y prerelease rechazados,
fallo entre renombrados con restauración, retirada/reinstalación y esquema futuro
que solo permite leer el requisito después de verificar la entrega.

Las pruebas usan bwrap sin red ni IPC anfitrión, archivos y firmas reales, GitHub
simulado. La versión de prueba 0.3.4 de los fixtures no es una release publicada.
La prueba de entrega completa añade el flujo nativo Remove → Add, instaladores reales,
el motor antiguo 0.2.1 y assets firmados reales de contenido. Paquetes, IPC y respuestas
siguen simulados. La instalación en Lenovo sigue pendiente de Rafa.
