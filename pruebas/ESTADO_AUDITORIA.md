# Estado de las recomendaciones - 14 de noviembre de 2026

Se aprobaron trece puntos, cada uno con commit propio. Se mantuvo **Godot 4.3
stable / Forward Plus**. A09, A13 y A16 se excluyeron expresamente.

| Punto | Resultado | Commit |
| --- | --- | --- |
| A01 | Editar datos actualiza el registro de esa partida; otro participante crea uno nuevo. | `68c631d` |
| A02 | Comprobación de escritura SQLite/personaje/alias; conserva captura ante errores. | `52898ca` |
| A03 | Instantánea persistente del reporte fallido, reintento y recuperación protegida. | `8b3a1c4` |
| A04 | Sin identidad ni respuestas en consultas de depuración o salida del cuestionario. | `5329309` |
| A05 | Atlas del topo desde PNG original, sin dependencia de archivos de caché heredados. | `95ffdbf` |
| A06 | Prueba de personajes reproducible con precisión y cola de entrada de 4.3. | `d8a88b2` |
| A07 | Cancelación de esperas y animaciones al abandonar escenas. | `b478e79` |
| A08 | Diez respuestas válidas para el reporte definitivo; pendientes distintas de cero. | `97eff85` |
| A09 | Catálogo de grado y selecciones iniciales. **Excluido; sin cambios.** | — |
| A10 | Nombres y alias largos conservados; presentación acotada en mapa y diálogo. | `25f514f` |
| A11 | Ortografía narrativa e instrucciones coherentes, sin cambiar preguntas o dificultad. | `1817dc1` |
| A12 | Veinte pulsaciones rápidas producen un fundido y un cambio de escena. | `80bfaae` |
| A13 | Preparación y validación de distribución Windows. **Excluido; sin cambios.** | — |
| A14 | Documentación vigente, instrucciones 4.3, operación y comando de pruebas. | Commit que incorpora este documento; `git log --oneline --grep='^A14:'` |
| A15 | 18 PDF, 37 páginas renderizadas y once puntajes frontera comprobados. | `89743f2` |
| A16 | Pruebas con jugadores y equipos de destino. **Excluido; sin realizar.** | — |

## Evidencia y reproducción

- Motor: `4.3.stable.official.77dcf97d8`; renderizado Forward Plus en esta estación.
- Suite de personajes, minijuegos y pruebas específicas de cada corrección.
- Comando integrado con `-Render` y Python: **12 suites correctas**, incluidos
  los 18 PDF y el recorrido completo; sin errores de script ni fugas de objetos.
- Fallos provocados: base inaccesible, configuración de personaje inválida, alias
  sobre archivo de solo lectura, carpeta de resultados bloqueada y JSON dañado.
- Recorrido asistido completo: 26 entradas, cinco retos, diez respuestas y PDF.
- Topo en copia de fuentes sin `.godot`: importación de recursos con 4.3, nueva
  pasada para resolver autoloads y suite de minijuegos correcta, sin copiar `.ctex`.
- Revisión visual de captura de alias, mapa, nombre del hablante e instrucciones.
- PDF: [evidencia detallada](VERIFICACION_PDF.md). Cierre:
  [investigación de recursos](CIERRE_RECURSOS.md).

[REVISION_JUEGO.md](REVISION_JUEGO.md) explica cómo repetir las doce suites con
APPDATA aislado. `ejecutar_pruebas.ps1` comprueba la versión y conserva los logs.
Los datos sintéticos y capturas bajo `tmp/` están excluidos del repositorio.

Se completó el alcance aprobado. El cierre global del producto todavía depende
de las decisiones y validaciones excluidas A09/A13/A16; no se declara una entrega
al 100 % por haber aprobado pruebas asistidas.
