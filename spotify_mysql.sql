-- ================================================================
--  Spotify Top 100 Tracks 2018
--  MySQL: Data Cleaning · Manipulation · Analysis
--  Author : THAK ARAVIND  |  github.com/thakarvind
-- ================================================================

CREATE DATABASE IF NOT EXISTS spotify_2018;
USE spotify_2018;

-- ── 1. CREATE TABLE ──────────────────────────────────────────────
DROP TABLE IF EXISTS tracks;
CREATE TABLE tracks (
  id               VARCHAR(50),
  name             VARCHAR(250),
  artists          VARCHAR(250),
  danceability     FLOAT,
  energy           FLOAT,
  musical_key      INT,
  loudness         FLOAT,
  mode             TINYINT,
  speechiness      FLOAT,
  acousticness     FLOAT,
  instrumentalness FLOAT,
  liveness         FLOAT,
  valence          FLOAT,
  tempo            FLOAT,
  duration_ms      INT,
  time_signature   INT
);

LOAD DATA INFILE '/path/to/top2018.csv'
INTO TABLE tracks
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES  TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ── 2. DATA CLEANING ─────────────────────────────────────────────

-- 2a. Check nulls
SELECT
  SUM(id IS NULL)            AS null_id,
  SUM(name IS NULL)          AS null_name,
  SUM(artists IS NULL)       AS null_artists,
  SUM(danceability IS NULL)  AS null_dance,
  SUM(energy IS NULL)        AS null_energy,
  SUM(tempo IS NULL)         AS null_tempo
FROM tracks;
-- Result: all 0 — no nulls ✓

-- 2b. Find duplicate IDs
SELECT id, COUNT(*) AS occurrences
FROM tracks
GROUP BY id
HAVING occurrences > 1;
-- Result: empty — no duplicates ✓

-- 2c. Remove duplicates (safety step)
DELETE t1 FROM tracks t1
INNER JOIN tracks t2
  ON t1.id = t2.id AND t1.name > t2.name;

-- 2d. Add derived columns
ALTER TABLE tracks
  ADD COLUMN track_rank    INT DEFAULT NULL,
  ADD COLUMN duration_min  FLOAT
    GENERATED ALWAYS AS (ROUND(duration_ms / 60000.0, 2)) STORED,
  ADD COLUMN key_name      VARCHAR(3)
    GENERATED ALWAYS AS (
      ELT(musical_key + 1,'C','C#','D','D#','E','F','F#','G','G#','A','A#','B')
    ) STORED,
  ADD COLUMN mode_name     VARCHAR(6)
    GENERATED ALWAYS AS (IF(mode = 1, 'Major', 'Minor')) STORED;

-- Assign rank based on row order
SET @r = 0;
UPDATE tracks SET track_rank = (@r := @r + 1) ORDER BY id;

-- 2e. Add index for faster queries
ALTER TABLE tracks ADD PRIMARY KEY (id);
CREATE INDEX idx_dance   ON tracks (danceability);
CREATE INDEX idx_energy  ON tracks (energy);
CREATE INDEX idx_valence ON tracks (valence);

-- ── 3. SUMMARY STATISTICS ────────────────────────────────────────
SELECT
  COUNT(*)                         AS total_tracks,
  COUNT(DISTINCT artists)          AS unique_artists,
  ROUND(AVG(danceability), 3)      AS avg_danceability,
  ROUND(AVG(energy),        3)     AS avg_energy,
  ROUND(AVG(valence),       3)     AS avg_valence,
  ROUND(AVG(tempo),         1)     AS avg_tempo_bpm,
  ROUND(AVG(duration_min),  2)     AS avg_duration_min,
  ROUND(AVG(loudness),      2)     AS avg_loudness_db
FROM tracks;

-- ── 4. TOP 10 TRACKS ─────────────────────────────────────────────
SELECT track_rank, name, artists,
  ROUND(danceability, 3) AS danceability,
  ROUND(energy, 3)       AS energy,
  ROUND(valence, 3)      AS valence,
  ROUND(tempo, 1)        AS tempo_bpm
FROM tracks
ORDER BY track_rank
LIMIT 10;

-- ── 5. ARTISTS WITH MOST TRACKS ──────────────────────────────────
SELECT artists,
  COUNT(*)                    AS tracks,
  ROUND(AVG(danceability), 3) AS avg_dance,
  ROUND(AVG(energy),        3) AS avg_energy,
  ROUND(AVG(valence),        3) AS avg_valence
FROM tracks
GROUP BY artists
HAVING COUNT(*) > 1
ORDER BY tracks DESC;

-- ── 6. MOST DANCEABLE TRACKS ─────────────────────────────────────
SELECT name, artists, ROUND(danceability, 3) AS danceability
FROM tracks ORDER BY danceability DESC LIMIT 10;

-- ── 7. HIGHEST ENERGY TRACKS ─────────────────────────────────────
SELECT name, artists, ROUND(energy, 3) AS energy
FROM tracks ORDER BY energy DESC LIMIT 10;

-- ── 8. HAPPIEST SONGS (Valence) ───────────────────────────────────
SELECT name, artists, ROUND(valence, 3) AS valence
FROM tracks ORDER BY valence DESC LIMIT 10;

-- ── 9. MOST ACOUSTIC TRACKS ──────────────────────────────────────
SELECT name, artists, ROUND(acousticness, 3) AS acousticness
FROM tracks ORDER BY acousticness DESC LIMIT 10;

-- ── 10. MOST SPEECH-HEAVY (RAP) ──────────────────────────────────
SELECT name, artists, ROUND(speechiness, 3) AS speechiness
FROM tracks ORDER BY speechiness DESC LIMIT 10;

-- ── 11. MUSICAL KEY DISTRIBUTION ─────────────────────────────────
SELECT key_name,
  COUNT(*) AS track_count,
  ROUND(COUNT(*) * 100.0 / 100, 1) AS pct
FROM tracks
GROUP BY key_name ORDER BY track_count DESC;

-- ── 12. MAJOR vs MINOR MODE ───────────────────────────────────────
SELECT mode_name,
  COUNT(*)                     AS tracks,
  ROUND(AVG(danceability), 3)  AS avg_dance,
  ROUND(AVG(energy),        3) AS avg_energy,
  ROUND(AVG(valence),        3) AS avg_valence
FROM tracks
GROUP BY mode_name;

-- ── 13. TEMPO CATEGORIES ──────────────────────────────────────────
SELECT
  CASE
    WHEN tempo < 90  THEN 'Slow  (<90 BPM)'
    WHEN tempo < 120 THEN 'Medium (90–120)'
    WHEN tempo < 150 THEN 'Fast  (120–150)'
    ELSE                  'Very Fast (150+)'
  END AS tempo_range,
  COUNT(*) AS tracks,
  ROUND(AVG(danceability), 3) AS avg_dance
FROM tracks
GROUP BY tempo_range ORDER BY tracks DESC;

-- ── 14. LOUDEST & QUIETEST ────────────────────────────────────────
SELECT name, artists, ROUND(loudness, 2) AS loudness_db
FROM tracks ORDER BY loudness DESC LIMIT 5;

SELECT name, artists, ROUND(loudness, 2) AS loudness_db
FROM tracks ORDER BY loudness ASC  LIMIT 5;

-- ── 15. HIGH DANCE + HIGH VALENCE (Party Songs) ───────────────────
SELECT name, artists,
  ROUND(danceability, 3) AS dance,
  ROUND(valence,      3) AS valence,
  ROUND((danceability + valence) / 2, 3) AS party_score
FROM tracks
WHERE danceability > 0.75 AND valence > 0.65
ORDER BY party_score DESC;

-- ── 16. WINDOW FUNCTION: Rank within artist ───────────────────────
SELECT name, artists,
  ROUND(danceability, 3) AS dance,
  RANK() OVER (PARTITION BY artists ORDER BY danceability DESC) AS rank_in_artist
FROM tracks
WHERE artists IN ('Drake','Post Malone','XXXTENTACION','Ed Sheeran')
ORDER BY artists, rank_in_artist;

/*
  ═══════════════════════════════════════
  CLEAN DATASET SUMMARY
  ───────────────────────────────────────
  Total Tracks      : 100
  Unique Artists    : 70
  Duplicates Found  : 0
  Nulls Found       : 0
  Avg Danceability  : 0.716
  Avg Energy        : 0.659
  Avg Valence       : 0.484
  Avg Tempo         : 119.9 BPM
  Avg Duration      : 3.42 min
  Top Key           : C# (15 tracks)
  Mode Split        : 59 Major · 41 Minor
  Most Tracks       : XXXTENTACION & Post Malone (6 each)
  ═══════════════════════════════════════
*/
