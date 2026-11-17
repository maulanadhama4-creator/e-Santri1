-- Skema e-Santri (sudah diterapkan ke proyek Supabase). Tidak berisi kata sandi.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nama text not null check (char_length(btrim(nama)) >= 3),
  email text not null,
  instansi text not null check (char_length(btrim(instansi)) >= 1),
  role text not null default 'santri' check (role in ('santri','developer')),
  created_at timestamptz not null default now()
);
create unique index profiles_nama_uniq on public.profiles (lower(btrim(nama)));
alter table public.profiles enable row level security;

create or replace function public.is_developer() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = (select auth.uid()) and role = 'developer')
$$;

create policy "baca profil sendiri atau developer" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or public.is_developer());

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, nama, email, instansi)
  values (new.id, btrim(coalesce(new.raw_user_meta_data->>'nama','')), new.email,
          btrim(coalesce(new.raw_user_meta_data->>'instansi','')));
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users for each row execute function public.handle_new_user();

create or replace function public.nama_tersedia(p_nama text) returns boolean
language sql stable security definer set search_path = '' as $$
  select not exists (select 1 from public.profiles where lower(btrim(nama)) = lower(btrim(p_nama)))
$$;

create or replace function public.email_by_nama(p_nama text) returns text
language sql stable security definer set search_path = '' as $$
  select email from public.profiles where lower(btrim(nama)) = lower(btrim(p_nama)) limit 1
$$;

revoke all on function public.is_developer() from public, anon;
grant execute on function public.is_developer() to authenticated;
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.email_by_nama(text) from public, anon, authenticated;
grant execute on function public.email_by_nama(text) to service_role;
revoke all on function public.nama_tersedia(text) from public;
grant execute on function public.nama_tersedia(text) to anon, authenticated;
