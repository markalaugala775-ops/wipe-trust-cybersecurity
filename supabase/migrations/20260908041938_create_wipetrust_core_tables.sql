/*
# Create WipeTrust core tables

1. New Tables
- `wipetrust_devices` stores registered IT assets, risk assessments, wiping progress, verification results, and lifecycle status.
- `wipetrust_certificates` stores generated wipe certificates and their integrity hashes.
- `wipetrust_audit_events` stores the tamper-evident audit chain for lifecycle actions.

2. Security
- Row Level Security is enabled on all WipeTrust tables.
- This prototype is a shared, no-sign-in workspace, so anon and authenticated roles receive CRUD access.

3. Important Notes
- The browser demo performs simulated wiping only; it never accesses or erases local files.
- Hashes and audit fields are persisted so the demo remains consistent across reloads and can be verified publicly.
*/

CREATE TABLE IF NOT EXISTS public.wipetrust_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  device_type text NOT NULL,
  manufacturer text NOT NULL,
  model text NOT NULL,
  serial_number text NOT NULL UNIQUE,
  capacity text NOT NULL,
  storage_technology text NOT NULL,
  organization text NOT NULL,
  asset_id text NOT NULL UNIQUE,
  risk_level text NOT NULL DEFAULT 'Medium',
  recommendation text NOT NULL DEFAULT 'Standard multi-pass wipe',
  risk_reason text NOT NULL DEFAULT '',
  additional_verification boolean NOT NULL DEFAULT false,
  status text NOT NULL DEFAULT 'Registered',
  wipe_method text,
  wipe_progress integer NOT NULL DEFAULT 0,
  verification_status text,
  verification_score integer,
  verification_checks integer,
  verification_timestamp timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.wipetrust_certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id uuid NOT NULL REFERENCES public.wipetrust_devices(id) ON DELETE CASCADE,
  certificate_id text NOT NULL UNIQUE,
  certificate_hash text NOT NULL,
  issued_at timestamptz NOT NULL DEFAULT now(),
  recycling_eligible boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS public.wipetrust_audit_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id text NOT NULL UNIQUE,
  device_id uuid REFERENCES public.wipetrust_devices(id) ON DELETE SET NULL,
  action text NOT NULL,
  actor text NOT NULL DEFAULT 'Alex Morgan',
  previous_hash text NOT NULL,
  current_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.wipetrust_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wipetrust_certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wipetrust_audit_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Shared users can view devices" ON public.wipetrust_devices;
CREATE POLICY "Shared users can view devices" ON public.wipetrust_devices FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Shared users can insert devices" ON public.wipetrust_devices;
CREATE POLICY "Shared users can insert devices" ON public.wipetrust_devices FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Shared users can update devices" ON public.wipetrust_devices;
CREATE POLICY "Shared users can update devices" ON public.wipetrust_devices FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Shared users can delete devices" ON public.wipetrust_devices;
CREATE POLICY "Shared users can delete devices" ON public.wipetrust_devices FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Shared users can view certificates" ON public.wipetrust_certificates;
CREATE POLICY "Shared users can view certificates" ON public.wipetrust_certificates FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Shared users can insert certificates" ON public.wipetrust_certificates;
CREATE POLICY "Shared users can insert certificates" ON public.wipetrust_certificates FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Shared users can update certificates" ON public.wipetrust_certificates;
CREATE POLICY "Shared users can update certificates" ON public.wipetrust_certificates FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Shared users can delete certificates" ON public.wipetrust_certificates;
CREATE POLICY "Shared users can delete certificates" ON public.wipetrust_certificates FOR DELETE TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Shared users can view audit events" ON public.wipetrust_audit_events;
CREATE POLICY "Shared users can view audit events" ON public.wipetrust_audit_events FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Shared users can insert audit events" ON public.wipetrust_audit_events;
CREATE POLICY "Shared users can insert audit events" ON public.wipetrust_audit_events FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Shared users can update audit events" ON public.wipetrust_audit_events;
CREATE POLICY "Shared users can update audit events" ON public.wipetrust_audit_events FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Shared users can delete audit events" ON public.wipetrust_audit_events;
CREATE POLICY "Shared users can delete audit events" ON public.wipetrust_audit_events FOR DELETE TO anon, authenticated USING (true);

CREATE INDEX IF NOT EXISTS wipetrust_devices_status_idx ON public.wipetrust_devices(status);
CREATE INDEX IF NOT EXISTS wipetrust_certificates_certificate_id_idx ON public.wipetrust_certificates(certificate_id);
CREATE INDEX IF NOT EXISTS wipetrust_audit_events_created_at_idx ON public.wipetrust_audit_events(created_at);
