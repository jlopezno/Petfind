begin;

create table if not exists public.fcm_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  token text not null unique,
  platform text not null default 'android',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_fcm_tokens_user_id
on public.fcm_tokens(user_id);

alter table public.fcm_tokens enable row level security;

drop policy if exists "Usuarios leen sus tokens FCM" on public.fcm_tokens;
create policy "Usuarios leen sus tokens FCM" on public.fcm_tokens
for select to authenticated
using (user_id = auth.uid());

drop policy if exists "Usuarios registran sus tokens FCM" on public.fcm_tokens;
create policy "Usuarios registran sus tokens FCM" on public.fcm_tokens
for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "Usuarios actualizan sus tokens FCM" on public.fcm_tokens;
create policy "Usuarios actualizan sus tokens FCM" on public.fcm_tokens
for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Usuarios eliminan sus tokens FCM" on public.fcm_tokens;
create policy "Usuarios eliminan sus tokens FCM" on public.fcm_tokens
for delete to authenticated
using (user_id = auth.uid());

commit;
