# solana-agent-payment-governance-skill

A Claude Code / Codex skill for building and extending **AI agent payment
governance systems** on Solana — the layer that sits between an autonomous
agent deciding "I should pay this" and the transaction actually being signed
on-chain.

## Problem this solves

As AI agents increasingly hold and spend funds on their own (autonomous
trading bots, yield-rebalancing agents, agent-to-agent payments), the
ecosystem has plenty of tooling for *security* (is this transaction
malicious, is this a scam a human is being tricked into signing) but very
little for *governance*: is this transaction within the scope a human
authorized their own agent to operate in? Those are different questions with
different threat models — security defends against an outside attacker;
governance constrains an agent that's acting exactly as designed but has
drifted, encountered bad data, or simply scaled up its own activity beyond
what a human expects.

This skill packages that governance pattern as a reusable knowledge module:
a policy engine design (behavioral baselines, counterparty trust, program
novelty), a risk + confidence scoring shape, a human-in-the-loop approval
flow with a countdown that defaults to safe (auto-block) rather than silent
pass-through, a kill-switch pattern for halting a misbehaving agent's
process entirely, and the on-chain data plumbing (RPC + Supabase) needed to
support it.

It's grounded in real implementation experience building **Sentinel Switch**,
an "AI Payment Governance" concept with a working real-time connection to live
Solana wallets. The policy engine itself — behavioral baselines, risk +
confidence scoring, the human-in-the-loop countdown/kill-switch flow, the
plain-language flag breakdown — is currently a demo/simulation layer on top
of that real connection, not yet a production-validated scoring model. This
skill packages that design as a blueprint other builders can implement against
real agent history, while being upfront about what's live vs. simulated today.

**Implementation status:** the real-time wallet connection layer (Solana RPC,
live balance/transaction reads) is implemented and working. The policy/risk
scoring engine (baseline thresholds, behavior confidence, flag generation)
exists as a working demo with configured/static logic — it demonstrates the
intended design but doesn't yet learn baselines from accumulated real agent
history. This skill documents the target architecture, including where the
current demo's scoring is a reasonable starting heuristic rather than a
fully data-driven system yet.

## Structure

```
solana-agent-payment-governance-skill/
├── skill/
│   ├── SKILL.md                          # entry point, progressive routing
│   └── references/
│       ├── policy-and-risk-scoring.md    # baselines, deviation flags, scoring shape
│       ├── human-in-the-loop-flow.md     # countdown, approval UX, kill switch
│       ├── onchain-data-pipeline.md      # RPC + Supabase data layer
│       └── integration-checklist.md      # shipping into an agent framework/backend
├── install.sh
└── README.md
```

## Install

```bash
git clone https://github.com/<your-username>/solana-agent-payment-governance-skill.git
cd solana-agent-payment-governance-skill
./install.sh /path/to/your/project/.claude/skills/solana-agent-payment-governance-skill
```

Or submodule it directly into the Solana AI Kit's skill hub:

```bash
git submodule add https://github.com/<your-username>/solana-agent-payment-governance-skill.git skills/solana-agent-payment-governance-skill
```

## License

MIT
