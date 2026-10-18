import ast
import builtins
import contextlib
import io
import json
import os
import re
import sys
import tempfile
import time
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST = "127.0.0.1"
PORT = 8765
MAX_CODE_SIZE = 12000
EXECUTION_SECONDS = 4.0

ALLOWED_IMPORT_ROOTS = {
    "collections",
    "datetime",
    "decimal",
    "fractions",
    "functools",
    "itertools",
    "json",
    "math",
    "random",
    "re",
    "sqlite3",
    "statistics",
    "string",
    "time",
    "urllib",
}

BLOCKED_CALLS = {
    "breakpoint",
    "compile",
    "eval",
    "exec",
    "exit",
    "globals",
    "help",
    "locals",
    "quit",
    "vars",
}


class LabValidationError(Exception):
    pass


class LabTimeoutError(Exception):
    pass


def validate_source(source: str) -> ast.AST:
    if not source.strip():
        raise LabValidationError("Escreva algum código antes de executar.")
    if len(source) > MAX_CODE_SIZE:
        raise LabValidationError(
            f"O laboratório aceita até {MAX_CODE_SIZE} caracteres por execução."
        )

    tree = ast.parse(source, mode="exec")

    for node in ast.walk(tree):
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            names = []
            if isinstance(node, ast.Import):
                names = [item.name for item in node.names]
            elif node.module:
                names = [node.module]
            for name in names:
                root = name.split(".", 1)[0]
                if root not in ALLOWED_IMPORT_ROOTS:
                    raise LabValidationError(
                        f"O módulo '{root}' não está liberado neste laboratório. "
                        "Use os recursos da aula ou um módulo padrão permitido."
                    )
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name):
            if node.func.id in BLOCKED_CALLS:
                raise LabValidationError(
                    f"A função '{node.func.id}' foi bloqueada para manter o laboratório estável."
                )
    return tree


def guarded_import(name, globals=None, locals=None, fromlist=(), level=0):
    root = name.split(".", 1)[0]
    if root not in ALLOWED_IMPORT_ROOTS:
        raise ImportError(
            f"O módulo '{root}' não está liberado neste laboratório."
        )
    return builtins.__import__(name, globals, locals, fromlist, level)


def lab_open(path, mode="r", encoding="utf-8"):
    """Open only small local text files in the course's private scratch space.

    Files remain available between executions while the OS preserves app cache.
    Absolute/traversal paths, binary access and arbitrary device files are
    rejected. This is intentionally *not* unrestricted filesystem access.
    """
    if not isinstance(path, str) or not path:
        raise ValueError("Informe um nome de arquivo, como notas.txt.")
    if (
        os.path.basename(path) != path
        or path in (".", "..")
        or "/" in path
        or "\\\\" in path
        or "\\x00" in path
        or len(path) > 100
    ):
        raise ValueError("Use apenas um nome simples de arquivo, sem pastas.")
    if not path.lower().endswith((".txt", ".json", ".csv")):
        raise ValueError("O laboratório aceita arquivos .txt, .json ou .csv.")
    if mode not in ("r", "w", "a", "x", "r+", "w+", "a+"):
        raise ValueError("Use modo texto: r, w, a, x ou suas variantes +.")
    home = os.path.join(tempfile.gettempdir(), "curso_zero_python_files")
    os.makedirs(home, exist_ok=True)
    return builtins.open(os.path.join(home, path), mode, encoding=encoding)


def safe_builtins(input_values):
    values = iter(input_values)

    def lab_input(prompt=""):
        if prompt:
            print(prompt, end="")
        try:
            return next(values)
        except StopIteration:
            raise EOFError(
                "O programa pediu mais entradas do que foram informadas no campo Entrada."
            )

    allowed_names = [
        "abs",
        "all",
        "any",
        "bool",
        "chr",
        "dict",
        "divmod",
        "enumerate",
        "filter",
        "float",
        "format",
        "frozenset",
        "int",
        "isinstance",
        "issubclass",
        "iter",
        "len",
        "list",
        "map",
        "max",
        "min",
        "next",
        "object",
        "ord",
        "pow",
        "print",
        "range",
        "repr",
        "reversed",
        "round",
        "set",
        "slice",
        "sorted",
        "str",
        "sum",
        "super",
        "tuple",
        "type",
        "zip",
        "Exception",
        "FileNotFoundError",
        "OSError",
        "ArithmeticError",
        "AssertionError",
        "IndexError",
        "KeyError",
        "NameError",
        "RuntimeError",
        "TypeError",
        "ValueError",
        "ZeroDivisionError",
    ]
    result = {name: getattr(builtins, name) for name in allowed_names}
    result["input"] = lab_input
    result["open"] = lab_open
    result["__import__"] = guarded_import
    result["__build_class__"] = builtins.__build_class__
    return result



def _has_required_element(tree: ast.AST, source: str, requirement: str) -> bool:
    """Inspect Python syntax instead of depending on exact spacing or quotes."""
    token = requirement.strip()
    simple = token.lower()
    nodes = list(ast.walk(tree))

    if simple == "if":
        return any(isinstance(node, ast.If) for node in nodes)
    if simple == "elif":
        return any(
            isinstance(child, ast.If)
            for node in nodes if isinstance(node, ast.If)
            for child in node.orelse
        )
    if simple == "else:":
        return any(
            isinstance(node, ast.If)
            and bool(node.orelse)
            and not isinstance(node.orelse[0], ast.If)
            for node in nodes
        )
    if simple == "print(":
        return any(
            isinstance(node, ast.Call)
            and isinstance(node.func, ast.Name)
            and node.func.id == "print"
            for node in nodes
        )
    if simple == "def":
        return any(isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) for node in nodes)
    if simple.startswith("def ") and "(" not in token:
        function_name = token[4:].strip()
        return any(
            isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
            and node.name.lower() == function_name
            for node in nodes
        )
    if simple == "return":
        return any(isinstance(node, ast.Return) for node in nodes)
    if simple == "assert":
        return any(isinstance(node, ast.Assert) for node in nodes)
    if simple == "and":
        return any(
            isinstance(node, ast.BoolOp) and isinstance(node.op, ast.And)
            for node in nodes
        )
    if simple == "=":
        return any(isinstance(node, (ast.Assign, ast.AnnAssign, ast.AugAssign)) for node in nodes)
    if simple == "try:":
        return any(isinstance(node, ast.Try) for node in nodes)
    if simple == "except":
        return any(isinstance(node, ast.ExceptHandler) for node in nodes)

    # Compare whole expressions as trees, independent of legal formatting.
    candidates = []
    try:
        candidates.append(ast.parse(token, mode="eval").body)
    except SyntaxError:
        pass
    if token.startswith("return "):
        try:
            wrapper = ast.parse("def _test():\n    " + token)
            candidates.append(wrapper.body[0].body[0])
        except SyntaxError:
            pass
    for candidate in candidates:
        expected = ast.dump(candidate, include_attributes=False)
        if any(ast.dump(node, include_attributes=False) == expected for node in nodes):
            return True

    # Legacy curriculum fragments (SQL and incomplete expressions) cannot
    # always be parsed independently; ignore formatting without changing code.
    condensed_source = re.sub(r"\s+", "", source).lower()
    condensed_token = re.sub(r"\s+", "", token).lower()
    return condensed_token in condensed_source


def check_code(source: str, requirements: list[str] | None = None) -> dict:
    """Validate real Python syntax plus the teaching goal, without executing it."""
    try:
        tree = validate_source(source)
    except SyntaxError as exc:
        return {
            "ok": False,
            "error": exc.msg,
            "errorType": "SyntaxError",
            "errorLine": exc.lineno,
            "missing": [],
        }
    except LabValidationError as exc:
        return {
            "ok": False,
            "error": str(exc),
            "errorType": "ValidationError",
            "errorLine": None,
            "missing": [],
        }

    missing = [
        item for item in (requirements or [])
        if not _has_required_element(tree, source, item)
    ]
    return {
        "ok": not missing,
        "error": None,
        "errorType": None,
        "errorLine": None,
        "missing": missing,
    }


def execute_code(source: str, stdin_text: str):
    stdout = io.StringIO()
    stderr = io.StringIO()
    inputs = stdin_text.splitlines()
    deadline = time.monotonic() + EXECUTION_SECONDS

    def trace(frame, event, arg):
        if time.monotonic() > deadline:
            raise LabTimeoutError(
                "A execução passou de 4 segundos. Verifique se existe um loop que nunca termina."
            )
        return trace

    namespace = {
        "__builtins__": safe_builtins(inputs),
        "__name__": "__main__",
    }
    started = time.perf_counter()
    error = None
    error_type = None
    error_line = None

    try:
        tree = validate_source(source)
        compiled = compile(tree, "<laboratorio>", "exec")
        sys.settrace(trace)
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            exec(compiled, namespace, namespace)
    except SyntaxError as exc:
        error_type = "SyntaxError"
        error_line = exc.lineno
        error = exc.msg
    except LabValidationError as exc:
        error_type = "ValidationError"
        error = str(exc)
    except LabTimeoutError as exc:
        error_type = "TimeoutError"
        error = str(exc)
    except Exception as exc:
        error_type = type(exc).__name__
        tb = traceback.extract_tb(exc.__traceback__)
        lab_frames = [frame for frame in tb if frame.filename == "<laboratorio>"]
        if lab_frames:
            error_line = lab_frames[-1].lineno
        error = str(exc) or error_type
    finally:
        sys.settrace(None)

    duration_ms = int((time.perf_counter() - started) * 1000)
    return {
        "ok": error is None,
        "stdout": stdout.getvalue(),
        "stderr": stderr.getvalue(),
        "error": error,
        "errorType": error_type,
        "errorLine": error_line,
        "durationMs": duration_ms,
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "CursoZeroPython/1.0"

    def log_message(self, format, *args):
        return

    def _send(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self._send(200, {"ok": True, "runtime": sys.version.split()[0]})
        else:
            self._send(404, {"ok": False, "error": "Rota não encontrada."})

    def do_POST(self):
        if self.path not in ("/run", "/check"):
            self._send(404, {"ok": False, "error": "Rota não encontrada."})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length <= 0 or length > 30000:
                raise LabValidationError("Requisição inválida para o laboratório.")
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
            source = payload.get("code", "")
            stdin_text = payload.get("stdin", "")
            if not isinstance(source, str) or not isinstance(stdin_text, str):
                raise LabValidationError("Código e entrada precisam ser texto.")
            if self.path == "/check":
                requirements = payload.get("requirements", [])
                if not isinstance(requirements, list) or any(
                    not isinstance(item, str) for item in requirements
                ):
                    raise LabValidationError("Requisitos inválidos.")
                self._send(200, check_code(source, requirements))
            else:
                result = execute_code(source, stdin_text)
                self._send(200, result)
        except LabValidationError as exc:
            self._send(
                200,
                {
                    "ok": False,
                    "stdout": "",
                    "stderr": "",
                    "error": str(exc),
                    "errorType": "ValidationError",
                    "errorLine": None,
                    "durationMs": 0,
                },
            )
        except Exception as exc:
            self._send(
                500,
                {
                    "ok": False,
                    "stdout": "",
                    "stderr": "",
                    "error": str(exc),
                    "errorType": type(exc).__name__,
                    "errorLine": None,
                    "durationMs": 0,
                },
            )


def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    server.daemon_threads = True
    print(f"Curso Zero Python pronto em {HOST}:{PORT}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
