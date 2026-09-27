# OmaPacks · repositorio de contenido

Este repositorio contiene packs, no el programa. El plugin está en
HeartyFM/omapacks-plugin. Lee README.md, docs/MANIFEST.md y docs/CREAR_PACKS_CON_IA.md.

Cada versión bajo packs/ es un estado completo y tiene pack.toml y NOTES.md.
Reutiliza la identidad diego-rafa.shared; la versión del gestor es independiente.
No sustituyas releases por códigos, catálogos ni scripts shell arbitrarios.
No incluyas binarios de terceros, claves privadas, tokens, datos personales, partidas,
configuración de hardware o una copia de todo ~/.config. Usa dependencias explícitas.

Valida con omapacks validate packs/VERSION. Prueba solo en entornos apropiados;
un HOME temporal no aísla paquetes, servicios o Hyprland. Distingue fixtures,
validación nativa, aplicación real y equipo probado. No declares Lenovo verificado.

Antes de publicar, presenta a Diego diff, pruebas, commit y assets firmados, salvo
que ya haya autorización aplicable. No crees claves permanentes ni cambies visibilidad
sin autorización. Usa la clave autorizada externa al repo; jamás la copies aquí.
No reemplaces tags/assets existentes. Comprueba descarga/firma de la release real.
