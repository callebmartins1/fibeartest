# FIBEAR

Rede social para quem treina (luta e musculação), com feed, stories, mensagens privadas, mapa de academias e o chat "Mestre FIBEAR".

**Stack:** TanStack Start (React + TypeScript), Tailwind CSS, Supabase (Auth, Postgres, Storage), OpenAI (Mestre) e Netlify (hospedagem).

## 1. Supabase

1. Crie um projeto em https://supabase.com.
2. Em **Project Settings > API**, copie a **Project URL** e a chave **publishable** (ou `anon`).
3. Aplique o banco, **na ordem**, usando uma das opções:
   - **SQL Editor:** cole e rode cada arquivo de `drizzle/migrations/0000_…sql` até `0010_…sql`.
   - **Terminal:** defina `DATABASE_URL` (Project Settings > Database > Connection string) e rode `bunx drizzle-kit migrate`.
4. Rode `supabase/setup-storage.sql` no SQL Editor (cria os buckets privados `posts`, `avatars` e `stories`).
5. Login com Google (opcional): em **Authentication > Providers > Google**, ative e informe o Client ID/Secret do Google Cloud. Em **Authentication > URL Configuration**, coloque a URL do site (e `http://localhost:5173` para testes) em *Site URL* e *Redirect URLs*.

## 2. Variáveis de ambiente

Copie `.env.example` para `.env` e preencha. Na Netlify, cadastre as mesmas em **Site configuration > Environment variables**.

| Variável | Para quê |
| --- | --- |
| `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY` | Navegador |
| `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Servidor |
| `OPENAI_API_KEY` | Mestre FIBEAR (sem ela o chat responde "indisponível") |
| `OPENAI_MODEL` | Opcional, padrão `gpt-5-mini` |
| `DATABASE_URL` | Só para `drizzle-kit` |

## 3. Imagens da marca

O logo e o mascote não vieram junto do código (eram servidos pela plataforma antiga). Coloque os arquivos em `public/`:

- `public/fibear-logo.png`
- `public/fibear-mascote.png`

## 4. Rodar

```sh
bun install
bun run dev      # http://localhost:5173
bun run test
bun run build
```

## 5. Deploy na Netlify

O `netlify.toml` já define build (`bun install && bun run build`), pasta `dist` e `NITRO_PRESET=netlify`. Conecte o repositório na Netlify, cadastre as variáveis e faça o deploy. Se preferir npm, troque o comando de build por `npm install && npm run build`.
