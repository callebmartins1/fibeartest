-- Rode UMA vez no Supabase (SQL Editor), depois das migrações em drizzle/migrations.
-- Cria os 3 buckets usados pelo app. Todos privados: o app usa URLs assinadas.
-- As policies de storage.objects já vêm nas migrações.
INSERT INTO storage.buckets (id, name, public) VALUES
  ('posts', 'posts', false),
  ('avatars', 'avatars', false),
  ('stories', 'stories', false)
ON CONFLICT (id) DO NOTHING;
