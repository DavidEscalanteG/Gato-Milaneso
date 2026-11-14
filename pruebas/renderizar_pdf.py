"""Render the synthetic reports for visual review; requires pypdfium2 and Pillow.

python pruebas/renderizar_pdf.py tmp/pdfs
Writes page PNGs and four-page contact sheets under tmp/pdfs/render.
"""

import json
import sys
from pathlib import Path

import pypdfium2 as pdfium
from PIL import Image, ImageDraw


def render(directory):
    expected = json.loads((directory / "esperado.json").read_text(encoding="utf-8"))
    output = directory / "render"
    output.mkdir(exist_ok=True)
    previews = []
    for filename in sorted(expected["archivos"]):
        with pdfium.PdfDocument(directory / filename) as document:
            for number in range(len(document)):
                page = document[number]
                bitmap = page.render(scale=2)
                full = bitmap.to_pil().convert("RGB")
                full.save(output / f"{Path(filename).stem}-{number + 1}.png")
                preview = full.resize((612, 792), Image.Resampling.LANCZOS)
                previews.append((f"{filename} / {number + 1}", preview))
                bitmap.close()
                page.close()
    for start in range(0, len(previews), 4):
        sheet = Image.new("RGB", (1224, 1640), "#e1e5e8")
        draw = ImageDraw.Draw(sheet)
        for position, (label, preview) in enumerate(previews[start:start + 4]):
            x = (position % 2) * 612
            y = (position // 2) * 820
            draw.text((x + 10, y + 6), label, fill="black")
            sheet.paste(preview, (x, y + 28))
        sheet.save(output / f"contacto-{start // 4 + 1:02d}.png")
    print(f"RENDER OK: {len(previews)} páginas; imágenes y contactos en {output}")


if __name__ == "__main__":
    render(Path(sys.argv[1] if len(sys.argv) > 1 else "tmp/pdfs"))
