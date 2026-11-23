# What Shapes Purchase Intent for "Youthful, Body-Revealing" Fast Fashion?

**A keyword and comparison analysis of 7,900+ social-media comments.**

A data-pipeline + text-mining project that asks a specific question about a specific clothing category: *what do the consumers who actually buy "纯欲风" (pure-desire) and "辣妹装" (spicy-girl) clothing focus on when they evaluate it — and what makes them complain?*

The answer, backed by a matched-comparison design, is deliberately unglamorous: **these consumers almost never discuss the category as an aesthetic or ethical question. They talk about it the way anyone talks about clothes — fabric, fit, whether it flatters them, and whether they can actually wear it out of the house.** The complaints that are *unique* to this category (fabric quality, exposure, wearability) are complaints about *execution*, not about *the idea*.

---

## TL;DR — what a recruiter should take away

- **A complete, reproducible pipeline** — raw Chinese comments → cleaned SQLite database → `jieba` segmentation → R/ggplot2 figures, with every keyword translated to English.
- **A real methodological decision, not a textbook one.** I discovered that my main sample was collected with *search terms carrying a built-in stance* (negative terms like "走光" / "勒肉" inflate complaint rates), so I **matched on neutral search terms only** to make the comparison fair.
- **A finding that survives honest testing.** I explicitly tried three alternative hypotheses and *ruled them out*, and I document that elimination process rather than hiding it.
- **A business framing, not just a number.** The insight reframes the category from "a morally controversial trend" into "a promise being badly executed" — which is actionable.

---

## 🔍 The core finding

I counted complaint-words across **five dimensions** and compared the "youthful, body-revealing" group against a **matched control set** (athleisure / office / yoga wear), standardising by hits per 1,000 comments (sample sizes differ: 989 vs 582).

| Dimension | Youthful, body-revealing (n=989) | Control (n=582) | Gap |
|---|---|---|---|
| Fit / Cut | 116.3 | 134.0 | — (universal) |
| **Fabric Quality** | **34.4** | 6.9 | **~5× higher** |
| **Exposure / Wardrobe** | **12.1** | 6.9 | **~1.8× higher** |
| **Wearability / Occasion** | **17.2** | 6.9 | **~2.5× higher** |
| Physical Comfort | 2.0 | 1.7 | — (universal) |

> **Reading the table:** only *fabric*, *exposure*, and *wearability* show a category-specific gap. *Fit* and *comfort* are common to **all** women's clothing. So the unique pain of this category is not "it doesn't fit" — it's "it's cheap, it's revealing, and I can't actually wear it anywhere."

Two further pieces of evidence point the same way:

1. **The words themselves (16:1).** In the neutral-search main sample (989 comments), *embodied / experiential* words (短 / 紧 / 显胖 / 版型 / 尴尬 / 土…) outnumber *abstract / aesthetic* words (审美 / 物化 / 幼态…) by roughly **16:1 (95 vs 6 occurrences)**. Consumers describe the *felt reality* of wearing it, almost never an aesthetic or ethical stance.
2. **Direct mentions of the aesthetic are rare.** References to the youthful styling itself (幼态 / 扮嫩 / 像小孩) appear in only **21 of 7,867** comments.

> ⚠️ **Honest caveat, stated plainly:** "youthful, body-revealing" is *my* analytic label, not theirs. The people in this data do not describe what they buy that way. They talk about clothes; I am the one applying an analytic frame. Keeping that distinction honest is the most important discipline of this project.

---

## 🧱 Pipeline overview

```
raw comments (xlsx)
      │  clean_data.py  ── column mapping, store pseudonymisation, de-duplication
      ▼
data/social_comments_clean.csv   (7,867 rows)
      │  jieba_segment.py  ── (exploratory) Chinese word segmentation + stopword removal
      ▼
segmented tokens (exploratory, not used by the final chart)
      │  manual keyword coding  ── five complaint dimensions, documented word list
      ▼
five-dimension counts (standardised per 1,000 comments)
      │  r/fig4.R  ── dplyr / ggplot2
      ▼
figures/fig4_unique_complaints.png
```

> **A note on method, stated plainly:** the `jieba` segmentation was an *exploratory* step — it mapped the vocabulary, but the headline comparison does **not** depend on it. The five-dimension complaint counts behind Figure 4 come from **manual keyword coding** against a documented word list, then standardised per 1,000 comments. The final figure is reproducible from a small, human-checkable table — which is *more* defensible than a black-box tokeniser would be.

> **Note on scale:** 7,912 raw comments → **7,867** after de-duplication (45 cross-post duplicates removed) → **6,571** retained after segmentation filtering (comments reduced to only stopwords or non-Chinese characters are dropped).

The database design (`sql/schema.sql`) uses a proper relational structure — primary keys, `NOT NULL` constraints, and indexes on the query columns (`platform`, `track`) — not just a flat CSV dump.

---

## 🗂️ Repository structure

```
├── report.qmd               # Quarto write-up (research question, method, findings, limitations, ethics)
├── report.html              # rendered report
├── clean_data.py            # raw → clean CSV (column mapping, pseudonymisation, dedup)
├── jieba_segment.py         # jieba segmentation + stopword list (also exports stopwords.txt)
├── sql/
│   └── schema.sql           # SQLite schema (3 tables, indexed)
├── r/
│   └── fig4.R               # the five-dimension comparison chart
├── data/
│   └── stopwords.txt        # categorised stopword list (methodology transparency)
└── figures/
    └── fig4_unique_complaints.png   # the five-dimension comparison chart
```

---

## 🧪 Methodology & labeling

Comments carry a **three-layer classification**:

1. **Platform** — Xiaohongshu (小红书) vs. Douyin (抖音)
2. **Collection track** — Broad extraction, Targeted (by store account), Awakening/backlash, Control/neutral
3. **Spectrum pole** — a within-category grouping used during exploration

**The key methodological decision — matching on search terms.** My main sample was collected with a mix of neutral and *negative* search terms, while the control set used only neutral terms. To make the comparison fair, I re-ran the analysis using **only the 6 neutral style terms** from the main sample (`纯欲风穿搭 / 幼态感穿搭 / 甜辣风穿搭 / 斩男穿搭 / 微胖穿搭 / 辣妹装`), matched against neutral control terms. This removes the "search-term stance" bias and leaves only the *category* difference.

**Text segmentation** uses `jieba` with a hand-curated stopword list (grammatical particles, filler words, marketing language, emoji-as-text, self-referential spectrum terms), and custom domain terms (纯欲, 辣妹, 幼态, 白月光, 好嫁风…) registered via `jieba.add_word()` so they are not over-segmented.

**Visualisation** uses R (`dplyr` + `ggplot2`). Every keyword that appears in a figure is translated to English so the charts are legible to an English-speaking audience.

---

## 🔒 Data privacy & ethics

This is a portfolio project built on **publicly posted social-media comments**. To minimise privacy risk:

- **Author identities are de-identified** (`author_anon` = U001, U002, …).
- **Store names are pseudonymised** (Store-A … Store-F).
- **The raw comment text, platform IDs (`comment_id` / `note_id`), and the database are intentionally NOT in this repository** — they live only locally and are excluded via `.gitignore`.

The point of sharing the pipeline (not the raw data) is to demonstrate methodology while respecting the original posters' privacy. A fuller ethics reflection is included in `report.qmd` (§6).

---

## ▶️ Reproducing the analysis

> Raw data is not included here. The scripts below are shown for transparency of method.

```bash
# 1. Clean raw comments → data/social_comments_clean.csv
python clean_data.py

# 2. Segment → segmented tokens (exploratory step; also writes data/stopwords.txt)
python jieba_segment.py

# 3. Build the SQLite database
sqlite3 analysis.db < sql/schema.sql

# 4. Generate the comparison figure (R 4.x with dplyr / ggplot2 / tidyr)
Rscript r/fig4.R

# 5. Render the report (requires Quarto)
quarto render report.qmd
```

---

## 🛠️ Tech stack

- **Python 3** — data cleaning (`csv`), text segmentation (`jieba`)
- **SQLite** — relational schema with primary keys, `NOT NULL` constraints, and indexes
- **R** — `dplyr`, `tidyr`, `stringr`, `ggplot2`, `RColorBrewer`, `forcats`, `readr`
- **Quarto** — reproducible report

---

## 📌 Status & next steps

- [x] Data pipeline (clean → segment → label)
- [x] SQLite schema
- [x] Matched-comparison analysis (five complaint dimensions, control set)
- [x] Quarto report (`report.qmd`)
- [x] `fig4_unique_complaints.png` finalised with the "youthful, body-revealing" label
- [x] Legacy figures / files cleaned up

---

## 👤 Author

**Yuchen Kang** — a data / business-analytics project built as a portfolio piece for a UK tech-analyst internship application. The goal is to show a complete, honest end-to-end analysis: messy data in, a defensible conclusion out.
