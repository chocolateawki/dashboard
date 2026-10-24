-- Ejecutar en Supabase > SQL Editor. Acceso compartido SOLO entre usuarios invitados.
-- Se recomienda desactivar 'Allow new users to sign up' y crear usuarios invitados desde Authentication.
create table if not exists public.revops_cortes (
  id uuid primary key default gen_random_uuid(),
  fecha date not null unique,
  empresas integer check (empresas >= 0),
  contactos integer check (contactos >= 0),
  contactos_contactados integer check (contactos_contactados >= 0),
  prioritarios integer check (prioritarios >= 0),
  prioritarios_contactados integer check (prioritarios_contactados >= 0),
  secuencias_evaluadas integer check (secuencias_evaluadas >= 0),
  secuencias_completas integer check (secuencias_completas >= 0),
  destinatarios_unicos integer check (destinatarios_unicos >= 0),
  respuestas_humanas integer check (respuestas_humanas >= 0),
  respuestas_positivas integer check (respuestas_positivas >= 0),
  reuniones_realizadas integer check (reuniones_realizadas >= 0),
  sql_validos integer check (sql_validos >= 0),
  oportunidades integer check (oportunidades >= 0),
  empresas_a_sin_contacto integer check (empresas_a_sin_contacto >= 0),
  crm_auditados integer check (crm_auditados >= 0),
  crm_coherentes integer check (crm_coherentes >= 0),
  notas text,
  actualizado_por uuid references auth.users(id),
  actualizado_en timestamptz not null default now(),
  constraint cobertura_check check (contactos_contactados is null or contactos is null or contactos_contactados <= contactos),
  constraint prioridades_check check (prioritarios_contactados is null or prioritarios is null or prioritarios_contactados <= prioritarios),
  constraint secuencias_check check (secuencias_completas is null or secuencias_evaluadas is null or secuencias_completas <= secuencias_evaluadas),
  constraint respuesta_check check (respuestas_humanas is null or destinatarios_unicos is null or respuestas_humanas <= destinatarios_unicos),
  constraint positivo_check check (respuestas_positivas is null or respuestas_humanas is null or respuestas_positivas <= respuestas_humanas),
  constraint crm_check check (crm_coherentes is null or crm_auditados is null or crm_coherentes <= crm_auditados)
);
create index if not exists revops_cortes_fecha_idx on public.revops_cortes(fecha desc);
alter table public.revops_cortes enable row level security;
-- Lectura y edición colaborativa para usuarios autenticados (sin acceso público).
drop policy if exists "lectura_equipo" on public.revops_cortes;
create policy "lectura_equipo" on public.revops_cortes for select to authenticated using (true);
drop policy if exists "crear_equipo" on public.revops_cortes;
create policy "crear_equipo" on public.revops_cortes for insert to authenticated with check (actualizado_por = (select auth.uid()));
drop policy if exists "editar_equipo" on public.revops_cortes;
create policy "editar_equipo" on public.revops_cortes for update to authenticated using (true) with check (actualizado_por = (select auth.uid()));
-- No existe política de DELETE: no se permiten eliminaciones desde la aplicación.
