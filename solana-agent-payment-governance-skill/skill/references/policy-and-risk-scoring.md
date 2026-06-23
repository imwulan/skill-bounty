# Policy Engine and Risk Scoring

How to design the engine that evaluates an AI agent's payment request against
policy *before* it's signed — the core of agent payment governance.

## Implementation status note

The scoring shape and baseline logic below is a **design pattern**, not a
description of a production-validated model. In the reference implementation
this skill draws from, the real/working piece is the live, real-time
connection to an actual Solana wallet — the baseline computation, risk
scoring, and confidence numbers are currently a demo/simulation layer on top
of that real connection, not yet derived from real accumulated agent history.
Treat everything below as the target architecture to build toward, and call
out clearly in your own README/docs which parts of your implementation are
live vs. simulated — judges and other builders will trust a clearly-labeled
demo far more than an unlabeled one that turns out to be hardcoded.

## The governance question vs. the security question

| | Security question | Governance question |
|---|---|---|
| Who's asking | An unknown counterparty / dApp the user interacts with | The user's own agent, acting on its own |
| What's being checked | Is this transaction malicious or a known scam pattern | Does this fit what the human authorized this agent to do |
| Failure mode | User tricked into signing something harmful | Agent drifts out of its intended scope (bug, bad data, scope creep, compromised agent) |

Both matter, but this skill is specifically about the governance question —
constraining your *own* automated agents, not just defending against outside
attackers.

## Policy dimensions to evaluate

For every agent-initiated payment request, evaluate against:

1. **Spending baseline** — compare the requested amount against the agent's
   historical typical range, not just a single hardcoded cap. Example flag
   format: "Transfer of 3.2 SOL exceeds baseline (threshold: 1 SOL)."
2. **Counterparty familiarity** — has this destination address been
   interacted with before, by this agent specifically (and optionally, by the
   wallet/account more broadly)? No prior history is itself a risk signal,
   not proof of malice.
3. **Program/instruction novelty** — is the agent invoking a program it
   hasn't used before? Unknown or rarely-seen programs raise risk even if the
   transaction is otherwise well-formed.
4. **Stated purpose vs. actual structure** — if the agent provides a reason
   for the action (e.g. "autonomous yield rebalancing — LP position exit"),
   sanity-check that the transaction's actual structure plausibly matches the
   stated purpose. A mismatch (e.g. claimed LP exit that actually sends funds
   to an unrelated wallet, not a known pool program) is a strong flag.

## Scoring shape

Produce a structured result, not just a single number:

```json
{
  "risk_level": "low | medium | high | critical",
  "risk_score": 90,
  "behavior_confidence": 92,
  "flags": [
    "Transfer of 3.200 SOL exceeds your normal baseline (threshold: 1 SOL)",
    "Destination wallet has no prior interaction history",
    "Unknown program(s) invoked"
  ]
}
```

- `risk_score` (0-100): how risky the action itself looks
- `behavior_confidence` (0-100): how confident the system is in its own
  assessment, given available history — low confidence with a borderline
  score should be communicated differently than high confidence with the same score
- `flags`: the specific, human-readable reasons — this is what the human
  approver actually reads in the seconds they have to decide

**Implementation note:** the structure above is the target shape to build
toward. A reasonable first implementation can start with static/configured
thresholds and a simple weighted-flag-count formula for `risk_score` and
`behavior_confidence` (e.g. each matched flag adds points, confidence scales
with how much history exists for that agent) — this is a legitimate starting
point, not a shortcut to hide. Plan to evolve it toward baselines computed
from actual observed agent history (see "Calibrating thresholds" below) once
enough real transaction data exists; don't present a static-threshold
implementation as if it's already learning from behavior, since that's a
meaningfully different (and not-yet-built) capability.

## Calibrating thresholds

- Start baselines from the agent's actual observed history where possible,
  not arbitrary numbers — a fixed "1 SOL" cap is a reasonable bootstrap default
  before enough history exists, but should ideally tighten/loosen per agent
  once real behavior data accumulates.
- Track false-block rate (legitimate agent actions blocked) just as closely as
  missed-risk rate — an agent governance system that blocks too aggressively
  will get its overrides rubber-stamped by an annoyed operator, which defeats
  the purpose.
