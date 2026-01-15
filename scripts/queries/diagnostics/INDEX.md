# 🔍 Diagnostic Queries Index

Queries SELECT-only para diagnóstico de tickets. Usar con Keyboard Maestro + DataGrip.

## Por Síntoma

| Síntoma | Query File | Parámetros |
|---------|------------|------------|
| Bot no joinea calls | `01-bot-issues.sql` | user_email, date_range |
| Scorecard no calcula | `02-scorecards.sql` | user_email, team_name |
| Labels no aparecen | `03-labels.sql` | conversation_uuid, team_name |
| CRM no sincroniza | `04-crm-auto-select.sql` | org_name, user_email |
| Usuario no ve calls | `05-permissions-dap.sql` | user_email |
| Calls duplicados | `06-duplicates.sql` | user_email, date_range |
| Transcripción mala | `07-transcription.sql` | conversation_uuid |
| Multi-record setup | `08-multi-record.sql` | org_name |
| Team/user lookup | `09-team-user-lookup.sql` | org_name, user_email |
| Snippets/folders | `10-snippets-folders.sql` | user_email, org_name |

## Quick Lookups

```sql
-- Buscar org por nombre
SELECT uuid, name FROM organizations WHERE name ILIKE '%NOMBRE%';

-- Buscar user por email
SELECT uuid, email, first_name, last_name FROM "user" WHERE email ILIKE '%EMAIL%';

-- Buscar team por nombre
SELECT t.uuid, t.name, o.name as org 
FROM teams t JOIN organizations o ON o.uuid = t.organization_uuid 
WHERE t.name ILIKE '%NOMBRE%';
```

## Keyboard Maestro Macros

| Macro Name | Descripción |
|------------|-------------|
| `DG: Run Query` | Ejecuta query del clipboard |
| `DG: Org Lookup` | Prompt org name → busca org |
| `DG: User Lookup` | Prompt email → busca user |
| `DG: Bot Issues` | Prompt email → diagnóstico bot |
| `DG: Scorecard Check` | Prompt user → diagnóstico scorecard |
