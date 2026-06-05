# Fina-Auto

Sistema de assistência mecânica (estilo Uber/Yango) com **dois apps Flutter separados** e **um único backend Firebase**.

| Projeto | Pasta | Utilizadores |
|---------|-------|----------------|
| **Cliente** | `fina_auto_cliente/` | Clientes finais |
| **Pro** | `fina_auto_pro/` | Oficinas e mecânicos |
| **Core partilhado** | `packages/fina_auto_core/` | Modelos e collections Firestore |
| **Firebase** | `firebase/` | Regras e índices Firestore |

## Arquitetura

```
fina-auto/
├── fina_auto_cliente/     # App cliente (UI azul)
├── fina_auto_pro/         # App profissional (UI verde)
├── packages/fina_auto_core/
└── firebase/
```

Ambos os apps ligam-se ao **mesmo projeto Firebase** (`fina-auto`), com **apps Android/iOS distintos** no console.

## Pré-requisitos

1. [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (3.24+)
2. Conta [Firebase](https://console.firebase.google.com)
3. [Google Maps API](https://console.cloud.google.com) (Maps SDK for Android/iOS)

## Setup rápido (recomendado)

```powershell
cd c:\Users\Toshiba\Documents\fina-auto
.\scripts\setup-completo.ps1
```

Guia passo a passo: **[SETUP_COMPLETO.md](SETUP_COMPLETO.md)**

### Gerar pastas nativas manualmente

Com Flutter no PATH:

```powershell
.\scripts\setup.ps1
```

Ou manualmente em cada app:

```bash
cd fina_auto_cliente
flutter create . --project-name fina_auto_cliente --org com.finaauto
flutter pub get
```

Repita em `fina_auto_pro` com `--project-name fina_auto_pro`.

### 2. Firebase (projeto único)

1. Criar projeto **fina-auto** no Firebase Console.
2. Ativar **Authentication → Email/Password**.
3. Criar base **Firestore** (modo teste para desenvolvimento).
4. Registar **duas** apps Android no mesmo projeto:
   - `com.finaauto.cliente` → descarregar `google-services.json` → `fina_auto_cliente/android/app/`
   - `com.finaauto.pro` → `google-services.json` → `fina_auto_pro/android/app/`
5. Em cada app Flutter:

```bash
dart pub global activate flutterfire_cli
dart run flutterfire_cli:flutterfire configure
```

Isto atualiza `lib/firebase_options.dart` automaticamente.

### 3. Regras Firestore

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore
```

(Execute na raiz; usa `firebase.json` e `firebase/firestore.rules`.)

### 4. Google Maps

Substitua `SUA_CHAVE_GOOGLE_MAPS` em:

- `fina_auto_cliente/android/app/src/main/AndroidManifest.xml`
- `fina_auto_pro/android/app/src/main/AndroidManifest.xml`

Ative **Maps SDK for Android** na Google Cloud Console.

## Funcionalidades (implementadas)

| Funcionalidade | Cliente | Pro |
|----------------|---------|-----|
| Login / registo Firebase | ✅ | ✅ |
| Mapa + marcadores oficinas/mecânicos | ✅ | — |
| Localização no mapa (automática) | — | ✅ |
| Criar pedido | ✅ | — |
| Aceitar / rejeitar | — | ✅ |
| Navegação GPS até cliente | — | ✅ |
| Pedidos ativos + iniciar / concluir | — | ✅ |
| Chat em tempo real | ✅ | ✅ |
| Pagamento simulado + avaliação | ✅ | — |
| Histórico de ganhos | — | ✅ |
| Token push (FCM) no Firestore | ✅ | ✅ |

## Collections Firestore

Ver [firebase/README.md](firebase/README.md).

## Executar

```bash
cd fina_auto_cliente
flutter run
```

```bash
cd fina_auto_pro
flutter run
```

## Fluxo do pedido

1. **Cliente** — Mapa → «Pedir mecânico» → descreve problema → pedido `pendente`
2. **Pro** — Aba «Novos» → abrir pedido → **Aceitar** ou **Rejeitar**
3. **Pro** — Aba «Ativos» → **Iniciar serviço** → **Concluir**
4. **Ambos** — Chat disponível após aceite (`chat/{pedidoId}/mensagens`)

## Próximos passos (opcional)

1. Cloud Functions para push automático (novo pedido / aceite)
2. Pagamento real (Stripe, PayPay, etc.)
3. Painel admin web

## Nota

Nesta máquina o Flutter **não está no PATH**. Após instalar o SDK, execute `.\scripts\setup.ps1` para completar as pastas `android/` e `ios/`.
