> **Purpose**: Single source of truth for **what rules exist**, **what’s implemented**, **what remains to be learned**, and **how to verify exact matches**.
> **Owner**: AGENT **<agent_slug/>** · **Timezone**: UTC · **Update cadence**: prepend entries, timestamped ISO‑8601 with `Z`.

---

## 0) Legend

* **Status**: `PROPOSED` | `IN_PROGRESS` | `IMPLEMENTED` | `VERIFIED_PUBLIC` | `VERIFIED_PRIVATE` | `REVERTED` | `DEFERRED`
* **Priority**: `P0 (must match)` · `P1 (likely)` · `P2 (nice to have)`
* **Source**: `PRD` | `INTERVIEWS` | `EDA`
* **Tags**: `per-diem`, `mileage`, `receipts`, `efficiency`, `days-quirk`, `normalization`, `caps`, `ordering`, `diagnostics`

**Definition of Done (per feature)**

* [ ] Impl complete (deterministic)
* [ ] Parameters fixed (documented)
* [ ] Unit tests added (edge & threshold)
* [ ] Eval: public cases delta \~ 0 for target slice
* [ ] Residual/cent diagnostics pass
* [ ] Docs updated (this file + lessons\_learned.md)

---

## 1) Quick Index (status at a glance)

| ID      | Feature                                            | Status   | Priority | Tags                 |
| ------- | -------------------------------------------------- | -------- | -------- | -------------------- |
| PD‑001  | Per‑diem lookup by `days`                          | PROPOSED | P0       | per-diem             |
| PD‑005  | Day‑5 additive bonus                               | PROPOSED | P0       | per-diem, days-quirk |
| PD‑008A | Day‑8 specific additive bonus (pattern A)          | PROPOSED | P0       | per-diem, days-quirk |
| PD‑008B | Day‑8 high‑receipt path: Tier‑3 = **5%**           | PROPOSED | P0       | receipts, days-quirk |
| MI‑100  | Mileage tiers (piecewise) + flattening             | PROPOSED | P0       | mileage              |
| EF‑150  | Efficiency penalty by miles/day (base −60 scaling) | PROPOSED | P0       | efficiency           |
| RC‑200  | Receipts tiers (thresholds & rates)                | PROPOSED | P0       | receipts             |
| RC‑210  | Dynamic low‑value receipts cap                     | PROPOSED | P1       | receipts             |
| NR‑300  | **.49/.99** cents normalization (placement)        | PROPOSED | P0       | normalization        |
| GL‑400  | Global min/max payout (if present)                 | PROPOSED | P2       | caps                 |
| OR‑900  | Rule ordering/precedence (stack order)             | PROPOSED | P0       | ordering             |
| TS‑001  | Cents histogram spikes at .49/.99                  | PROPOSED | P0       | diagnostics          |
| TS‑002  | Residuals vs days: fix needles at 5 & 8            | PROPOSED | P0       | diagnostics          |
| TS‑003  | Residuals vs miles: slope breaks at cutpoints      | PROPOSED | P0       | diagnostics          |
| TS‑004  | Residuals vs miles/day: kink at efficiency thresh  | PROPOSED | P0       | diagnostics          |

> Add rows as you discover more micro‑rules; keep IDs stable for commit history.

---

## 2) Feature Cards (one per rule)

### PD‑001 — Per‑diem schedule (lookup by `trip_duration_days`)

* **Status**: PROPOSED · **Priority**: P0 · **Source**: PRD, INTERVIEWS · **Tags**: per-diem
* **Intent**: Discrete per‑diem amounts per day count; not necessarily linear.
* **Parameters to learn**: Table values for `days ∈ [1..N]` (expect blips around 5 and 8).
* **Guards**: Applies to all trips (base component).
* **Precedence**: Compute before day‑quirk bonuses and normalization.
* **Tests**:

  * Slice low‑miles & low‑receipts trips; recovered base should explain most variance.
  * Check residual needles at 5/8 disappear once PD‑005/PD‑008\* applied.
* **DoD**:

  * [ ] Table encoded with fixed seed/constant file.
  * [ ] Unit test asserts exact lookup values on curated cases.
  * [ ] Public cases residual reduction logged.

---

### PD‑005 — Day‑5 additive bonus

* **Status**: PROPOSED · **Priority**: P0 · **Source**: INTERVIEWS, EDA · **Tags**: per-diem, days-quirk
* **Intent**: Deterministic additive bump for 5‑day trips.
* **Parameters to learn**: Bonus amount (flat vs % of base).
* **Guards**: `days == 5` (consider receipts/miles conditions if EDA reveals).
* **Precedence**: After base components (per‑diem/mileage/receipts) but before efficiency penalty; confirm during fit.
* **Tests**:

  * 5‑day cluster should align; non‑5‑day unaffected.
* **DoD**:

  * [ ] Implement guarded addend.
  * [ ] Threshold/amount locked and documented.

---

### PD‑008A — Day‑8 additive bonus (pattern A)

* **Status**: PROPOSED · **Priority**: P0 · **Source**: INTERVIEWS · **Tags**: per-diem, days-quirk
* **Intent**: Specific additive bonus for a subset of 8‑day trips.
* **Parameters to learn**: Trigger condition (likely pattern of `miles/day` and `receipts/day`), bonus value.
* **Mutual exclusivity**: If PD‑008A triggers, **do not** apply PD‑008B on the same case.
* **Tests**:

  * Partition 8‑day public cases; verify one subset snaps to \~0 residuals with this bonus.
* **DoD**:

  * [ ] Guard implemented; exclusivity enforced with PD‑008B.
  * [ ] Documented trigger and addend.

---

### PD‑008B — Day‑8 high‑receipt path: **Tier‑3 receipts = 5%**

* **Status**: PROPOSED · **Priority**: P0 · **Source**: INTERVIEWS · **Tags**: receipts, days-quirk
* **Intent**: Alternate 8‑day path where top receipts band uses **5%** marginal rate.
* **Parameters to learn**: Receipts Tier‑3 threshold; confirm 5% exact; verify it’s marginal (top band only).
* **Mutual exclusivity**: Do not co‑apply with PD‑008A.
* **Tests**:

  * 8‑day, high‑receipt cases align when Tier‑3=5% is used.
* **DoD**:

  * [ ] Tier‑3 override wired under guard.
  * [ ] Unit test at threshold ±ε.

---

### MI‑100 — Mileage tiers (piecewise) with flattening

* **Status**: PROPOSED · **Priority**: P0 · **Source**: PRD, INTERVIEWS · **Tags**: mileage
* **Intent**: Compute mileage reimbursement via tiered rates; diminishing returns on higher bands.
* **Parameters to learn**: Cut points (e.g., `<400`, `400–800`, `>800`), per‑tier rates.
* **Tests**:

  * Residual vs miles shows slope breaks aligned with cut points.
* **DoD**:

  * [ ] Deterministic piecewise function implemented.
  * [ ] Table of thresholds/rates documented.

---

### EF‑150 — Efficiency penalty (miles/day), base −60 with scaling

* **Status**: PROPOSED · **Priority**: P0 · **Source**: INTERVIEWS · **Tags**: efficiency
* **Intent**: Penalize unusually high miles/day; discourages extreme driving days or padding.
* **Parameters to learn**: Activation threshold (miles/day), scaling function from base **−60** (linear/step).
* **Precedence**: After base + day‑quirks, before normalization.
* **Tests**:

  * Residual vs miles/day exhibits a kink at threshold after enabling.
* **DoD**:

  * [ ] Guarded penalty with documented formula/threshold.
  * [ ] Unit tests across boundary.

---

### RC‑200 — Receipts tiers (thresholds & rates)

* **Status**: PROPOSED · **Priority**: P0 · **Source**: PRD, INTERVIEWS · **Tags**: receipts
* **Intent**: Tiered reimbursement on receipts; interacts with PD‑008B for 8‑day high‑receipt path.
* **Parameters to learn**: Tier thresholds, Tier‑1/2/3 rates (except PD‑008B override for Tier‑3=5%).
* **Tests**:

  * Check marginal effects near each threshold; verify no overshoot at joins.
* **DoD**:

  * [ ] Deterministic tier calc with exact thresholds.
  * [ ] Edge tests at each threshold ±\$0.01.

---

### RC‑210 — Dynamic low‑value receipts cap

* **Status**: PROPOSED · **Priority**: P1 · **Source**: INTERVIEWS · **Tags**: receipts
* **Intent**: Suppress tiny receipt noise (clerical convenience rule).
* **Parameters to learn**: Cap function (fixed floor vs function of days).
* **Tests**:

  * Residual distribution narrows for low‑receipt trips; no effect elsewhere.
* **DoD**:

  * [ ] Guard + formula locked; documented.

---

### NR‑300 — **.49/.99** cents normalization (stage & rule)

* **Status**: PROPOSED · **Priority**: P0 · **Source**: INTERVIEWS, EDA · **Tags**: normalization
* **Intent**: Snap amounts to `…49` or `…99` cents at the correct stage (either receipts component or subtotal).
* **Parameters to learn**: Placement (component vs subtotal), tie‑breaking logic, exact snapping rule.
* **Tests**:

  * Cents histogram spikes at `.49/.99` **appear** only when placed correctly.
* **DoD**:

  * [ ] Single place in pipeline; deterministic rule; unit test on crafted values.

---

### GL‑400 — Global payout caps/floors (if any)

* **Status**: PROPOSED · **Priority**: P2 · **Source**: PRD (implied) · **Tags**: caps
* **Intent**: Enforce minimum trip payout and/or hard cap if present.
* **Parameters to learn**: Min, Max values; activation guards.
* **Tests**:

  * Boundary cases hit min/max exactly; no unintended clipping.
* **DoD**:

  * [ ] Constants documented; tests added.

---

### OR‑900 — Rule ordering / precedence

* **Status**: PROPOSED · **Priority**: P0 · **Source**: PRD, EDA · **Tags**: ordering
* **Intent**: Canonical order for exact reproducibility:

  1. Per‑Diem → 2) Mileage → 3) Receipts (+ low‑value cap) → 4) Day‑quirks (5‑day, 8‑day) → 5) Efficiency penalty → 6) Normalization (.49/.99) → 7) Final round(2) & caps
* **Parameters to learn**: Confirm normalization placement (step 3 or 6).
* **Tests**:

  * Ablation toggles confirm order sensitivity (cent spikes & residual needles vanish only in correct order).
* **DoD**:

  * [ ] Order codified centrally (single function) and referenced by tests.

---

## 3) Diagnostics & Verification Tasks

### TS‑001 — Cents histogram spikes at .49/.99

* **Status**: PROPOSED · **Priority**: P0 · **Tags**: diagnostics
* **Goal**: Validate normalization stage by observing histogram spikes.
* **DoD**:

  * [ ] Script generates cents histogram before/after; expected spikes present only when placed correctly.

### TS‑002 — Residuals vs `days`

* **Status**: PROPOSED · **Priority**: P0
* **Goal**: Needles at 5 & 8 vanish after PD‑005 and PD‑008\* enabled.
* **DoD**:

  * [ ] Plot/regression check saved under `logs/`.

### TS‑003 — Residuals vs `miles`

* **Status**: PROPOSED · **Priority**: P0
* **Goal**: Slope changes line up with MI‑100 thresholds.
* **DoD**:

  * [ ] Breaks detected; thresholds documented.

### TS‑004 — Residuals vs `miles/day`

* **Status**: PROPOSED · **Priority**: P0
* **Goal**: Kink at efficiency threshold; −60 base scaling validated.
* **DoD**:

  * [ ] Threshold recorded; penalty formula snapshot in params.

---

## 4) Open Parameters Register (to be learned & then frozen)

> Fill these as you fit rules; keep reverse‑chronological with timestamps.

* **\[\_\_\_\_Z]** `per_diem_table`: `{1: ___, 2: ___, …, 8: ___, …}`
* **\[\_\_\_\_Z]** `mileage_tiers`: `[(0, t1, rate1), (t1, t2, rate2), (t2, inf, rate3)]`
* **\[\_\_\_\_Z]** `receipts_tiers`: `[(0, r1, pct1), (r1, r2, pct2), (r2, inf, pct3)]`
* **\[\_\_\_\_Z]** `efficiency_threshold_mpd`: `___` (miles/day)
* **\[\_\_\_\_Z]** `efficiency_penalty_scale`: `formula(params)`; base `−60` confirmed
* **\[\_\_\_\_Z]** `low_value_cap`: `formula(days, receipts)`
* **\[\_\_\_\_Z]** `.49/.99_normalization`: `stage=<component|subtotal>`, `rule=<snap logic>`

---

## 5) Change Log (prepend newest at top)

```
### 2025-08-24T00:00:00Z — [AGENT <agent_slug/>] — backlog-init
- Added baseline feature cards PD‑001, PD‑005, PD‑008A/B, MI‑100, EF‑150, RC‑200/210, NR‑300, GL‑400, OR‑900, TS‑001..004.
- Next: parameter extraction for PD‑001, MI‑100, RC‑200; placement test for NR‑300.
```

> Use the same concise cadence for each iteration.

---

## 6) How to Use & Maintain

1. **Every iteration**:

   * Update **status** and **parameters** here first.
   * Keep **IDs stable**; never recycle.
   * When a feature is confirmed wrong, set `REVERTED` and note **why** (don’t delete).

2. **Ablations**:

   * Keep a simple toggle dict (e.g., `params/feature_flags-<agent_slug/>.json`) to flip features on/off for order/placement testing.

3. **Cross‑links**:

   * When you commit code for a feature, reference its **ID** in the commit message and in `lessons_learned.md`.

4. **Verification**:

   * For P0 items, attach at least one **diagnostic** (TS‑001..004) outcome in `logs/` and note the file here.

---

## 7) Icebox (deferred hypotheses)

* **QC‑x**: Department‑specific multipliers (seen in interviews but likely out‑of‑scope if not encoded in inputs).
* **TIME‑x**: Submission‑day effects (Tuesday/Friday lore)—ignore unless leakage appears in public cases.

---

### (Optional) Machine‑Readable Registry (JSONL)

If you want automation, create `features/features-<agent_slug/>.jsonl` with one JSON object per feature:

```json
{"id":"PD-001","name":"Per-diem table","status":"PROPOSED","priority":"P0","tags":["per-diem"],"params":["table"],"guards":"days >= 1","precedence":1}
{"id":"PD-005","name":"Day-5 bonus","status":"PROPOSED","priority":"P0","tags":["per-diem","days-quirk"],"params":["amount","is_percent"],"guards":"days == 5","precedence":4}
{"id":"PD-008A","name":"Day-8 additive bonus","status":"PROPOSED","priority":"P0","tags":["per-diem","days-quirk"],"params":["trigger","amount"],"guards":"days == 8 && patternA","precedence":4}
{"id":"PD-008B","name":"Day-8 Tier-3=5%","status":"PROPOSED","priority":"P0","tags":["receipts","days-quirk"],"params":["tier3_threshold"],"guards":"days == 8 && high_receipts && !patternA","precedence":3}
{"id":"MI-100","name":"Mileage tiers","status":"PROPOSED","priority":"P0","tags":["mileage"],"params":["t1","t2","rate1","rate2","rate3"],"guards":"miles >= 0","precedence":2}
{"id":"EF-150","name":"Efficiency penalty","status":"PROPOSED","priority":"P0","tags":["efficiency"],"params":["mpd_threshold","scale"],"guards":"(miles/days) >= mpd_threshold","precedence":5}
{"id":"RC-200","name":"Receipts tiers","status":"PROPOSED","priority":"P0","tags":["receipts"],"params":["r1","r2","pct1","pct2","pct3"],"guards":"receipts >= 0","precedence":3}
{"id":"RC-210","name":"Low-value cap","status":"PROPOSED","priority":"P1","tags":["receipts"],"params":["cap_formula"],"guards":"receipts small","precedence":3}
{"id":"NR-300","name":".49/.99 normalization","status":"PROPOSED","priority":"P0","tags":["normalization"],"params":["stage","rule"],"guards":"always","precedence":6}
{"id":"GL-400","name":"Global caps/floors","status":"PROPOSED","priority":"P2","tags":["caps"],"params":["min","max"],"guards":"always","precedence":7}
{"id":"OR-900","name":"Ordering","status":"PROPOSED","priority":"P0","tags":["ordering"],"params":["sequence"],"guards":"n/a","precedence":0}
```
