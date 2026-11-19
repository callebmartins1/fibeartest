DELETE FROM public.academias WHERE created_at < now();
INSERT INTO public.academias (nome, latitude, longitude, endereco, modalidades, horario, tipo) VALUES
('Skyfit Agudos', -22.4650408, -48.9856703, 'Av. Cleophano Pitaguari, 300 - Centro, Agudos - SP', ARRAY['Musculação','Condicionamento físico'], 'Consulte o horário na academia', 'musculacao'),
('Perform Academia', -22.4755146, -48.9856607, 'R. Srg. Andiras, 89 - Centro, Agudos - SP', ARRAY['Musculação','Performance'], 'Abre às 5h', 'musculacao'),
('Life Gym', -22.4700, -48.9930, 'R. Emanuel Octaviani, 62 - Jardim Canaã, Agudos - SP', ARRAY['Musculação','Força'], 'Abre às 6h', 'musculacao'),
('QG Fitness', -22.4575208, -48.9893645, 'R. Pref. José Nogueira de Abreu, 362 - Vila Honorina, Agudos - SP', ARRAY['Musculação','Fitness'], 'Abre às 5h', 'musculacao'),
('Iron Fast Academia', -22.4811840, -48.9899927, 'R. Treze de Maio, 487 - Centro, Agudos - SP', ARRAY['Musculação'], 'Abre às 6h', 'musculacao'),
('Cross Agudos', -22.4702, -48.9933, 'R. Emanuel Octaviani, 80 - Agudos - SP', ARRAY['CrossFit','Funcional'], 'Abre às 6h', 'musculacao'),
('Salte Cross', -22.4620, -48.9800, 'Av. Ver. Otacílio Lodeiro, 507 - Jardim Europa, Agudos - SP', ARRAY['CrossFit'], 'Abre às 6h', 'musculacao'),
('Farina Team Agudos', -22.4674407, -48.9841186, 'Av. Ratelif, 51 - Centro, Agudos - SP', ARRAY['Jiu-Jitsu','Kickboxing'], 'Consulte o horário na academia', 'luta'),
('CT Wilian Gomes', -22.4780, -48.9950, 'R. Cristina Conceição Marques de Oliveira, 78 - Jardim Vienense, Agudos - SP', ARRAY['Artes marciais'], 'Abre às 9h', 'luta'),
('Gracie Barra Agudos', -22.4739379, -48.9833417, 'Av. Rui Barbosa, 35 A - Centro, Agudos - SP', ARRAY['Jiu-Jitsu','Defesa pessoal'], 'Abre às 19h', 'luta'),
('B9 Jiu Jitsu - Filial Agudos', -22.4525920, -48.9894693, 'R. José Octaviani Filho, 315 - Santana, Agudos - SP', ARRAY['Jiu-Jitsu'], 'Consulte o horário na academia', 'luta'),
('Kickboxing Agudos', -22.4750719, -48.9897665, 'R. Srg. Andiras, 203 - Centro, Agudos - SP', ARRAY['Kickboxing'], 'Abre às 20h', 'luta');