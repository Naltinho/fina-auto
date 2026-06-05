# Firebase — Fina-Auto (partilhado)

Os apps **fina_auto_cliente** e **fina_auto_pro** usam o **mesmo projeto Firebase**.

## Collections

| Collection   | Descrição |
|-------------|-----------|
| `users`     | Perfil com `tipo`: `cliente`, `profissional`, `admin` |
| `pedidos`   | Pedidos de assistência mecânica |
| `chat/{pedidoId}/mensagens` | Mensagens em tempo real |
| `oficinas`  | Oficinas registadas |
| `mecanicos` | Mecânicos independentes |
| `produtos`  | Catálogo (fase posterior) |
| `pagamentos`| Registos de pagamento (simulação MVP) |

## Deploy das regras

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Execute na pasta raiz após `firebase init` (ou use `firebase/firestore.rules` no projeto).
