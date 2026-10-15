from pathlib import Path


def ensure_android_min_sdk() -> None:
    candidates = [
        Path('android/app/build.gradle.kts'),
        Path('android/app/build.gradle'),
    ]
    for path in candidates:
        if not path.exists():
            continue
        text = path.read_text(encoding='utf-8')
        original = text
        if path.suffix == '.kts':
            text = text.replace('minSdk = flutter.minSdkVersion', 'minSdk = 23')
            text = text.replace('minSdk = 21', 'minSdk = 23')
        else:
            text = text.replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 23')
            text = text.replace('minSdkVersion 21', 'minSdkVersion 23')
        if text == original and 'minSdk' not in text:
            raise SystemExit(f'Não foi possível localizar minSdk em {path}')
        path.write_text(text, encoding='utf-8')
        return
    raise SystemExit('Arquivo Gradle do Android não encontrado.')


def ensure_android_network_permission() -> None:
    path = Path('android/app/src/main/AndroidManifest.xml')
    if not path.exists():
        raise SystemExit('AndroidManifest.xml não encontrado.')
    text = path.read_text(encoding='utf-8')
    permission = '<uses-permission android:name="android.permission.INTERNET" />'
    if permission not in text:
        marker = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
        if marker not in text:
            raise SystemExit('Manifest Android inesperado.')
        text = text.replace(marker, marker + '\n    ' + permission, 1)
    path.write_text(text, encoding='utf-8')


def disable_android_backup_for_secure_session() -> None:
    path = Path('android/app/src/main/AndroidManifest.xml')
    text = path.read_text(encoding='utf-8')
    if 'android:allowBackup=' not in text:
        text = text.replace('<application\n', '<application\n        android:allowBackup="false"\n', 1)
    path.write_text(text, encoding='utf-8')


if __name__ == '__main__':
    ensure_android_min_sdk()
    ensure_android_network_permission()
    disable_android_backup_for_secure_session()
    print('Plataformas nativas preparadas: Android minSdk 23, internet e backup seguro.')
