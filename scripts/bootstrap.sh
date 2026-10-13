#!/usr/bin/env bash
set -euo pipefail
flutter create --platforms=android,windows --project-name curso_programacao_zero --org br.com.cursozero .
flutter pub get
flutter analyze
flutter test
echo "Projeto preparado."
