# Setup completo — Fina-Auto

Tudo no **código já está pronto**. Só precisa de **uma vez** ligar as contas Google/Firebase (ninguém consegue fazer isso por si — são as suas chaves).

## Automático (1 comando)

Abra PowerShell na pasta do projeto:

```powershell
cd c:\Users\Toshiba\Documents\fina-auto
.\scripts\setup-completo.ps1
```

Isto tenta:
- Instalar Flutter (winget)
- Gerar pastas Android/iOS (`flutter create`)
- `flutter pub get` nos 2 apps
- Criar `CONFIG.env` e injetar chave do Google Maps

---

## Manual rápido (10–15 min)

### Passo 1 — Firebase (obrigatório)

1. Abra https://console.firebase.google.com  
2. **Criar projeto** → nome: `fina-auto`  
3. **Authentication** → Sign-in method → **Email/Password** → Ativar  
4. **Firestore Database** → Criar base (modo teste para desenvolvimento)  
5. **Adicionar app** → Android:
   - App 1: package `com.finaauto.cliente` → descarregar `google-services.json`  
     → colocar em `fina_auto_cliente/android/app/google-services.json`
   - App 2: package `com.finaauto.pro` → outro `google-services.json`  
     → colocar em `fina_auto_pro/android/app/google-services.json`

### Passo 2 — FlutterFire (liga o código ao Firebase)

```powershell
dart pub global activate flutterfire_cli
cd fina_auto_cliente
dart run flutterfire_cli:flutterfire configure
cd ..\fina_auto_pro
dart run flutterfire_cli:flutterfire configure
```

Isto substitui `lib/firebase_options.dart` automaticamente.

### Passo 3 — Google Maps

1. https://console.cloud.google.com → mesmo projeto do Firebase  
2. **APIs & Services** → ativar **Maps SDK for Android**  
3. **Credentials** → Create API Key  
4. Edite `CONFIG.env`:

```
GOOGLE_MAPS_API_KEY=AIza...sua_chave
```

5. Execute:

```powershell
.\scripts\inject-config.ps1
```

### Passo 4 — Regras Firestore

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore
```

### Passo 5 — Correr os apps

Terminal 1:
```powershell
cd fina_auto_cliente
flutter run
```

Terminal 2:
```powershell
cd fina_auto_pro
flutter run
```

---

## O que já está implementado no código

| Funcionalidade | Cliente | Pro |
|----------------|---------|-----|
| Login / registo | ✅ | ✅ |
| Mapa + marcadores oficinas/mecânicos | ✅ | — |
| Criar pedido | ✅ | — |
| Aceitar / rejeitar | — | ✅ |
| Navegação GPS (Google Maps) | — | ✅ |
| Chat tempo real | ✅ | ✅ |
| Pagamento simulado (15 000 AOA) | ✅ | — |
| Avaliação 1–5 estrelas | ✅ | — |
| Histórico de ganhos | — | ✅ |
| Localização no mapa (Pro) | — | ✅ |
| Token FCM guardado no Firestore | ✅ | ✅ |

---

## Testar o fluxo completo

1. **Pro** — registe-se como mecânico (com GPS ativo para aparecer no mapa)  
2. **Cliente** — registe-se → mapa deve mostrar o marcador verde/laranja  
3. **Cliente** — «Pedir mecânico» → enviar pedido  
4. **Pro** — «Novos» → Aceitar → «Navegar até ao cliente»  
5. **Ambos** — Chat  
6. **Pro** — Iniciar → Concluir  
7. **Cliente** — Pagar → Avaliar  
8. **Pro** — «Ganhos» — ver pagamento  

---

## Push notifications (opcional)

Os tokens FCM são guardados em `users.fcmToken`. Para notificações automáticas (novo pedido, pedido aceite), configure depois **Firebase Cloud Functions** — o app já está preparado.

---

## Problemas comuns

| Erro | Solução |
|------|---------|
| `flutter` não encontrado | `.\scripts\install-flutter.ps1` ou instalar manualmente |
| Mapa cinza | Chave Maps em `CONFIG.env` + `inject-config.ps1` |
| Firebase auth failed | `flutterfire configure` + `google-services.json` |
| Permissão Firestore | `firebase deploy --only firestore` |
