# Acompañar a Rafa: gestor 0.4.0 y base 1.2.0

Publicadas con autorización de Diego y verificadas el 30-09-2026. La guía de Rafa
está en `RAFA.md`; solo falta coordinar la prueba real del Lenovo.

Entrega local: `artifacts/desktop-gaming-2026-09-30/delivery/`. Incluye el plugin
configurado para Add Plugin, gestor independiente, contenido firmado y carpeta
`rafa/` con la guía y `Comprobar-OmaPacks.py`. El comprobador es Python estándar,
de solo lectura, y funciona aunque el gestor anterior no conozca `support-report`.
Su salida excluye diarios completos, perfiles, rutas personales y secretos.

Antes de la llamada, Diego verifica la publicación de **0.4.0 estable** del gestor
y **1.2.0 Prueba** del contenido, sus assets y firmas descargados de GitHub.
Después entrega el enlace habitual del plugin y el aviso de que ya están disponibles.

| Momento | Evidencia esperada | Si falla |
| --- | --- | --- |
| Antes | Versiones, origen, sin transacciones pendientes | Revisar/restaurar la transacción; conservar datos |
| Omarchy | 4.0.4-1.1 o posterior; Lua/x86_64 compatible | Actualizador oficial; no forzar el pack |
| Gestor | 0.4.0; mismo origen y contenido anterior | Revisar la oferta/diagnóstico del actualizador |
| Plan | Apps, retiros, AUR, permisos, archivos y conflictos visibles | Cancelar o resolver; no aprobar otra cosa |
| Resultado | 1.2.0, sin pendientes; reloads comprobados | Diario parcial y recuperación revisada |
| Uso real | Apps abiertas manualmente; Spotify y juegos comprobados | Registrar aplicación, fase y error concreto |

La validación previa solo acredita accesos de aplicaciones; no acredita juegos,
cuentas o audio. Roblox se ofrece mediante Sober. hyprmoncfg no recibe monitores,
perfiles o configuración de servicio de Diego. El pack no inicia ni habilita su
daemon. Los cuatro retiros usan `pacman -R`, nunca cascada; si otro paquete los
necesita se bloquea y se revisa. Sus datos no se eliminan. Otras variantes o ámbitos
de instalación requieren revisar el plan; no se desinstalan por coincidencia de nombre.

Spotify necesita la versión cuyos binarios conoce la receta de cristal. Una
actualización de Spotify puede exigir otra release del pack. Las versiones Flatpak
se fijan por commit: si Flathub ya ofrece otro, el gestor bloquea y Diego debe
revisar/actualizar la receta. No se resuelve «latest» silenciosamente.

Registrar en CURRENT_STATE.md el equipo, versiones inicial/final, resultado de cada
fila y límites. Solo una prueba real en el Lenovo permite afirmar su compatibilidad.
