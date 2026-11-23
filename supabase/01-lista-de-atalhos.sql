-- ============================================================
-- 01 — Lista de atalhos da equipe
--
-- Até aqui a lista morava só no aparelho de cada um. Esta tabela é a
-- BASE: quem publica manda a lista para cá, e todo aparelho que abrir o
-- app passa a ver essa lista.
--
-- Projeto: painel-sesmt (ldqegnfcjeljvywbravl) — o mesmo do painel e do
-- app de inspeções. Não criei projeto novo: seriam mais uma chave, mais
-- um lugar para olhar quando algo quebra, e o Supabase gratuito dorme
-- projetos parados.
--
-- LER é livre, sem login: a lista é só endereço de site, e exigir conta
-- para ver atalho transformaria um app de um toque num app de dois.
-- PUBLICAR exige login, e de UMA conta só — ver atalhos_quem_publica.
-- ============================================================

-- ---------- a lista ----------
-- Uma linha só, para sempre. O "check (id = 1)" é o que garante isso:
-- sem ele, um erro de código criaria uma segunda lista e o app passaria
-- a mostrar uma ou outra conforme a ordem que o banco devolvesse.
create table if not exists public.atalhos_lista (
  id            smallint primary key default 1 check (id = 1),
  dados         jsonb       not null default '[]'::jsonb,
  atualizado_em timestamptz not null default now(),
  por           text
);

comment on table  public.atalhos_lista is 'Lista de atalhos que todos os aparelhos enxergam';
comment on column public.atalhos_lista.dados is 'Os atalhos: [{n,u,g,f,c}] — mesmo formato da chave de transferência';
comment on column public.atalhos_lista.por is 'E-mail de quem publicou por último';

insert into public.atalhos_lista (id, dados)
values (1, '[]'::jsonb)
on conflict (id) do nothing;

-- ---------- quem pode publicar ----------
-- Tabela, e não e-mail escrito dentro da política: trocar quem publica
-- vira um INSERT, não uma reescrita de regra de segurança.
create table if not exists public.atalhos_quem_publica (
  email text primary key
);

comment on table public.atalhos_quem_publica is 'E-mails autorizados a publicar a lista de atalhos';

-- A conta única de publicação. Ela é criada no painel do Supabase, em
-- Authentication → Users → Add user, COM "Auto Confirm User" marcado —
-- usuário sem e-mail confirmado não consegue entrar.
insert into public.atalhos_quem_publica (email)
values ('atalhos@teccel.com.br')
on conflict (email) do nothing;

-- ---------- acesso ----------
alter table public.atalhos_lista       enable row level security;
alter table public.atalhos_quem_publica enable row level security;

drop policy if exists "atalhos: qualquer um lê" on public.atalhos_lista;
create policy "atalhos: qualquer um lê"
  on public.atalhos_lista for select
  to anon, authenticated
  using (true);

/* Escrever é só para a conta de publicação.

   O "to authenticated" sozinho NÃO bastaria: os inspetores têm conta
   neste mesmo projeto, por causa do app de inspeções, e qualquer um
   deles poderia trocar a lista da equipe sem querer. A conferência é
   pelo e-mail que vem dentro do token. */
drop policy if exists "atalhos: só o publicador escreve" on public.atalhos_lista;
create policy "atalhos: só o publicador escreve"
  on public.atalhos_lista for update
  to authenticated
  using (
    exists (select 1 from public.atalhos_quem_publica q
             where q.email = lower(auth.jwt() ->> 'email'))
  )
  with check (
    exists (select 1 from public.atalhos_quem_publica q
             where q.email = lower(auth.jwt() ->> 'email'))
  );

/* A lista de quem publica não é pública: ela não interessa a ninguém de
   fora e expõe um e-mail. Quem precisa dela é a política acima, que roda
   dentro do banco e não passa por RLS do cliente. */
drop policy if exists "publicadores: ninguém lê pelo app" on public.atalhos_quem_publica;
create policy "publicadores: ninguém lê pelo app"
  on public.atalhos_quem_publica for select
  to authenticated
  using (lower(auth.jwt() ->> 'email') = email);

-- ---------- conferência ----------
select id, jsonb_array_length(dados) as quantos, atualizado_em, por
  from public.atalhos_lista;
select email from public.atalhos_quem_publica;
