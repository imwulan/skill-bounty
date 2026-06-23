# On-Chain Data Pipeline (Solana RPC + Supabase)

How to wire up the data layer that feeds the policy engine, based on a working
RPC + Supabase architecture for AI agent payment governance.

## Components

1. **Solana RPC connection** — for fetching transaction data and running
   `simulateTransaction` before an agent's payment is signed (this is what
   lets you compute post-balances and validate structure without actually
   submitting the transaction).
2. **Instruction decoder** — maps `program_id` + instruction discriminator to
   a human-readable action. Maintain a lookup table for common programs
   (System, Token, Token-2022, Associated Token Account, major DEXs) and treat
   unrecognized programs as a risk signal in themselves (see
   `policy-and-risk-scoring.md`).
3. **Supabase (Postgres)** — persistence layer for:
   - **Per-agent behavioral baseline** (typical transfer size range, typical
     counterparties, typical programs invoked) — this is what spending-baseline
     and counterparty-familiarity checks are computed against
   - **Decision audit log** (flagged request + policy result + human or auto
     outcome) for the audit-log/threat-intel views
   - **Agent registry** (agent ID, status: active/killed, current session/scope)

## Suggested schema sketch

```sql
-- agent_baseline: rolling behavioral profile per agent
create table agent_baseline (
  agent_id text primary key,
  typical_transfer_lamports_p95 bigint not null default 0,
  known_counterparties jsonb not null default '[]',
  known_programs jsonb not null default '[]',
  status text not null default 'active', -- active | killed | suspended
  updated_at timestamptz not null default now()
);

-- payment_decision_log: every evaluated agent payment request
create table payment_decision_log (
  id uuid primary key default gen_random_uuid(),
  agent_id text not null,
  requested_action jsonb not null,       -- decoded instruction(s) + amount + destination
  stated_purpose text,
  risk_level text not null,
  risk_score integer not null,
  behavior_confidence integer not null,
  flags jsonb not null default '[]',
  decision text not null,                -- approved | approved_with_risk_accepted | auto_blocked | killed
  decided_by text,                       -- "auto" or a human operator identifier
  created_at timestamptz not null default now()
);
```

## Pre-sign interception is the whole point

The governance check only has value if it happens **before** the agent's
transaction is signed and submitted — once it's on-chain, the decision window
is gone. The integration point is typically the agent's own
sign/execute-payment call, intercepted and routed through the policy engine
first, with the agent's call only proceeding if the policy engine returns
"approved" (or a human explicitly accepts the risk within the countdown).

## Rate limits and RPC reliability

- Use a dedicated/paid RPC provider for production — public RPC endpoints
  rate-limit aggressively, and a governance system that can't reach RPC to
  validate a transaction should fail toward blocking, not toward letting the
  agent's payment through unchecked.
- Add retry/backoff and a circuit breaker on the RPC layer specifically because
  agents may retry rapidly on failure — a governance system that fails open
  under RPC pressure is a bigger risk than one that's briefly unavailable.

