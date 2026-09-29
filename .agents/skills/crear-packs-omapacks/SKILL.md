---
name: crear-packs-omapacks
description: Crear o revisar releases completas y paquetes de prueba de OmaPacks, con manifiesto declarativo y reporte editorial editable. Usar para preparar contenido de este proyecto, sin implicar autorización para instalarlo o publicarlo.
---

# Crear packs de OmaPacks

Trabaja en el checkout de OmaPacks. Lee `AGENTS.md`, `CURRENT_STATE.md`,
`docs/CREAR_PACKS_CON_IA.md` y `docs/MANIFEST.md` desde su raíz. La guía contiene el
flujo y el contrato vigente; no presupongas soporte de una función por su historial.

El reporte se redacta en español en `NOTES.md`. Es texto editorial que puede escribir
y editar una IA con la revisión de Diego. No es código, una orden de instalación ni
un sustituto del plan que calcula el gestor. Debe estar incluido en el índice firmado.

Mantén siempre estas tres primeras secciones y este orden:

```markdown
## Resumen
Un párrafo breve: qué ofrece este paquete y para qué sirve.

## Apps y plugins
- Nombre: qué añade y cómo se accede.

## Modificaciones
- Omarchy · Interfaz o paneles: cambio concreto.
- Hyprland · Capturas o navegación: cambio concreto.
```

Si una sección no tiene contenido, consérvala: «No se añadieron nuevos elementos»
o «No se declararon modificaciones». Usa categorías humanas cuando correspondan;
no inventes cambios para llenar categorías. Las secciones adicionales son opcionales
y van después. No añadas una sección si no aporta información a ese paquete.
No introduzcas ANSI ni colores en Markdown: el gestor resalta los títulos usando
el color del logo del tema activo. Conserva frases breves y listas fáciles de recorrer.
El inicio usa el apartado Resumen como previsualización, limitado a dos líneas de
terminal con puntos suspensivos. Publica el mismo NOTES.md como notas de la release
para que esa vista informativa coincida con el reporte firmado al abrir.

Describe la intención de la release completa; los cambios que realmente faltan en
cada equipo, permisos, colisiones y bloqueos los calcula el motor y se muestran aparte.
No declares instalado, compatible o probado algo que solo figura en el reporte.

Conserva `diego-rafa.shared` y todos los recursos de la release anterior cuando
prepares un nuevo pack compartido. Un fixture aislado debe identificarse como DEMO.
Fija las fuentes externas por revisión y hash. Si falta un adaptador tipado, documenta
la brecha: no uses Lua/shell genérico ni rutas arbitrarias para saltarte el contrato.
Prueba dentro del namespace del proyecto; nunca confundas HOME temporal con aislamiento.
No publiques ni apliques contenido al anfitrión sin autorización vigente específica.

Si un pack necesita un OmaPacks más nuevo, usa exclusivamente `manager_min`.
Desde gestor 0.3.3 el requisito aparece automáticamente en el reporte: el gestor
actualiza su propia entrega firmada tras aprobación y vuelve a calcular el plan.
No añadas un instalador, URL de gestor, clave o comando de actualización al contenido.
El gestor compatible debe estar publicado y verificado antes de publicar el pack.
Las versiones anteriores requieren reinstalar primero el gestor desde Add Plugin.
