CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome text NOT NULL DEFAULT 'Atleta',
  avatar_url text,
  bio text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.profiles TO anon;
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "perfis publicos" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "insere proprio" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "edita proprio" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, nome, avatar_url)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', split_part(NEW.email,'@',1)), NEW.raw_user_meta_data->>'avatar_url');
  RETURN NEW;
END $$;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TABLE public.posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  imagem_url text,
  legenda text NOT NULL DEFAULT '',
  categoria text NOT NULL CHECK (categoria IN ('luta','musculacao')),
  curtidas integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.posts TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.posts TO authenticated;
GRANT ALL ON public.posts TO service_role;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "posts publicos" ON public.posts FOR SELECT USING (true);
CREATE POLICY "cria proprio post" ON public.posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "apaga proprio post" ON public.posts FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TABLE public.curtidas (
  post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  PRIMARY KEY (post_id, user_id)
);
GRANT SELECT ON public.curtidas TO anon;
GRANT SELECT, INSERT, DELETE ON public.curtidas TO authenticated;
GRANT ALL ON public.curtidas TO service_role;
ALTER TABLE public.curtidas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "curtidas publicas" ON public.curtidas FOR SELECT USING (true);
CREATE POLICY "curte" ON public.curtidas FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "descurte" ON public.curtidas FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.sync_curtidas() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN UPDATE public.posts SET curtidas = curtidas + 1 WHERE id = NEW.post_id; RETURN NEW;
  ELSE UPDATE public.posts SET curtidas = GREATEST(curtidas - 1, 0) WHERE id = OLD.post_id; RETURN OLD; END IF;
END $$;
CREATE TRIGGER curtidas_sync AFTER INSERT OR DELETE ON public.curtidas FOR EACH ROW EXECUTE FUNCTION public.sync_curtidas();

CREATE TABLE public.academias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  endereco text NOT NULL,
  modalidades text[] NOT NULL DEFAULT '{}',
  horario text NOT NULL,
  tipo text NOT NULL DEFAULT 'luta' CHECK (tipo IN ('luta','musculacao','misto')),
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.academias TO anon, authenticated;
GRANT ALL ON public.academias TO service_role;
ALTER TABLE public.academias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "academias publicas" ON public.academias FOR SELECT USING (true);

INSERT INTO public.academias (nome, latitude, longitude, endereco, modalidades, horario, tipo) VALUES
('Gracie Barra Paulista', -23.5614, -46.6559, 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP', ARRAY['Jiu-Jitsu','No-Gi'], 'Seg-Sex 6h-22h | Sáb 9h-13h', 'luta'),
('Iron Gym Pinheiros', -23.5672, -46.6922, 'R. dos Pinheiros, 450 - Pinheiros, São Paulo - SP', ARRAY['Musculação','Funcional'], 'Seg-Sex 5h-23h | Sáb-Dom 8h-18h', 'musculacao'),
('Chute Boxe Moema', -23.6005, -46.6650, 'Av. Ibirapuera, 2300 - Moema, São Paulo - SP', ARRAY['Muay Thai','Boxe','MMA'], 'Seg-Sex 7h-22h', 'luta'),
('Titan Fight & Fitness', -23.5440, -46.6380, 'R. Augusta, 1500 - Consolação, São Paulo - SP', ARRAY['Musculação','Boxe','Muay Thai'], 'Seg-Sex 6h-23h | Sáb 9h-15h', 'misto'),
('Nova União Rio', -22.9711, -43.1822, 'R. Barata Ribeiro, 200 - Copacabana, Rio de Janeiro - RJ', ARRAY['Jiu-Jitsu','MMA','Muay Thai'], 'Seg-Sex 7h-22h | Sáb 9h-12h', 'luta'),
('Body Tech Barra', -23.0004, -43.3659, 'Av. das Américas, 4666 - Barra da Tijuca, Rio de Janeiro - RJ', ARRAY['Musculação','Crossfit'], 'Seg-Sex 6h-23h | Sáb-Dom 8h-20h', 'musculacao'),
('Alliance Ipanema', -22.9840, -43.2050, 'R. Visconde de Pirajá, 300 - Ipanema, Rio de Janeiro - RJ', ARRAY['Jiu-Jitsu'], 'Seg-Sex 6h-21h', 'luta'),
('Team Nogueira BH', -19.9320, -43.9380, 'Av. Afonso Pena, 3000 - Funcionários, Belo Horizonte - MG', ARRAY['Boxe','Jiu-Jitsu','Musculação'], 'Seg-Sex 6h-22h | Sáb 8h-14h', 'misto'),
('Smart Fit Savassi', -19.9380, -43.9330, 'R. Pernambuco, 1000 - Savassi, Belo Horizonte - MG', ARRAY['Musculação'], 'Seg-Sex 5h-23h | Sáb-Dom 9h-17h', 'musculacao'),
('Kimura Team Curitiba', -25.4284, -49.2733, 'R. XV de Novembro, 700 - Centro, Curitiba - PR', ARRAY['Jiu-Jitsu','Judô'], 'Seg-Sex 7h-22h', 'luta'),
('Força Total Porto Alegre', -30.0346, -51.2177, 'Av. Ipiranga, 5000 - Partenon, Porto Alegre - RS', ARRAY['Musculação','Powerlifting'], 'Seg-Sex 6h-23h | Sáb 8h-16h', 'musculacao'),
('Arena Thai Salvador', -12.9777, -38.5016, 'Av. Sete de Setembro, 1200 - Centro, Salvador - BA', ARRAY['Muay Thai','Kickboxing'], 'Seg-Sex 7h-21h | Sáb 9h-12h', 'luta'),
('Fortaleza Fight Club', -3.7319, -38.5267, 'Av. Beira Mar, 2500 - Meireles, Fortaleza - CE', ARRAY['MMA','Boxe','Jiu-Jitsu'], 'Seg-Sex 6h-22h', 'luta'),
('Brasília Strong Gym', -15.7942, -47.8822, 'SCS Quadra 2 - Asa Sul, Brasília - DF', ARRAY['Musculação','Funcional','Boxe'], 'Seg-Sex 5h-23h | Sáb-Dom 8h-18h', 'misto'),
('Recife Combat Center', -8.0476, -34.8770, 'Av. Boa Viagem, 3000 - Boa Viagem, Recife - PE', ARRAY['Muay Thai','Jiu-Jitsu','Capoeira'], 'Seg-Sex 7h-22h | Sáb 9h-13h', 'luta');

INSERT INTO storage.objects (bucket_id, name) SELECT 'x','x' WHERE false;
CREATE POLICY "posts imagens publicas" ON storage.objects FOR SELECT USING (bucket_id = 'posts');
CREATE POLICY "upload proprio" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'posts' AND (storage.foldername(name))[1] = auth.uid()::text);