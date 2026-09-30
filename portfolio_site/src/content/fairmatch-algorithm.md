**Algorithm — FairMatch v4 Lexicographic Solver (detail for CV / interview):**

> **Input model:** Each respondent submits `self{devops, ai_ml, general/technical, involvement}` + peer `skill{target:1-10}` + `fit{target:1-10 willingness}` as escaped JSON in Sheets `payload/email` column.

**1. Clean & Normalize (Node 1):**

Dual-stage JSON parse (fix `""` escapes), timestamp-parse + keep latest per `selfName`, fixed 24-roster via master gender map (unknown rated names ignored + warned, no ghosts), 2-token display names with collision-throw, dynamic scale detect: if `maxRaw>5` then `scaled=1+(raw-1)*4/(maxRaw-1)`, peer-consensus imputation for non-submitters (self = peer skill mean, outgoing = peer means), profile synthesis per dimension: `peer=mean`, `gap=self-peer`, if `|gap|>1.5` flag `OVER/UNDER_SELF_RATED` → `final=peer`, else `final=0.8*peer+0.2*self` for tech dims / `0.5/0.5` for involvement, `overall=mean(4 dims)`. Pearson rater-consistency (>0.75, n≥10) + low-confidence flags (<max(3,30% raters)).

> **Compatibility matrices:** `directedWilling[rater][target]`, `pairMin=min(A→B,B→A)`, `pairAvg=mean`. `veto` if `pairMin≤1.5`, `low` if `<2.5`.

**2. Constraints precompute:**

`genderSlots(M,F,K=4)`: even distribute M/F, fix size mismatch to `[3M/3F,3M/3F,2M/4F,2M/4F]` for 10M/14F. `buildTiers`: per gender sort by `overall_skill`, slice by slot demands → Tier 1 = Top Talent. `MIN_SKILL_FLOOR`=10th-percentile skill −0.3.

**3. 8-level lexicographic objective `L1→L2V→L2→L2C→L5→L3→L6→L4`:**

`L1` = sum floor deficit, `L2V` = intra-team veto count, `L2` = sum `max(0,2.5-worstWilling)`, `L2C` = low-pair count, `L5` = `max(teamAvg)-min(teamAvg)`, `L3` = missing tech-dimension coverage (`max<3.0` per devops/ai_ml/technical), `L6` = `max(spread)-min(spread)` where spread = intra-team stddev, `L4` = Tier-1 stacking (`count Tier1>1` excess). Compare as raw tuple, no epsilon.

**4. DraftV4 (toxicity-first, 20 starts, seed=42+s*997, CPython MT19937):**

Sort roster by `veto-degree desc, skill desc, random()`. Place each greedily minimizing `penalty=addVeto*100+addLow*10+|newAvg-globalMean|*2-wAvg*0.5` respecting gender slots. Fallback `draftGreedySimple`: skill-sorted snake draft per gender with veto-avoid scan.

**5. Refinement (steepest descent, 6 passes):**

Try all same-gender 1-swaps + M+F 2×2 swaps across team pairs, take globally best lexicographic improvement per pass until no improvement. Log `swapLog`.

**6. Selection + audit:**

Best tuple across 20 starts wins. Classify: `FEASIBLE` if all zero, `FEASIBLE_WITH_RELAXATION` if only tier relax, else `FEASIBLE_WITH_REMAINING_SOFT_VIOLATIONS` (thresholds: avg-gap 0.6, spread-gap 0.75). Per-team fairness: `penalty=vetoes*22+(worst<2.5?12:0)+lows*4+|avg-global|*28+max(0,spread-0.35)*30+max(0,2.8-avgW)*6`, `score=100-penalty`, grade A≥85 B≥70 C≥50 D≥35 else F. Overall: `L2V*15+L2*10+L2C*5+L5*30+L6*18`. Final result: gap ≤0.19, L2V=0 on frozen data.
