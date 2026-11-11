"""Validate generated reports; requires pypdf and pdfplumber.

Run exportacion_pdf.tscn first, then: python pruebas/validar_pdf.py tmp/pdfs
"""

import json
import sys
from pathlib import Path

import pdfplumber
from pypdf import PdfReader


def normal(value):
    return " ".join(value.split())


def validate(directory):
    expected = json.loads((directory / "esperado.json").read_text(encoding="utf-8"))
    for path in sorted(directory.glob("*.pdf")):
        reader = PdfReader(path, strict=True)
        assert reader.metadata.title == "Resultados del cuestionario"
        assert reader.metadata.creator == "El Gato Milaneso"
        text = normal(" ".join(page.extract_text() for page in reader.pages))
        incomplete = "incompleta" in path.name
        assert ("0 / 27" if incomplete else "15 / 27") in text
        assert "La pregunta 10 se registra por separado y no modifica el puntaje." in text
        if "larga" in path.name:
            assert text.count("W") == 1600 and "FIN_NOMBRE" in text
            assert len(reader.pages) > 2
        elif path.name == "exportacion-prueba.pdf":
            assert "José Muñoz (PRUEBA) \\" in text
            assert "áéíóú ü ¡¿" in text
            assert len(reader.pages) == 2
        found = {}
        with pdfplumber.open(path) as pdf:
            for page_number, page in enumerate(pdf.pages, 1):
                assert page.width == 612 and page.height == 792
                assert all(
                    char["x0"] >= 39.5 and char["x1"] <= 572.5
                    and char["top"] >= 33 and char["bottom"] <= 773
                    for char in page.chars
                ), f"Text outside margins: {path}"
                assert "EL GATO MILANESO" in page.extract_text()
                assert f"Página {page_number} de {len(pdf.pages)}" in page.extract_text()
                number_lines = {}
                for char in page.chars:
                    if 50 <= char["x0"] <= 65 and abs(char["size"] - 12) < 0.01:
                        number_lines.setdefault(round(char["top"], 2), []).append(char)
                for top, chars in number_lines.items():
                    number = int("".join(c["text"] for c in sorted(chars, key=lambda c: c["x0"])))
                    assert number not in found, f"Duplicated question {number}: {path}"
                    row = next(r for r in page.rects if abs(r["x0"] - 40) < 0.01
                               and abs(r["width"] - 532) < 0.01 and r["top"] <= top < r["bottom"])
                    assert row["bottom"] <= 724, f"Split/overflowing row: {path}"
                    question = normal(page.crop((84, row["top"], 400, row["bottom"])).extract_text())
                    answer = normal(page.crop((412, row["top"], 572, row["bottom"])).extract_text())
                    assert question == expected["preguntas"][number - 1], (path, number, question)
                    value = 0 if incomplete else expected["valores"][number - 1]
                    if number == 10:
                        if incomplete:
                            assert answer == "Sin responder"
                            found[number] = question
                            continue
                        value = 3 if "larga" in path.name else value
                        if path.name.startswith("pregunta10-"):
                            value = int(path.stem.split("-")[-1])
                        choice = expected["dificultades"][value]
                        assert answer == f"{choice} Valor: {value} - no suma"
                    else:
                        choice = expected["frecuencias"][value]
                        assert answer == f"{choice} Valor: {value}"
                    found[number] = question
        assert set(found) == set(range(1, 11)), f"Missing questions: {path}"
        print(f"OK: {path.name}, {len(reader.pages)} pages, 10 complete rows with correct answers")


if __name__ == "__main__":
    for argument in sys.argv[1:] or ["tmp/pdfs"]:
        validate(Path(argument))
