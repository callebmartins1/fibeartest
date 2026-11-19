CREATE TABLE public.mensagens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  remetente_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  destinatario_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  texto text NOT NULL CHECK (char_length(texto) BETWEEN 1 AND 1000),
  lida boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (remetente_id <> destinatario_id)
);
CREATE INDEX mensagens_par_idx ON public.mensagens (remetente_id, destinatario_id, created_at);
CREATE INDEX mensagens_dest_idx ON public.mensagens (destinatario_id, created_at);
GRANT SELECT, INSERT, UPDATE ON public.mensagens TO authenticated;
GRANT ALL ON public.mensagens TO service_role;
ALTER TABLE public.mensagens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "participantes leem" ON public.mensagens FOR SELECT TO authenticated USING (auth.uid() = remetente_id OR auth.uid() = destinatario_id);
CREATE POLICY "envia propria" ON public.mensagens FOR INSERT TO authenticated WITH CHECK (auth.uid() = remetente_id AND lida = false);
CREATE POLICY "destinatario marca lida" ON public.mensagens FOR UPDATE TO authenticated USING (auth.uid() = destinatario_id) WITH CHECK (auth.uid() = destinatario_id);