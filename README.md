# grilo
Grilho Falante um sistema de gerenciamento de artesanato em flutter

## Setup do ambiente (dev container)

Este workspace foi preparado para desenvolvimento Flutter com Android build no Linux.

### Ferramentas instaladas

- Flutter SDK (stable)
- Firebase CLI
- Android SDK (command-line tools, platform-tools, build-tools 36.0.0, platform android-36)
- Claude Code CLI

### Variaveis de ambiente

As variaveis abaixo foram adicionadas ao shell do usuario:

- `PATH` com `~/flutter/bin`
- `ANDROID_SDK_ROOT=~/Android/Sdk`
- `ANDROID_HOME=~/Android/Sdk`
- `PATH` com `~/Android/Sdk/cmdline-tools/latest/bin` e `~/Android/Sdk/platform-tools`

Se abrir um novo terminal, rode:

```bash
source ~/.bashrc
```

### Validacao rapida

```bash
flutter --version
firebase --version
sdkmanager --version
claude --version
flutter doctor -v
```

### Observacoes

- Licencas Android ja foram aceitas no ambiente atual.
- Firebase CLI requer autenticacao manual:

```bash
firebase login
```

- Claude Code CLI pode requerer autenticacao no primeiro uso, dependendo da configuracao da conta.
- Nao foi instalado emulador Android (escopo atual: build essencial).
