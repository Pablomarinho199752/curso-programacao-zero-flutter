import unittest

import python_runtime.main as runtime


class RuntimeTests(unittest.TestCase):
    def test_executes_real_python_and_captures_output(self):
        result = runtime.execute_code(
            'total = 0\nfor numero in range(1, 4):\n    total += numero\nprint(total)',
            '',
        )
        self.assertTrue(result['ok'])
        self.assertEqual(result['stdout'].strip(), '6')

    def test_supports_input_lines(self):
        result = runtime.execute_code(
            'nome = input("Nome: ")\nidade = int(input("Idade: "))\nprint(nome, idade + 1)',
            'Lia\n21',
        )
        self.assertTrue(result['ok'])
        self.assertIn('Lia 22', result['stdout'])

    def test_reports_syntax_error_line(self):
        result = runtime.execute_code('if True\n    print("x")', '')
        self.assertFalse(result['ok'])
        self.assertEqual(result['errorType'], 'SyntaxError')
        self.assertEqual(result['errorLine'], 1)

    def test_blocks_dangerous_imports(self):
        with self.assertRaises(runtime.LabValidationError):
            runtime.execute_code('import os\nprint(os.getcwd())', '')

    def test_interrupts_infinite_cpu_loop(self):
        old_limit = runtime.EXECUTION_SECONDS
        runtime.EXECUTION_SECONDS = 0.02
        try:
            result = runtime.execute_code('while True:\n    pass', '')
        finally:
            runtime.EXECUTION_SECONDS = old_limit
        self.assertFalse(result['ok'])
        self.assertEqual(result['errorType'], 'TimeoutError')


if __name__ == '__main__':
    unittest.main()
