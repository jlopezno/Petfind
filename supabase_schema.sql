-- Esquema completo de Supabase para PetFindr.
-- Ejecuta este archivo en Supabase SQL Editor como propietario del proyecto.

create extension if not exists postgis;
create extension if not exists pgcrypto;

do $$ begin
  create type public.user_role as enum ('owner', 'shelter');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.pet_species as enum ('dog', 'cat', 'bird', 'rabbit', 'other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.pet_size as enum ('small', 'medium', 'large');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.post_type as enum ('lost', 'found', 'adoption', 'sponsor');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.post_status as enum ('active', 'resolved', 'closed', 'deleted');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.adoption_status as enum ('pending', 'approved', 'rejected', 'completed');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.payment_status as enum ('pending', 'completed', 'failed', 'refunded');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.rating_target as enum ('publisher', 'shelter', 'reporter', 'adopter');
exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.user_role not null default 'owner',
  full_name text not null default '',
  phone text,
  avatar_url text,
  city text,
  shelter_name text,
  shelter_ruc text,
  shelter_bio text,
  verified boolean not null default false,
  location geometry(point, 4326),
  rating_score int not null default 0,
  rating_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  species public.pet_species not null,
  breed text,
  color text,
  size public.pet_size,
  birth_date date,
  gender char(1) not null check (gender in ('M', 'F')),
  description text,
  photos text[] not null default '{}',
  main_photo text,
  microchip_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vaccines (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  name text not null,
  administered_at date not null,
  next_due_at date,
  veterinarian text,
  clinic text,
  notes text,
  certificate_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  pet_id uuid references public.pets(id) on delete set null,
  type public.post_type not null,
  status public.post_status not null default 'active',
  title text not null,
  body text,
  photos text[] not null default '{}',
  location geometry(point, 4326),
  address_hint text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.lost_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null unique references public.posts(id) on delete cascade,
  last_seen_at timestamptz not null,
  last_seen_loc geometry(point, 4326),
  last_seen_addr text,
  circumstances text,
  reward numeric(10, 2),
  contact_phone text,
  resolved boolean not null default false,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.adoptions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  applicant_id uuid not null references public.profiles(id) on delete cascade,
  shelter_id uuid not null references public.profiles(id) on delete cascade,
  status public.adoption_status not null default 'pending',
  message text,
  rejection_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (post_id, applicant_id)
);

create table if not exists public.sponsorships (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  sponsor_id uuid not null references public.profiles(id) on delete cascade,
  amount numeric(10, 2) not null check (amount > 0),
  currency char(3) not null default 'PEN',
  payment_status public.payment_status not null default 'pending',
  payment_provider text,
  provider_tx_id text,
  provider_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sightings (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  seen_at timestamptz not null,
  location geometry(point, 4326) not null,
  address_hint text,
  photo_url text,
  notes text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  reviewer_id uuid not null references public.profiles(id) on delete cascade,
  target_id uuid not null references public.profiles(id) on delete cascade,
  target_type public.rating_target not null,
  value smallint not null check (value in (1, -1)),
  comment text,
  context_id uuid,
  created_at timestamptz not null default now(),
  check (reviewer_id <> target_id),
  unique (reviewer_id, target_id, target_type, context_id)
);

create index if not exists idx_profiles_location on public.profiles using gist(location);
create index if not exists idx_posts_location on public.posts using gist(location);
create index if not exists idx_posts_type_status_created on public.posts(type, status, created_at desc);
create index if not exists idx_pets_owner_id on public.pets(owner_id);
create index if not exists idx_sightings_post_id on public.sightings(post_id);
create index if not exists idx_ratings_target_id on public.ratings(target_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists pets_set_updated_at on public.pets;
create trigger pets_set_updated_at before update on public.pets
for each row execute function public.set_updated_at();

drop trigger if exists posts_set_updated_at on public.posts;
create trigger posts_set_updated_at before update on public.posts
for each row execute function public.set_updated_at();

drop trigger if exists adoptions_set_updated_at on public.adoptions;
create trigger adoptions_set_updated_at before update on public.adoptions
for each row execute function public.set_updated_at();

drop trigger if exists sponsorships_set_updated_at on public.sponsorships;
create trigger sponsorships_set_updated_at before update on public.sponsorships
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    role,
    full_name,
    shelter_name,
    shelter_ruc
  )
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'owner'),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(new.raw_user_meta_data ->> 'shelter_name', ''),
    nullif(new.raw_user_meta_data ->> 'shelter_ruc', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.recalculate_profile_rating(profile_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set
    rating_score = coalesce((select sum(value)::int from public.ratings where target_id = profile_id), 0),
    rating_count = coalesce((select count(*)::int from public.ratings where target_id = profile_id), 0)
  where id = profile_id;
end;
$$;

create or replace function public.refresh_rating_totals()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.recalculate_profile_rating(old.target_id);
    return old;
  end if;

  perform public.recalculate_profile_rating(new.target_id);
  if tg_op = 'UPDATE' and old.target_id <> new.target_id then
    perform public.recalculate_profile_rating(old.target_id);
  end if;
  return new;
end;
$$;

drop trigger if exists ratings_refresh_totals on public.ratings;
create trigger ratings_refresh_totals
after insert or update or delete on public.ratings
for each row execute function public.refresh_rating_totals();

create or replace function public.posts_near_location(
  lon float,
  lat float,
  radius_m int,
  filter_type text default null
)
returns table (
  id uuid,
  author_id uuid,
  pet_id uuid,
  type public.post_type,
  status public.post_status,
  title text,
  body text,
  photos text[],
  address_hint text,
  created_at timestamptz,
  updated_at timestamptz,
  lat float,
  lon float,
  distance_m float
)
language sql
stable
as $$
  select
    p.id,
    p.author_id,
    p.pet_id,
    p.type,
    p.status,
    p.title,
    p.body,
    p.photos,
    p.address_hint,
    p.created_at,
    p.updated_at,
    st_y(p.location)::float as lat,
    st_x(p.location)::float as lon,
    st_distance(
      p.location::geography,
      st_setsrid(st_makepoint(posts_near_location.lon, posts_near_location.lat), 4326)::geography
    )::float as distance_m
  from public.posts p
  where p.status = 'active'
    and p.location is not null
    and (filter_type is null or p.type::text = filter_type)
    and st_dwithin(
      p.location::geography,
      st_setsrid(st_makepoint(posts_near_location.lon, posts_near_location.lat), 4326)::geography,
      radius_m
    )
  order by distance_m asc, p.created_at desc;
$$;

alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.vaccines enable row level security;
alter table public.posts enable row level security;
alter table public.lost_reports enable row level security;
alter table public.adoptions enable row level security;
alter table public.sponsorships enable row level security;
alter table public.sightings enable row level security;
alter table public.ratings enable row level security;

drop policy if exists "Perfiles visibles para usuarios autenticados" on public.profiles;
create policy "Perfiles visibles para usuarios autenticados" on public.profiles
for select to authenticated using (true);

drop policy if exists "Usuarios actualizan su perfil" on public.profiles;
create policy "Usuarios actualizan su perfil" on public.profiles
for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Mascotas visibles para autenticados" on public.pets;
create policy "Mascotas visibles para autenticados" on public.pets
for select to authenticated using (true);

drop policy if exists "Duenos gestionan sus mascotas" on public.pets;
create policy "Duenos gestionan sus mascotas" on public.pets
for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

drop policy if exists "Vacunas visibles para autenticados" on public.vaccines;
create policy "Vacunas visibles para autenticados" on public.vaccines
for select to authenticated using (true);

drop policy if exists "Duenos gestionan vacunas" on public.vaccines;
create policy "Duenos gestionan vacunas" on public.vaccines
for all to authenticated
using (exists (select 1 from public.pets p where p.id = pet_id and p.owner_id = auth.uid()))
with check (exists (select 1 from public.pets p where p.id = pet_id and p.owner_id = auth.uid()));

drop policy if exists "Publicaciones activas visibles" on public.posts;
create policy "Publicaciones activas visibles" on public.posts
for select to authenticated using (status <> 'deleted');

drop policy if exists "Autores gestionan publicaciones" on public.posts;
create policy "Autores gestionan publicaciones" on public.posts
for all to authenticated using (auth.uid() = author_id) with check (auth.uid() = author_id);

drop policy if exists "Reportes de perdida visibles" on public.lost_reports;
create policy "Reportes de perdida visibles" on public.lost_reports
for select to authenticated using (true);

drop policy if exists "Autores gestionan reportes de perdida" on public.lost_reports;
create policy "Autores gestionan reportes de perdida" on public.lost_reports
for all to authenticated
using (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()))
with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()));

drop policy if exists "Adopciones relacionadas visibles" on public.adoptions;
create policy "Adopciones relacionadas visibles" on public.adoptions
for select to authenticated using (auth.uid() in (applicant_id, shelter_id));

drop policy if exists "Usuarios solicitan adopcion" on public.adoptions;
create policy "Usuarios solicitan adopcion" on public.adoptions
for insert to authenticated with check (auth.uid() = applicant_id);

drop policy if exists "Refugios gestionan adopciones" on public.adoptions;
create policy "Refugios gestionan adopciones" on public.adoptions
for update to authenticated using (auth.uid() = shelter_id) with check (auth.uid() = shelter_id);

drop policy if exists "Patrocinios propios visibles" on public.sponsorships;
create policy "Patrocinios propios visibles" on public.sponsorships
for select to authenticated using (auth.uid() = sponsor_id);

drop policy if exists "Usuarios crean patrocinios" on public.sponsorships;
create policy "Usuarios crean patrocinios" on public.sponsorships
for insert to authenticated with check (auth.uid() = sponsor_id and payment_status = 'pending');

drop policy if exists "Avistamientos visibles" on public.sightings;
create policy "Avistamientos visibles" on public.sightings
for select to authenticated using (true);

drop policy if exists "Usuarios reportan avistamientos" on public.sightings;
create policy "Usuarios reportan avistamientos" on public.sightings
for insert to authenticated with check (auth.uid() = reporter_id);

drop policy if exists "Calificaciones visibles" on public.ratings;
create policy "Calificaciones visibles" on public.ratings
for select to authenticated using (true);

drop policy if exists "Usuarios califican a otros" on public.ratings;
create policy "Usuarios califican a otros" on public.ratings
for insert to authenticated with check (auth.uid() = reviewer_id and reviewer_id <> target_id);

insert into storage.buckets (id, name, public)
values
  ('fotos-mascotas', 'fotos-mascotas', true),
  ('fotos-publicaciones', 'fotos-publicaciones', true),
  ('fotos-avistamientos', 'fotos-avistamientos', true),
  ('avatares', 'avatares', true)
on conflict (id) do nothing;

drop policy if exists "Fotos publicas visibles" on storage.objects;
create policy "Fotos publicas visibles" on storage.objects
for select to public using (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

drop policy if exists "Usuarios autenticados suben fotos" on storage.objects;
create policy "Usuarios autenticados suben fotos" on storage.objects
for insert to authenticated with check (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

drop policy if exists "Usuarios autenticados actualizan fotos" on storage.objects;
create policy "Usuarios autenticados actualizan fotos" on storage.objects
for update to authenticated using (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
) with check (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);

drop policy if exists "Usuarios autenticados eliminan fotos" on storage.objects;
create policy "Usuarios autenticados eliminan fotos" on storage.objects
for delete to authenticated using (
  bucket_id in ('fotos-mascotas', 'fotos-publicaciones', 'fotos-avistamientos', 'avatares')
);
