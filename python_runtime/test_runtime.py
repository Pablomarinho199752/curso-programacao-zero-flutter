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

    def test_blocks_dangerous_imports_with_friendly_feedback(self):
        result = runtime.execute_code('import os\nprint(os.getcwd())', '')
        self.assertFalse(result['ok'])
        self.assertEqual(result['errorType'], 'ValidationError')
        self.assertIn("módulo 'os'", result['error'])

    def test_interrupts_infinite_cpu_loop(self):
        old_limit = runtime.EXECUTION_SECONDS
        runtime.EXECUTION_SECONDS = 0.02
        try:
            result = runtime.execute_code('while True:\n    pass', '')
        finally:
            runtime.EXECUTION_SECONDS = old_limit
        self.assertFalse(result['ok'])
        self.assertEqual(result['errorType'], 'TimeoutError')

    def test_check_accepts_valid_age_ranges_with_whitespace(self):
        source = (
            'idade = 18\\n'
            'if idade >=18:\\n'
            '    print ("adulto")\\n'
            'elif 12<= idade <=17:\\n'
            '    print ("adolescente")\\n'
            'else:\\n'
            '    print ("criança")'
        )
        check = runtime.check_code(source, ['if ', 'elif ', 'else:', 'print('])
        self.assertTrue(check['ok'], check)
        self.assertEqual(check['missing'], [])

    def test_check_uses_ast_to_accept_whitespace_and_quote_styles(self):
        source = 'idade=18\\nif idade>=18:\\n    print (\'Pode entrar\')'
        check = runtime.check_code(
            source, ['idade >= 18', 'print("Pode entrar")']
        )
        self.assertTrue(check['ok'], check)

    def test_check_reports_missing_requirements_without_hiding_syntax(self):
        check = runtime.check_code(
            'idade = 18\\nif idade >= 18:\\n    print("adulto")',
            ['if ', 'elif ', 'else:', 'print('],
        )
        self.assertFalse(check['ok'])
        self.assertEqual(check['missing'], ['elif ', 'else:'])
        self.assertIsNone(check['error'])

    def test_check_reports_real_python_syntax_error_and_line(self):
        check = runtime.check_code('idade = 18\\nif idade >= 18\\n    print("adulto")', ['if '])
        self.assertFalse(check['ok'])
        self.assertEqual(check['errorType'], 'SyntaxError')
        self.assertEqual(check['errorLine'], 2)

    def test_check_return_and_function_name(self):
        check = runtime.check_code(
            'def desconto(valor):\\n    return valor',
            ['def desconto', 'return'],
        )
        self.assertTrue(check['ok'], check)



if __name__ == '__main__':
    unittest.main()
