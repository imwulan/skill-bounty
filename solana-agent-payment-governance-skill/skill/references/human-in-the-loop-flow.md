# Human-in-the-Loop Approval Flow

How to design the moment a flagged agent payment is handed to a human —
the countdown, the kill switch, and the override.

## Why a countdown, not an indefinite hold

An indefinite "waiting for approval" state quietly breaks the agent's
workflow (it's stuck) and gives no default outcome if nobody's watching.
A visible countdown forces an explicit default:

- **No response when countdown expires → auto-block.** Silence must resolve
  to the safe outcome, never to silent approval. This is the single most
  important design rule in this flow.
- The countdown length should scale with risk tier — a `critical` flag might
  get a short window (e.g. 8–15s) specifically because it's already strongly
  suspected to be wrong; a `medium` flag can afford a longer window.

## What the approval screen must show

At minimum, surface:
1. **Requesting agent** — which agent/process is asking (name/ID), so a human
   managing multiple agents knows which one to investigate
2. **Requested action** in plain language — what's being sent, how much, to where
3. **Stated purpose** — whatever justification the agent itself provided
4. **Why it was flagged** — the specific policy violations (see
   `policy-and-risk-scoring.md` flags), not just a score
5. **Risk level + confidence**, visually distinct (e.g. risk as a labeled bar,
   confidence as a percentage) so a human can distinguish "high risk, certain"
   from "high risk, uncertain"
6. **Countdown to auto-block**, visibly ticking down
7. Two clear actions:
   - **Kill process** — the safe default action; stops the requesting
     agent/process, not just this one transaction
   - **Approve anyway — I accept the risk** — explicit, worded as accepting
     responsibility, not a neutral "approve" button

## Kill switch scope

Distinguish two levels of "stop":
- **Block this transaction** — the immediate payment doesn't go through
- **Kill process / panic** — halts the *agent* itself (e.g. revokes its
  active session, disables its ability to submit further requests until a
  human re-enables it)

A system that can only block individual transactions but not halt a
misbehaving agent's process leaves the door open for the same agent to retry
or escalate immediately after. The panic/kill-switch control should be reachable
both from a specific flagged-transaction screen and as a standalone control
(e.g. a dedicated "Panic" section) for when an operator notices something is
wrong before any specific transaction gets flagged.

## Audit trail

Every decision — auto-blocked, approved-anyway, or killed — should be logged
with: timestamp, agent ID, requested action, all flags shown, risk/confidence
values, who acted (or "auto" if the countdown expired), and the outcome. This
is what makes the system reviewable after the fact and is what a "Threat
intel" or "Audit log" view in the product surface should be built from.
