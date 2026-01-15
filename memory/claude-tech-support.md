# Claude Tech Support - Knowledge Base

## Proyecto
`~/Developer/claude-tech-support` - Sistema de triage agentic para Attention.io

## Qué hace
- **Triage automatizado** de tickets de Linear
- **Routing inteligente** basado en matriz SME
- **Diagnóstico con playbooks** (no solo routing, sino root cause analysis)
- **Integración Slack** - comentarios sincronizan con threads

## Arquitectura
```
claude-tech-support/
├── instructions.md          # Source of Truth - reglas de triage
├── attention-sme-matrix.csv # Área → SME mapping
├── db-tables/               # Schema de DB (14 tablas)
│   ├── conversations.md
│   ├── calendar_events.md
│   ├── scorecards.md
│   └── ...
└── playbooks/               # Guías de diagnóstico (16 playbooks)
    ├── INDEX.md
    ├── missing-call-recording.md
    ├── scorecards.md
    ├── auto-select.md
    └── ...
```

## Flujo de trabajo
1. Query tickets en Triage (últimos ~14 días)
2. Analizar cada ticket (comments, actividad, topic)
3. Presentar tabla de propuestas con confidence level
4. **≥90% confidence** → auto-ejecutar
5. **<90% confidence** → pedir confirmación

## SMEs clave (Yeiner's areas)
- **CRM - Multiple Records**: Yeiner (primary), Brayan Restrepo (backup)
- **SFDC**: Brayan Restrepo, Juan Castro, Oscar
- **Hubspot**: Brayan Restrepo, Juan Castro

## Playbooks principales
| Issue | Playbook | Key Checks |
|-------|----------|------------|
| Bot didn't join | `missing-call-recording.md` | `joinable_final`, calendar_events |
| Scorecard issues | `scorecards.md` | `auto_calculate_scorecards` |
| CRM not syncing | `auto-select.md` | `auto_select_opportunities` |
| Labels missing | `missing-labels-tags.md` | Label category → team |
| Permissions | `dap.md`, `access-conversations-permissions.md` | team_members, DAP |

## Comandos útiles
```bash
# Morning triage
> check triage please

# Review my tickets
> go through tickets assigned to me, oldest first

# Batch processing
> handle all remaining triage tickets
```

## Clientes high-profile
- Elise
- Dandy
- Engine
- BambooHR
- Slice

## Reglas importantes
- **Nudge policy**: Si >24h sin respuesta, agregar nudge con contexto específico
- **Reassessment**: Si usuario tarda >10 min en responder, re-query antes de ejecutar
- **Stale tickets**: >3 semanas sin engagement → flag para Yeiner
- **OCR**: Siempre extraer screenshots para contexto completo

## Linear MCP
Configurado en `~/.claude/settings.json` con `@anthropic/linear-mcp-server`
