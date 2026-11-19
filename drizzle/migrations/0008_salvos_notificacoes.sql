CREATE TABLE public.salvos (
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);
GRANT SELECT, INSERT, DELETE ON public.salvos TO authenticated;
GRANT ALL ON public.salvos TO service_role;
ALTER TABLE public.salvos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "salvos proprios ler" ON public.salvos FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "salvos proprios criar" ON public.salvos FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "salvos proprios apagar" ON public.salvos FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE TABLE public.notificacoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  ator_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tipo text NOT NULL CHECK (tipo IN ('curtida','comentario','seguidor')),
  post_id uuid REFERENCES public.posts(id) ON DELETE CASCADE,
  lida boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX notificacoes_user_idx ON public.notificacoes(user_id, created_at DESC);
GRANT SELECT, UPDATE, DELETE ON public.notificacoes TO authenticated;
GRANT ALL ON public.notificacoes TO service_role;
ALTER TABLE public.notificacoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notif ler" ON public.notificacoes FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notif marcar" ON public.notificacoes FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "notif apagar" ON public.notificacoes FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.gera_notificacao() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE dono uuid;
BEGIN
  IF TG_TABLE_NAME = 'seguidores' THEN
    INSERT INTO notificacoes(user_id, ator_id, tipo) VALUES (NEW.seguido_id, NEW.seguidor_id, 'seguidor');
  ELSE
    SELECT user_id INTO dono FROM posts WHERE id = NEW.post_id;
    IF dono IS NOT NULL AND dono <> NEW.user_id THEN
      INSERT INTO notificacoes(user_id, ator_id, tipo, post_id) VALUES (dono, NEW.user_id, CASE WHEN TG_TABLE_NAME = 'curtidas' THEN 'curtida' ELSE 'comentario' END, NEW.post_id);
    END IF;
  END IF;
  RETURN NEW;
END $$;
REVOKE EXECUTE ON FUNCTION public.gera_notificacao() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER notif_curtida AFTER INSERT ON public.curtidas FOR EACH ROW EXECUTE FUNCTION public.gera_notificacao();
CREATE TRIGGER notif_comentario AFTER INSERT ON public.comentarios FOR EACH ROW EXECUTE FUNCTION public.gera_notificacao();
CREATE TRIGGER notif_seguidor AFTER INSERT ON public.seguidores FOR EACH ROW EXECUTE FUNCTION public.gera_notificacao();