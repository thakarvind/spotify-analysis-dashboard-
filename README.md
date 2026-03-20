[README.md](https://github.com/user-attachments/files/26134287/README.md)
# Spotify Top 100 Tracks — 2018 Data Analysis & Dashboard

**Author:** THAK ARAVIND
**GitHub:** [github.com/thakarvind](https://github.com/thakarvind)
**Stack:** MySQL · Python · Power BI · HTML

---

## Project Description

End-to-end data analysis of the Spotify Top 100 Tracks from 2018. The raw dataset was cleaned using a full SQL pipeline — checking for nulls, removing duplicates, engineering new columns, and computing a custom vibe score. All insights are presented in a clean, single-page interactive dark-mode dashboard styled built with Power BI.

---

## Dashboard Preview

[spotify_dashboard.pdf](https://github.com/user-attachments/files/26136286/spotify_dashboard.pdf)

---

## Repository Files

| File | Description |
|------|-------------|
| `top2018.csv` | Raw dataset · 100 tracks · 16 audio feature columns |
| `spotify_sql_pipeline.sql` | Full MySQL pipeline · 13 steps · cleaning + EDA |
| `spotify_dashboard.html` | Interactive analytics dashboard |
| `README.md` | Project documentation |
| `assets/` | Dashboard preview screenshots |

---

## SQL Pipeline — Step by Step

```sql
-- STEP 1  Create raw table and load CSV
-- STEP 2  NULL check across all 16 columns        → 0 nulls found ✓
-- STEP 3  Duplicate check (GROUP BY id)           → 0 duplicates found ✓
-- STEP 4  Remove duplicates using ROW_NUMBER()    → Clean table created
-- STEP 5  Add derived columns:
--           key_name      (C, C#, D ... B)
--           mode_name     (Major / Minor)
--           tempo_category (Slow / Medium / Fast / Very Fast)
--           duration_min  (duration_ms ÷ 60000)
-- STEP 6  Add computed vibe_score = (danceability + energy + valence) / 3
-- STEP 7  Summary statistics
-- STEP 8  Top 10 tracks by chart rank
-- STEP 9  Artists with most chart placements
-- STEP 10 Key and Mode distribution
-- STEP 11 Tempo range distribution
-- STEP 12 Feature rankings (dance, energy, valence, acousticness)
-- STEP 13 Party song filter (danceability > 0.78 AND energy > 0.78)
```

---

## Dataset Overview

| Column | Type | Description |
|--------|------|-------------|
| `id` | String | Unique Spotify track ID |
| `name` | String | Track name |
| `artists` | String | Artist name |
| `danceability` | Float (0–1) | How suitable for dancing |
| `energy` | Float (0–1) | Intensity and activity level |
| `key` | Int (0–11) | Musical key (C=0, C#=1 … B=11) |
| `loudness` | Float (dB) | Overall loudness |
| `mode` | Int (0/1) | Minor=0, Major=1 |
| `speechiness` | Float (0–1) | Presence of spoken words |
| `acousticness` | Float (0–1) | Acoustic confidence score |
| `instrumentalness` | Float (0–1) | Predicts no vocals |
| `liveness` | Float (0–1) | Presence of live audience |
| `valence` | Float (0–1) | Musical positiveness / mood |
| `tempo` | Float (BPM) | Estimated beats per minute |
| `duration_ms` | Int | Track duration in milliseconds |
| `time_signature` | Int | Estimated time signature |

---

## Key Findings

### Data Quality
| Check | Result |
|-------|--------|
| Total raw records | 100 |
| Null values | 0 |
| Duplicate track IDs | 0 |
| Final clean records | 100 ✓ |

### Audio Feature Averages
| Feature | Avg Score |
|---------|-----------|
| Danceability | 0.716 |
| Energy | 0.659 |
| Valence (Mood) | 0.484 |
| Acousticness | 0.196 |
| Speechiness | 0.116 |
| Liveness | 0.158 |
| Avg Tempo | 119.9 BPM |
| Avg Duration | 3.42 min |

### Artist Insights
| Artist | Tracks in Top 100 |
|--------|-------------------|
| XXXTENTACION | 6 |
| Post Malone | 6 |
| Drake | 4 |
| Marshmello | 3 |
| Ed Sheeran | 3 |

### Top Track Rankings
| Category | Track | Artist | Score |
|----------|-------|--------|-------|
| Most Danceable | Yes Indeed | Lil Baby | 0.964 |
| Highest Energy | Nice For What | Drake | 0.909 |
| Happiest (Valence) | Shape of You | Ed Sheeran | 0.931 |
| Most Acoustic | lovely | Billie Eilish | 0.934 |

### Musical Key & Mode
- **Most common key:** C# — 15 tracks (15%)
- **Mode split:** 59 Major · 41 Minor
- Minor songs have slightly higher avg danceability (0.726 vs 0.710)

### Tempo Distribution
| Category | Tracks |
|----------|--------|
| Medium (90–120 BPM) | 42 |
| Fast (120–150 BPM) | 35 |
| Very Fast (150+ BPM) | 15 |
| Slow (<90 BPM) | 8 |

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/thakarvind/spotify-2018-analysis.git
cd spotify-2018-analysis

# 2. Run the SQL pipeline in MySQL
mysql -u root -p spotify_2018 < spotify_sql_pipeline.sql

# 3. Open the dashboard
open spotify_dashboard.html
```

---

## GitHub Topics

`data-analysis` `sql` `mysql` `spotify` `eda` `dashboard` `data-cleaning` `chartjs` `data-visualization` `music-data` `python` `top-100`
