# Corrección Steam/Radeon · guía de Rafa

Disponibles y verificadas: **gestor 0.4.2 / pack 1.2.3 Prueba**. Descarga pública,
firmas y hashes comprobados. El error anterior se produjo al preparar
dependencias; la consulta aportada confirma que NVIDIA no estaba instalado.

1. Abre **Update → Configuración compartida**, consulta las releases y selecciona
   **v1.2.3 · Prueba**. Si no aparece, vuelve a consultar la lista y revisa si
   informa de caché o un fallo de red. No instales NVIDIA para superar el mensaje.
2. Acepta **Actualizar gestor** a **0.4.2** cuando lo solicite. Conserva el origen,
   la clave y el registro. OmaPacks vuelve a abrir el contenido y calcula otro plan.
   Para una instalación nueva, usa **Setup → Plugin → Add Plugin** con
   `https://github.com/HeartyFM/omapacks-plugin` y acepta instalar su gestor.
3. Revisa el plan. En el Radeon descrito, con Mesa ya instalado, deben figurar
   **vulkan-radeon**, **lib32-vulkan-radeon** y **lib32-mesa**, sin `nvidia-utils`
   ni `lib32-nvidia-utils`. Aparecerán otras dependencias normales de las apps.
   Si el plan muestra un conflicto, otra GPU o una actualización de Arch pendiente,
   vuelve atrás y comparte ese diagnóstico con Diego.
4. Confirma el plan que quieras aplicar y las preguntas nativas de permisos.
   Flatpak puede requerir preparación inicial y un segundo plan. Se conservan las
   revisiones de AUR, conflictos y retiradas explícitas. Las apps no se inician al
   descargar; al terminar se recargan las configuraciones y se comprueban.
5. Comprueba **«Instalación completada correctamente»** y ejecuta
   `~/.local/bin/omapacks support-report`: gestor 0.4.2, contenido 1.2.3 y sin
   operaciones pendientes. Abre las apps tú mismo y prueba el escritorio. Ante un
   error, comparte su fase/recurso y ese reporte; conserva los diarios.

No se exige igualar la versión de Omarchy de Diego. Siguen vigentes los requisitos
técnicos de Hyprland Lua, arquitectura y aplicaciones. No se cambian kernel, GPU
del escritorio, arranque, Secure Boot ni perfiles de monitores. Las bibliotecas
Vulkan/Mesa se instalan mediante pacman y se revisan en el plan. La prueba local
de resolución no certifica aceleración ni juegos funcionando en el Lenovo.
