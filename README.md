# LatteConect MVP

Aplicacao Flutter Web responsiva para a Sprint 3 da FIAP. O MVP conecta nutrizes
doadoras, familias, hospitais e bancos de leite em uma experiencia navegavel
com cadastro, solicitacao, agendamento, painel operacional e paginas
informativas.

## Requisitos

- Flutter `>=3.44.0`

## Como rodar

```bash
flutter pub get
flutter run -d chrome
flutter build web --release --output dist
```

## Estrutura

- `lib/`: codigo-fonte Flutter da aplicacao
- `web/`: arquivos de entrada e metadados do Flutter Web
- `test/`: verificacoes automatizadas dos widgets

## Comandos uteis

- `flutter run -d chrome`: inicia o ambiente local no navegador
- `flutter build web --release --output dist`: gera o build web estatico
- `flutter test`: verifica os widgets principais do LatteConect
