"""Prevent impossible lessons from being shipped as a successful build.

These checks catch syntax, packaged-runtime incompatibilities and regressions.
They are a baseline, not a substitute for pedagogical or device testing.
"""
import json
import pathlib
import unittest

from python_runtime import main as runtime


ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTENT = ROOT / "assets" / "content"


def load_lessons():
    base = json.loads((CONTENT / "modules.json").read_text(encoding="utf-8"))
    module_1 = json.loads(
        (CONTENT / "module_1_lessons.json").read_text(encoding="utf-8")
    )
    extra = json.loads(
        (CONTENT / "module_2_12_lessons.json").read_text(encoding="utf-8")
    )
    yield 0, base["modules"][0]["lessons"][0]
    for lesson in module_1["lessons"]:
        yield 1, lesson
    for key, value in extra["modules"].items():
        for lesson in value["lessons"]:
            yield int(key.split("_")[1]), lesson


class CourseContentTests(unittest.TestCase):
    def test_all_modules_present_once_and_with_required_fields(self):
        lessons = list(load_lessons())
        self.assertEqual([number for number, _ in lessons], list(range(13)))
        for number, lesson in lessons:
            with self.subTest(module=number):
                self.assertTrue(lesson["theory"])
                self.assertTrue(lesson["practicePrompt"].strip())
                self.assertTrue(lesson["challenge"].strip())
                self.assertEqual(len(lesson["quiz"]), 3)
                self.assertTrue(lesson["onboarding"]["projectPrompt"].strip())

    def test_python_examples_are_parseable_and_imports_are_packaged(self):
        for number, lesson in load_lessons():
            if number >= 11:
                continue  # Git terminal / planning activities, not Python.
            with self.subTest(module=number, lesson=lesson["id"]):
                runtime.validate_source(lesson["code"])

    def test_age_range_python_accepts_valid_spacing(self):
        program = (
            "idade = 18\n"
            "if idade >= 18:\n"
            "    print (\"adulto\")\n"
            "elif 12 <= idade <= 17:\n"
            "    print (\"adolescente\")\n"
            "else:\n"
            "    print (\"criança\")"
        )
        check = runtime.check_code(
            program, ["if ", "elif ", "else:", "print("]
        )
        self.assertTrue(check["ok"], check)

    def test_project_prerequisites_are_taught_before_required(self):
        lesson = dict(load_lessons())[2]
        theory = " ".join(lesson["theory"]).lower()
        project = lesson["onboarding"]["projectPrompt"].lower()
        self.assertIn("and", theory)
        self.assertIn("and", project)
        self.assertIn("recuperação", project)
        self.assertIn("reprovado", project)

    def test_files_lesson_can_write_read_without_external_storage(self):
        filename = "curso_zero_teste_auditoria.txt"
        source = (
            'with open("' + filename + '", "w", encoding="utf-8") as arquivo:\n'
            '    arquivo.write("uma linha\\n")\n'
            'with open("' + filename + '", "r", encoding="utf-8") as arquivo:\n'
            '    print(arquivo.read())'
        )
        result = runtime.execute_code(source, "")
        self.assertTrue(result["ok"], result)
        self.assertIn("uma linha", result["stdout"])

    def test_file_access_rejects_paths_outside_laboratory(self):
        result = runtime.execute_code(
            'with open("../segredo.txt", "w") as arquivo:\n'
            '    arquivo.write("x")',
            "",
        )
        self.assertFalse(result["ok"], result)
        self.assertIn(result["errorType"], {"ValueError", "ValidationError"})

    def test_api_chapter_uses_packaged_standard_library(self):
        lesson = dict(load_lessons())[8]
        self.assertIn("urllib.request", lesson["code"])
        self.assertNotIn("import requests", lesson["code"])
        self.assertIn("offline", lesson["code"])
        runtime.validate_source(lesson["code"])


if __name__ == "__main__":
    unittest.main()
