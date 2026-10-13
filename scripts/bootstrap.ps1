$ErrorActionPreference = "Stop"
flutter create --platforms=android,windows --project-name curso_programacao_zero --org br.com.cursozero .
flutter pub get
flutter analyze
flutter test
Write-Host "Projeto preparado. Use 'flutter run -d windows' ou conecte um Android." -ForegroundColor Green
