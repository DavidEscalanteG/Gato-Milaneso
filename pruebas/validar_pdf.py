"""Validate generated reports; requires pypdf and pdfplumber.

Run exportacion_pdf.tscn first, then: python pruebas/validar_pdf.py tmp/pdfs
"""

import json
import re
import sys
from pathlib import Path

import pdfplumber
from pypdf import PdfReader


def normal(value):
    return " ".join(value.split())


def validate(directory):
    expected = json.loads((directory / "esperado.json").read_text(encoding="utf-8"))
    assert len(expected["archivos"]) == 18
    assert not (directory / "no-debe-existir.pdf").exists(), "No emitir el definitivo incompleto"
    for filename, case in sorted(expected["archivos"].items()):
        path = directory / filename
        reader = PdfReader(path, strict=True)
        assert reader.metadata.title == "Resultados del cuestionario"
        assert reader.metadata.creator == "El Gato Milaneso"
        text = normal(" ".join(page.extract_text() for page in reader.pages))
        assert re.search(r"\b\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}\b", text), "Fecha debe usar día/mes/año"
        assert f"{case['total']} / 27" in text
        assert case["clasificacion"] in text
        # Los campos pueden cruzar líneas/páginas; no perder ningún carácter.
        with pdfplumber.open(path) as fields_pdf:
            fields = " ".join(page.crop((40, 115, 572, 724)).extract_text() for page in fields_pdf.pages)
        compact = re.sub(r"\s", "", fields)
        assert re.sub(r"\s", "", case["nombre"]) in compact
        assert re.sub(r"\s", "", case["alias"]) in compact
        assert "La pregunta 10 se registra por separado y no modifica el puntaje." in text
        if "larga" in path.name:
            assert text.count("W") == 1600 and "FIN_NOMBRE" in text and "FIN_ALIAS" in text
            assert len(reader.pages) > 2
        elif path.name == "exportacion-prueba.pdf":
            assert "Jugador: José Muñoz (PRUEBA) \\" in text
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
                    value = case["respuestas"][f"p{number}"]
                    if value == -1:
                        assert answer == "Sin responder"
                        found[number] = question
                        continue
                    if number == 10:
                        choice = expected["dificultades"][value]
                        assert answer == f"{choice} Valor: {value} - no suma"
                    else:
                        choice = expected["frecuencias"][value]
                        assert answer == f"{choice} Valor: {value}"
                    found[number] = question
        assert set(found) == set(range(1, 11)), f"Missing questions: {path}"
        print(f"OK: {path.name}, {len(reader.pages)} pages, 10 rows with correct answers and margins")


if __name__ == "__main__":
    for argument in sys.argv[1:] or ["tmp/pdfs"]:
        validate(Path(argument))
