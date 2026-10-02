# SaaS Analytics — Analytics Engineer Case Study

## Getting started

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install dbt-core dbt-duckdb
export DBT_PROFILES_DIR=.
dbt debug   # confirms the connection is set up correctly
```

The three raw CSVs (`data/raw_accounts.csv`, `data/raw_subscriptions.csv`,
`data/raw_events.csv`) are already wired up as dbt sources in
`models/sources.yml` — dbt reads them directly, no seed step required. There
are no other models in this repo yet; that's the exercise.

`setup.py` is a separate, optional ad-hoc exploration tool (loads the CSVs
into an in-memory DuckDB shell via `python setup.py`) if you want to poke at
the raw data before writing any SQL. It is not part of the dbt data path.

---

## Scenario

You've just joined a B2B SaaS company as an analytics engineer.
You're given three raw exports from production systems and asked to build
the modeling layer the business will run on. Two things make this messier
than a clean modeling exercise:

1. The **VP of Sales** and the **CRO** disagree about what "churned" means
   for this business. Both have a legitimate reason for their view — they're
   not arguing in bad faith, they're looking at the same accounts through
   different lenses:
   - **VP of Sales:** "Churned means they've stopped paying us. If MRR is
     zero, they've churned. If they're still paying us something, they
     haven't — I don't care how quiet they've gone."
   - **CRO:** "That's too narrow. An account can be functionally gone long
     before the invoice says so — revenue that's cratered from where it used
     to be, or an account nobody there has logged into in months, is churned
     to me, whether or not billing agrees."

   Neither has given you a number (a % revenue drop, a day count) — that's
   yours to decide and defend, not theirs to hand you.

   One more wrinkle: the VP has already used his zero-MRR definition in this
   quarter's board deck, and this quarter's sales commissions are calculated
   against it. If your number lands somewhere else, you need to be ready to
   say why — not just declare a different one.
2. There's also an unresolved dispute over the **Customer Health Score**:
   Customer Success wants one number they can sort a renewals list by;
   Product wants the components kept visible, because a blended score can
   hide which input is actually collapsing. You're not told which view wins,
   or whether that means one score, several, or something else — state your
   approach and the trade-off; a couple of sentences is enough.

Deciding how to handle that absence of clarification is part of the
exercise, not a gap in this brief.

## What you're given

- `data/raw_accounts.csv`, `data/raw_subscriptions.csv`, `data/raw_events.csv`
  — the three raw exports.
- A skeleton dbt project (`dbt_project.yml`, `profiles.yml`,
  `models/sources.yml`) with the CSVs already wired up as dbt sources —
  there's no seed step and nothing to configure before you start writing
  models.
- `setup.py` — optional and outside the dbt path. Loads the CSVs into an
  in-memory DuckDB shell (`python setup.py`) if you want to poke at the raw
  data before writing any SQL.

One fixed value to know about: `as_of_date` in `dbt_project.yml` is pinned to
**2026-04-26** — the event data only covers 2026-01-01 through that date.
Treat it as "today" for any point-in-time logic (recency, current-month MRR,
health-score inputs) instead of the system clock; the var is already there
for you to reference.

Treat the CSVs as real production exports. They contain duplicates,
inconsistent formatting, orphaned foreign keys, and edge cases that don't
collapse cleanly into a 1:1 model. Finding and handling these is part of
what's being assessed, not incidental noise around the "real" task.

## What to build

A working dbt project (dbt-core, any supported adapter — DuckDB is fine, and
is what we'll use to run it) that produces, at minimum:

- An account dimension.
- A subscription-level history that a finance or CS user could audit —
  reconstructable current and historical state is enough; you do not need a
  full bitemporal (SCD2-style) audit trail.
- A monthly recurring revenue fact table at account × month grain, with
  enough detail to explain revenue movement (new, expansion, contraction,
  churn, reactivation) month over month.
- A customer health / churn view that addresses the VP/CRO disagreement
  above, plus whatever health-scoring approach you think is defensible.

We are **not** prescribing table names, grain, or how many models this
becomes. We are also not telling you whether the VP and CRO end up with one
number, two numbers, or something else — that structure is your call to make
and defend.

There is no single correct answer to the churn question or the health-score
question. We're evaluating how you reason about it and whether your solution
makes that reasoning inspectable — not whether you land on the output we
would.

## Deliverables

1. **Runnable dbt project** — passes `dbt build`, with a handful of targeted
   tests covering the judgment calls you made (not exhaustive column-level
   coverage).
2. **Written submission** (~1–2 pages total, in a format of your choosing —
   markdown, a doc, slides, whatever you'd actually use at work):
   - **Architecture & data cleanup** — key modeling decisions and how you
     handled the raw edge cases.
   - **Stakeholder resolution** — your call on the VP/CRO churn dispute and
     the health-score trade-off, and why.
   - **CRO summary** — one paragraph or slide, written directly for the CRO
     in their register, not a reworded engineering summary — you'll defend
     it live in the debrief.
   - **Standard-setting note** — imagine a different engineer hitting a
     similar dispute later (different specifics, same underlying pattern).
     What would you want them to already have, so they're not starting from
     zero? A definitions note, a decision-log entry, a metrics contract, or
     similar — any are reasonable, but give the actual content, not just the
     artifact's name. Not a restatement of the call you just made above.
   - **Trade-offs** — what you'd revisit with more time, and where you're
     least confident.
   - **AI usage** — what you used AI for, what you specifically checked
     before trusting it, what you didn't hand to it. Be specific: "I had it
     draft the staging models, then rewrote a piece of overlap-handling
     logic once I spotted it silently dropping data" is useful; "used it for
     boilerplate" isn't. If you used AI to draft specs, prompts, or a plan
     for any part of this, feel free to attach them alongside your
     write-up — useful signal for us, not required reading for you to
     produce.

## Time

Aim for 4–6 hours. We'd rather see a smaller, well-reasoned solution than a
sprawling one — the debrief will ask you to defend specific decisions live,
not to read the whole submission back to us.

## The debrief

This case study is the input to a working session, not the deliverable
itself. Come ready to:

- Walk through 2–3 specific decisions you made and why. Don't plan a full
  readthrough — we will have read the repo before you arrive.
- Take a live follow-up requirement we introduce on the spot, and reason
  through it in real time.
- Talk honestly about what you're least sure of. "I didn't have time to
  resolve X, and here's how I'd approach it" is a strong answer, not a weak
  one.
