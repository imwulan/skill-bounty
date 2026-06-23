# Integration Checklist

Use this when shipping AI agent payment governance into an agent framework,
backend, or wallet-adjacent product.

## Before launch

- [ ] Pre-sign interception point confirmed working — the agent's
      payment/transfer call is routed through the policy engine *before* the
      transaction is signed, not after
- [ ] Decoder covers at minimum: System Program, Token Program, Token-2022,
      Associated Token Account Program, and the top DEX/protocol programs your
      agents actually interact with
- [ ] Per-agent baseline tracking in place (not just one global spending cap)
      so flags are calibrated to each agent's own typical behavior
- [ ] Risk + confidence both computed and both surfaced — not collapsed into
      a single number
- [ ] Countdown auto-block path tested: confirm that an unattended countdown
      genuinely resolves to "blocked," not to silent pass-through
- [ ] Kill-switch reachable both from a flagged-transaction screen and as a
      standalone "panic" control independent of any specific transaction
- [ ] Every flag shown to the human includes a plain-language reason, not
      just a tier label or score
- [ ] Audit log captures every decision (auto-blocked, approved, approved-
      with-risk, killed) with who/what decided and why

## Privacy and trust considerations

- Be explicit about what data is logged for audit purposes (decoded
  instructions, amounts, counterparties — never private keys)
- If the policy engine uses an LLM for purpose/structure sanity-checking,
  document what's sent to a third-party API and its retention policy
- Consider letting operators export the audit log, since "why did my agent
  almost do that" is exactly the kind of question a builder will want to
  answer outside the product itself

## Metrics to track post-launch

- **False-block rate** (legitimate agent action blocked) — drives whether
  operators trust the system or start rubber-stamping every "approve anyway"
- **Missed-risk rate** (an out-of-policy action that should have been flagged
  but wasn't) — drives actual loss exposure
- **Time-to-decision** during the countdown window — if operators consistently
  need more time than the window allows, the countdown length needs revisiting
  per risk tier, not just shortened universally
- **Kill-switch usage** — frequency and which agents trigger it, since a
  pattern of repeated kills on one agent is itself a signal worth investigating

