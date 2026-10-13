-- Run this in Supabase Dashboard -> SQL Editor.
create table if not exists public.designs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  design_code text not null,
  design_name text not null,
  tags text not null default '',
  design_type text not null default '',
  roll_no text not null default '',
  rack_no text not null default '',
  paper_no text not null default '',
  section_no text not null default '',
  notes text not null default '',
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, design_code)
);
alter table public.designs enable row level security;
drop policy if exists "Users can read own designs" on public.designs;
create policy "Users can read own designs" on public.designs for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Users can insert own designs" on public.designs;
create policy "Users can insert own designs" on public.designs for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can update own designs" on public.designs;
create policy "Users can update own designs" on public.designs for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users can delete own designs" on public.designs;
create policy "Users can delete own designs" on public.designs for delete to authenticated using (auth.uid() = user_id);

-- Private image bucket. Use authenticated-only access.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('design-images', 'design-images', false, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
drop policy if exists "Users can view own design images" on storage.objects;
create policy "Users can view own design images" on storage.objects for select to authenticated
using (bucket_id = 'design-images' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Users can upload own design images" on storage.objects;
create policy "Users can upload own design images" on storage.objects for insert to authenticated
with check (bucket_id = 'design-images' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Users can update own design images" on storage.objects;
create policy "Users can update own design images" on storage.objects for update to authenticated
using (bucket_id = 'design-images' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'design-images' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Users can delete own design images" on storage.objects;
create policy "Users can delete own design images" on storage.objects for delete to authenticated
using (bucket_id = 'design-images' and (storage.foldername(name))[1] = auth.uid()::text);
