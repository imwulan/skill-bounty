---
name: solana-ai-agent-payment-governance-skill
description: >
  Use this skill whenever a builder is working on governance, policy enforcement,
  or risk controls for AI agents that hold or spend funds autonomously on Solana.
  Triggers include: "AI agent wallet", "autonomous payment", "agent spending limit",
  "agentic payment risk", "kill switch for AI agent", "agent policy engine",
  "human-in-the-loop approval", "counterparty trust score", "behavioral baseline
  wallet", or any request to build/extend a system that intercepts and evaluates
  payments an AI agent is about to make before they're signed. Routes to focused
  sub-skills depending on whether the task is about policy/risk logic, the
  human-in-the-loop approval flow, or the on-chain data plumbing.
license: MIT
---

# Solana AI Agent Payment Governance Skill

A skill for building and extending **AI agent payment governance systems** on
Solana: the layer that sits between an autonomous agent deciding "I should pay
this" and the transaction actually being signed and submitted on-chain.

As AI agents increasingly hold and spend funds on their own (autonomous trading
bots, yield-rebalancing agents, agent-to-agent payments), the open question
shifts from "is this transaction malicious" to **"does this agent's behavior
fit the policy a human set for it?"** This skill packages that governance
pattern: behavioral baselines, counterparty trust, risk scoring, a
human-in-the-loop override window, and an audit trail — distinct from
traditional wallet-drainer/phishing protection, which assumes a human is the
one signing.

This skill is informed by real-world implementation experience building
**Sentinel Switch** ("AI Payment Governance"), a system with a working
real-time connection to live Solana wallets, paired with a policy-engine UX
(behavioral baselines, spending limits, risk/confidence scoring, countdown
approval, kill switch) currently implemented as a demo/simulation layer on
top of that real connection. The patterns below describe the target design —
they're a blueprint for what the policy engine should become, not a claim
that the scoring logic is already production-validated.

## When to use this skill

Use this skill when the task involves any of:
- Intercepting an AI agent's payment/transfer request before it's signed, to
  evaluate it against a policy (not just checking if it's outright malicious)
- Defining a **behavioral baseline** for an agent (e.g. typical transfer size,
  typical counterparties, typical programs invoked) and flagging deviations
- Scoring agent-initiated transactions on risk + confidence, with reasons
- Designing a **human-in-the-loop approval flow** with a countdown — i.e.
  default-safe behavior (auto-block) if no human responds in time
- A "panic" / kill-switch control to halt an agent's process entirely
- Counterparty trust scoring — has this destination wallet been interacted
  with before, by this agent or otherwise
- Audit logging of agent payment decisions for after-the-fact review

Do NOT use this skill for: protecting a human user's wallet from phishing/
drainer scams where the human is the one signing (that's a different problem —
the threat model here is "is my own agent about to do something out of
policy," not "is someone else tricking me"). Also not for smart contract
security audits (see `solana-auditor-skill`) or CLMM/DeFi position management
(see `position-manager-skill`).

## How this skill is organized (progressive loading)

Load only the files relevant to the current task — don't load everything upfront.

| File | Load when... |
|---|---|
| `references/policy-and-risk-scoring.md` | Designing or reviewing the policy engine: baselines, deviation flags, risk/confidence scoring |
| `references/human-in-the-loop-flow.md` | Building the approval UX: countdown, kill-switch, approve-anyway override |
| `references/onchain-data-pipeline.md` | Wiring up Solana RPC, transaction parsing, and persistence (e.g. Supabase) to feed the policy engine |
| `references/integration-checklist.md` | Shipping/integrating governance into an agent framework, wallet, or backend |

## Core principles this skill encodes

1. **Policy fit, not just maliciousness.** A transaction can be entirely
   legitimate on-chain (valid signatures, known program, no exploit) and still
   be *out of policy* — e.g. an agent transferring far more than its usual
   range, or to a counterparty it's never dealt with. The governance question
   is "does this fit what the human authorized this agent to do," separate
   from "is this an attack."
2. **Default-safe under uncertainty, with a human escape hatch.** When risk is
   high, the system should default toward blocking — but always give the human
   operator a visible, time-boxed window to either approve anyway (accepting
   explicit risk) or kill the process outright. Silence should resolve to the
   safe outcome (auto-block), never to silent approval.
3. **Behavioral baseline over static rules.** Thresholds (like a spending cap)
   are necessary but not sufficient — the system should also learn/track each
   agent's typical behavior (transfer sizes, counterparties, programs used)
   so deviations are meaningful relative to that agent's own history, not just
   a single global number.
4. **Explainability drives trust.** Every flag must show *why* — the specific
   policy violations and risk factors found (e.g. "exceeds baseline," "no prior
   interaction," "unknown program") — not just a score. A human asked to decide
   in seconds needs the reasons, not just a number.
5. **A kill switch is a first-class feature, not an afterthought.** Beyond
   blocking a single transaction, the system needs a way to halt the
   *requesting agent/process* entirely when something looks systemically wrong.

See the reference files for the detailed how-to on each of these.
