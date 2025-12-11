//////////////////////////////////////////////
// SnowflakeBascketballDataWarehouse
// OPTA_DATA_BASKETBALL_SCHEDULE_AND_RESULTS_DATA__SAMPLE
// Odin Lee
//////////////////////////////////////////////

// Initial Setup
USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COYOTE_WH;
USE WAREHOUSE COYOTE_WH;
CREATE DATABASE IF NOT EXISTS COYOTE_DB;
USE COYOTE_DB.PUBLIC;

// =================================================== //
//            Worksheet 3: Aggregation Layer           //
// =================================================== //

// ---------- Create schema --------- //

// Create aggregation schema called BASKETBALL_AGGREGATION
CREATE SCHEMA IF NOT EXISTS BASKETBALL_AGGREGATION;

// ---------- Aggregation Object #1 ---------- //

// Teams Point Per Game (PPG) statistics (TABLE)
CREATE OR REPLACE TABLE BASKETBALL_AGGREGATION.AGG_TEAM_STATS
TAG (BASKETBALL_CURATION.PROJECT = 'true') AS
WITH ALL_GAMES AS (
    -- Home team
    SELECT
        home.TEAM_UUID,
        home.TEAM_NAME,
        g.GAME_UUID,
        g.HOME_SCORE    AS HOME_POINTS,
        NULL::NUMBER    AS AWAY_POINTS,
        g.HOME_SCORE    AS POINTS_SCORED
    FROM BASKETBALL_CURATION.CUR_GAME_FACT g
    JOIN BASKETBALL_CURATION.CUR_TEAM_DIM home
        ON g.HOME_TEAM_UUID = home.TEAM_UUID

    UNION ALL

    -- Away team
    SELECT
        away.TEAM_UUID,
        away.TEAM_NAME,
        g.GAME_UUID,
        NULL::NUMBER    AS HOME_POINTS,
        g.AWAY_SCORE    AS AWAY_POINTS,
        g.AWAY_SCORE    AS POINTS_SCORED
    FROM BASKETBALL_CURATION.CUR_GAME_FACT g
    JOIN BASKETBALL_CURATION.CUR_TEAM_DIM away
        ON g.AWAY_TEAM_UUID = away.TEAM_UUID
)
SELECT
    TEAM_UUID,
    TEAM_NAME,
    COUNT(DISTINCT GAME_UUID)          AS GAMES_PLAYED,     // COUNT
    AVG(HOME_POINTS)                   AS AVG_PPG_HOME,     // AVG
    AVG(AWAY_POINTS)                   AS AVG_PPG_AWAY,     // AVG
    AVG(POINTS_SCORED)                 AS AVG_PPG           // AVG
FROM ALL_GAMES
GROUP BY
    TEAM_UUID,
    TEAM_NAME;

// ---------- Aggregation Object #2 ---------- //

// Daily scoring (VIEW)
CREATE OR REPLACE VIEW BASKETBALL_AGGREGATION.AGG_DAILY_POINTS
TAG (BASKETBALL_CURATION.PROJECT = 'true') AS
SELECT
    d.DATE_FULL,
    d.DATE_DAY_WORD,
    d.DATE_WEEKEND,
    COUNT(DISTINCT g.GAME_UUID)                   AS GAMES_PLAYED,        // COUNT
    SUM(g.HOME_SCORE + g.AWAY_SCORE)              AS TOTAL_POINTS,        // SUM
    AVG(g.HOME_SCORE + g.AWAY_SCORE)              AS AVG_POINTS_PER_GAME  // AVG
FROM BASKETBALL_CURATION.CUR_GAME_FACT g
JOIN BASKETBALL_CURATION.CUR_DATE_DIM d
    ON g.DATE_KEY = d.DATE_KEY
GROUP BY
    d.DATE_FULL,
    d.DATE_DAY_WORD,
    d.DATE_WEEKEND;

// ---------- Aggregation Object #3 ---------- //

// Venue statistics (VIEW)
CREATE OR REPLACE VIEW BASKETBALL_AGGREGATION.AGG_VENUE_SUMMARY
TAG (BASKETBALL_CURATION.PROJECT = 'true') AS
SELECT
    loc.VENUE,
    COUNT(DISTINCT g.GAME_UUID)            AS GAMES_AT_VENUE,        // COUNT
    SUM(g.HOME_SCORE + g.AWAY_SCORE)       AS TOTAL_POINTS_AT_VENUE, // SUM
    AVG(g.HOME_SCORE + g.AWAY_SCORE)       AS AVG_POINTS_AT_VENUE    // AVG
FROM BASKETBALL_CURATION.CUR_GAME_FACT g
JOIN BASKETBALL_CURATION.CUR_LOCATION_DIM loc
    ON g.VENUE_UUID = loc.VENUE_UUID
GROUP BY
    loc.VENUE;

// ---------- Aggregation Object #4 ---------- //

// Season Overview (VIEW)
CREATE OR REPLACE VIEW BASKETBALL_AGGREGATION.AGG_SEASON_OVERVIEW
TAG (BASKETBALL_CURATION.PROJECT = 'true') AS
SELECT
    seas.SEASON,
    seas.COMPETITION,
    COUNT(DISTINCT g.GAME_UUID)                   AS TOTAL_GAMES,                 // COUNT
    MIN(g.HOME_SCORE + g.AWAY_SCORE)              AS MIN_TOTAL_POINTS_IN_GAME,    // MIN
    MAX(g.HOME_SCORE + g.AWAY_SCORE)              AS MAX_TOTAL_POINTS_IN_GAME,    // MAX
    AVG(g.HOME_SCORE + g.AWAY_SCORE)              AS AVG_POINTS_PER_GAME          // AVG
FROM BASKETBALL_CURATION.CUR_GAME_FACT g
JOIN BASKETBALL_CURATION.CUR_SEASON_DIM seas
    ON g.SEASON_UUID = seas.SEASON_UUID
GROUP BY
    seas.SEASON,
    seas.COMPETITION;

// ---------- Materialized View ---------- //

// Materialized view finding the teams in which have played at least 5 games and average over 90 or more points per game
CREATE OR REPLACE MATERIALIZED VIEW BASKETBALL_AGGREGATION.AGG_TOP_SCORING_TEAMS
TAG (BASKETBALL_CURATION.PROJECT = 'true') AS
SELECT
    TEAM_UUID,
    TEAM_NAME,
    GAMES_PLAYED,
    AVG_PPG,
    AVG_PPG_HOME,
    AVG_PPG_AWAY
FROM BASKETBALL_AGGREGATION.AGG_TEAM_STATS
WHERE GAMES_PLAYED >= 5      // only teams with enough games played
  AND AVG_PPG >= 90;         // only teams scoring on average more than 90
