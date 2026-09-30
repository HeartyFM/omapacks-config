# Acompañar a Rafa: gestor 0.4.2 y base 1.2.3

Ambas releases están publicadas y verificadas. La base conserva el contenido de
1.2.2 y pide gestor 0.4.2 para corregir la selección de Vulkan al instalar Steam.
No exige la versión de Omarchy de Diego. Usar [la guía de Rafa](RAFA.md).

Rafa informó Mesa 1:26.2.2-1 sin Vulkan Radeon de 64/32 bits ni lib32-mesa;
NVIDIA tampoco estaba instalado. El plan nuevo detecta la GPU local y propone
las bibliotecas adecuadas antes de confirmar. Mantiene los bloqueos de kernel,
arranque y dependencias NVIDIA. No certifica aceleración ni juegos funcionando.

Diego dispone de la entrega revisada en
`artifacts/vulkan-provider-2026-09-30/delivery/`, firmas y fuentes públicas verificadas.
Rafa no necesita esos directorios: selecciona v1.2.3 en OmaPacks y acepta actualizar
el gestor. Si necesita una instalación nueva, usa el plugin público habitual.

| Momento | Evidencia esperada | Si falla |
| --- | --- | --- |
| Antes | Versiones, origen, sin transacciones pendientes | Revisar/restaurar la transacción; conservar datos |
| Compatibilidad | Sin mínimo de versión Omarchy; Hyprland ≥0.56.2 en Lua y x86_64 | Revisar el requisito técnico concreto; no saltarse validaciones |
| Gestor | 0.4.2; mismo origen y contenido anterior | Revisar la oferta/diagnóstico del actualizador |
| Plan | Apps, retiros, AUR, permisos, archivos y conflictos visibles | Cancelar o resolver; no aprobar otra cosa |
| Resultado | 1.2.3, sin pendientes; reloads comprobados | Diario parcial y recuperación revisada |
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
