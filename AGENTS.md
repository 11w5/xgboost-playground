# AGENTS.md

<repository_overview>
  The project is a reverse‑engineering challenge: reproduce the legacy travel reimbursement algorithm
  using the 1,000 labeled examples in `public_cases.json`, guided by clues in `PRD.md` and `INTERVIEWS.md`.
</repository_overview>

<data_sets>
  - `public_cases.json`: array of 1,000 records. Each record has an `input` object with
    `trip_duration_days` (integer), `miles_traveled` (integer), and `total_receipts_amount` (decimal),
    plus an `expected_output` (decimal reimbursement).
  - `private_cases.json`: array of 5,000 unlabeled records mirroring the `input` structure above.
</data_sets>

<repository_structure>
  .
  ├── AGENTS.md
  ├── INTERVIEWS.md
  ├── PRD.md
  ├── README.md
  ├── eval.sh
  ├── generate_results.sh
  ├── public_cases.json
  ├── private_cases.json
  └── run.sh.template

  - `AGENTS.md`: contributor guidelines and instructions.
  - `INTERVIEWS.md`: anecdotal clues about the legacy logic.
  - `PRD.md`: product requirements document.
  - `README.md`: challenge overview and usage notes.
  - `eval.sh`: validates `run.sh` against public cases.
  - `generate_results.sh`: produces predictions for private cases.
  - `public_cases.json`: labeled dataset with 1,000 examples.
  - `private_cases.json`: unlabeled dataset for final submission.
  - `run.sh.template`: starting point for implementing the reimbursement model.
</repository_structure>

<code_editing_rules>

  <guiding_principles>
    - Be precise and avoid conflicting instructions; prefer clarity over completeness.
    - When modifying `run.sh`, ensure it accepts exactly three parameters:
      `trip_duration_days`, `miles_traveled`, and `total_receipts_amount`.
    - Any change that affects reimbursement logic must be validated with `./eval.sh`.
  </guiding_principles>

  <reasoning_effort>
    - Use **high** reasoning effort for deducing or altering algorithmic behavior.
    - Use **medium** effort for routine shell scripting or documentation tweaks.
  </reasoning_effort>

  <instruction_format>
    - Embed new instructions or code comments with XML‑like tags where helpful
      (e.g., `<assumption>`, `<todo>`), keeping them concise.
  </instruction_format>

  <language_tone>
    - Favor calm, direct language instead of overly firm phrasing.
  </language_tone>

  <self_reflection>
    - Before committing substantial logic changes, briefly reflect on:
      1. The hypothesis you’re implementing.
      2. How it aligns with interview anecdotes and dataset patterns.
      3. Possible edge cases.
  </self_reflection>

  <persistence>
    - Assume responsibility for reasonable default decisions without repeatedly
      asking for confirmation.
    - Document assumptions in commit messages or inline comments.
  </persistence>

</code_editing_rules>

<testing_guidelines>
  - Run `./eval.sh` after any change to verify public-case accuracy.
  - Before submission, run `./generate_results.sh` to produce `private_results.txt`.
</testing_guidelines>
