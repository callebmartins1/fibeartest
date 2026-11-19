ALTER TABLE public.profiles
  ADD COLUMN idade integer CHECK (idade IS NULL OR (idade BETWEEN 13 AND 120)),
  ADD COLUMN peso_kg numeric(5,1) CHECK (peso_kg IS NULL OR (peso_kg BETWEEN 20 AND 400)),
  ADD COLUMN altura_cm integer CHECK (altura_cm IS NULL OR (altura_cm BETWEEN 80 AND 260)),
  ADD COLUMN sexo text CHECK (sexo IS NULL OR sexo IN ('masculino','feminino','outro','prefiro_nao_dizer')),
  ADD COLUMN tempo_treino text CHECK (tempo_treino IS NULL OR tempo_treino IN ('nao_treina','menos_6m','6m_1a','1a_3a','mais_3a')),
  ADD COLUMN termos_aceitos_em timestamptz;

CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_idade integer;
BEGIN
  BEGIN v_idade := NULLIF(NEW.raw_user_meta_data->>'idade','')::integer; EXCEPTION WHEN others THEN v_idade := NULL; END;
  IF v_idade IS NOT NULL AND (v_idade < 13 OR v_idade > 120) THEN v_idade := NULL; END IF;
  INSERT INTO public.profiles (id, nome, avatar_url, idade, termos_aceitos_em)
  VALUES (NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', split_part(NEW.email,'@',1)),
    NEW.raw_user_meta_data->>'avatar_url',
    v_idade,
    CASE WHEN NEW.raw_user_meta_data->>'termos_aceitos' = 'true' THEN now() ELSE NULL END);
  RETURN NEW;
END $$;

CREATE TABLE public.seguidores (
  seguidor_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  seguido_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (seguidor_id, seguido_id),
  CHECK (seguidor_id <> seguido_id)
);
CREATE INDEX seguidores_seguido_idx ON public.seguidores(seguido_id);
GRANT SELECT ON public.seguidores TO anon;
GRANT SELECT, INSERT, DELETE ON public.seguidores TO authenticated;
GRANT ALL ON public.seguidores TO service_role;
ALTER TABLE public.seguidores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "seguidores leitura" ON public.seguidores FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "segue" ON public.seguidores FOR INSERT TO authenticated WITH CHECK (auth.uid() = seguidor_id);
CREATE POLICY "deixa de seguir" ON public.seguidores FOR DELETE TO authenticated USING (auth.uid() = seguidor_id);