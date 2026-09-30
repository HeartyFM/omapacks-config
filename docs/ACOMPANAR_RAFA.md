# Acompañar a Rafa: gestor 0.4.0 y base 1.2.2

La base 1.2.2 elimina únicamente el mínimo de versión Omarchy y utiliza el gestor 0.4.0 ya publicado.
Comprobar la disponibilidad de la release 1.2.2 y sus firmas antes de instalar.
La base pública 1.2.0 permanece intacta con su requisito anterior. Guía: `RAFA.md`.

Gestor local: `artifacts/desktop-gaming-2026-09-30/delivery/`. Incluye el plugin
configurado para Add Plugin, gestor independiente, contenido firmado y carpeta
`rafa/` con la guía anterior y `Comprobar-OmaPacks.py`. El contenido nuevo está en
`artifacts/omarchy-version-policy-2026-09-30/release-v1.2.2/`; usar la guía actual
`docs/RAFA.md`. El comprobador es Python estándar,
de solo lectura, y funciona aunque el gestor anterior no conozca `support-report`.
Su salida excluye diarios completos, perfiles, rutas personales y secretos.

Antes de la llamada, Diego verifica la publicación de **0.4.0 estable** del gestor
y **1.2.2 Prueba** del contenido, sus assets y firmas descargados de GitHub.
Después entrega el enlace habitual del plugin y el aviso de que ya están disponibles.

| Momento | Evidencia esperada | Si falla |
| --- | --- | --- |
| Antes | Versiones, origen, sin transacciones pendientes | Revisar/restaurar la transacción; conservar datos |
| Compatibilidad | Sin mínimo de versión Omarchy; Hyprland ≥0.56.2 en Lua y x86_64 | Revisar el requisito técnico concreto; no saltarse validaciones |
| Gestor | 0.4.0; mismo origen y contenido anterior | Revisar la oferta/diagnóstico del actualizador |
| Plan | Apps, retiros, AUR, permisos, archivos y conflictos visibles | Cancelar o resolver; no aprobar otra cosa |
| Resultado | 1.2.2, sin pendientes; reloads comprobados | Diario parcial y recuperación revisada |
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
