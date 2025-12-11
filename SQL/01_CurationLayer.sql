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
//             Worksheet 1: Curation Layer             //
// =================================================== //

// ---------- Create schema and Sementic Tag --------- //

// Create curation schema called BASKETBALL_CURATION
CREATE SCHEMA IF NOT EXISTS BASKETBALL_CURATION;

// Create project tag
CREATE TAG IF NOT EXISTS BASKETBALL_CURATION.PROJECT COMMENT = 'Tag for all tables and views in the curation schema of project';

// ------------------- Staging View ------------------ //

// Create and Curate Staging View 
CREATE OR REPLACE VIEW BASKETBALL_CURATION.SLV_BASKETBALL_STAGING
TAG (BASKETBALL_CURATION.PROJECT='true') AS
SELECT
    // -- DATE_DIM columns 
    DATE_TIME                                      AS DATE_TIMESTAMP,
    TO_DATE(DATE_TIME)                             AS DATE_FULL,
    YEAR(DATE_TIME)                                AS DATE_YEAR,
    QUARTER(DATE_TIME)                             AS DATE_QUARTER,
    MONTH(DATE_TIME)                               AS DATE_MONTH_NUMBER, 
    MONTHNAME(DATE_TIME)                           AS DATE_MONTH_WORD, 
    DAY(DATE_TIME)                                 AS DATE_DAY_NUMBER,
    DAYNAME(DATE_TIME)                             AS DATE_DAY_WORD,
    // If DATE_DAY_WORD equals "Sat" or "Sun" then DATE_WEEKEND equals Weekend otherwise returns Weekday
    IFF(DAYNAME(DATE_TIME) IN ('Sat', 'Sun'),
        'Weekend', 'Weekday')                      AS DATE_WEEKEND,

    // -- TEAM_DIM columns
    HOME_UUID                                      AS HOME_TEAM_UUID,
    AWAY_UUID                                      AS AWAY_TEAM_UUID, 
    HOME                                           AS HOME_TEAM,
    // When HOME_ABBRV is null, then use the first three letters in HOME
    CASE 
        WHEN HOME_SHORT IS NULL THEN UPPER(SUBSTRING(HOME, 1, 3))
        ELSE HOME_SHORT
    END                                            AS HOME_ABBRV,
    AWAY                                           AS AWAY_TEAM,
    // When AWAY_ABBRV is null, then use the first three letters in HOME
    CASE 
        WHEN AWAY_SHORT IS NULL THEN UPPER(SUBSTRING(AWAY, 1, 3))
        ELSE AWAY_SHORT
    END                                            AS AWAY_ABBRV,   
            
    // -- SEASON_DIM solumns
    TRIM(SEASON_UUID)                              AS SEASON_UUID, //PK
    SEASON                                         AS SEASON,
    TRIM(COMPETITION_UUID)                         AS COMPETITION_UUID,
    COMPETITION                                    AS COMPETITION,
    ROUND                                          AS ROUND,  

    // -- LOCATION_DIM columns
    TRIM(COUNTRY_UUID)                             AS COUNTRY_UUID, //PK
    COUNTRY                                        AS COUNTRY,
    TRIM(REGION_UUID)                              AS REGION_UUID,
    REGION                                         AS REGION,
    TRIM(VENUE_UUID)                               AS VENUE_UUID,
    VENUE                                          AS VENUE,    

    // -- GAME_FACT columns
    TRIM(GAME_UUID)                                AS GAME_UUID, //PK
    CAST(DATE_TIME AS TIME)                        AS GAME_TIME,
    HOME_SCORE                                     AS HOME_SCORE,      
    AWAY_SCORE                                     AS AWAY_SCORE, 
    HOME_SCORE - AWAY_SCORE                        AS HOME_POINT_DIFF, 
    AWAY_SCORE - HOME_SCORE                        AS AWAY_POINT_DIFF, 
    // When home score is greater than away score than Home Win and vise verse else Draw
    CASE 
        WHEN HOME_SCORE > AWAY_SCORE THEN 'Home Win'
        WHEN HOME_SCORE < AWAY_SCORE THEN 'Away Win'
        ELSE 'Draw'
    END                                            AS GAME_RESULT,
    STATUS                                         AS GAME_STATUS
FROM OPTA_DATA_BASKETBALL_SCHEDULE_AND_RESULTS_DATA__SAMPLE.BASKETBALL.FIXTURES;

// ----------- Create & Populate Dimensions ---------- //

// Create DATE_DIM
// - Create and Populate are seperate for DATE_DIM due to creating a sarrogate key
CREATE OR REPLACE TABLE BASKETBALL_CURATION.CUR_DATE_DIM 
TAG (BASKETBALL_CURATION.PROJECT='true') (
    DATE_KEY            NUMBER(8)   NOT NULL,
    DATE_FULL           DATE        NOT NULL,
    DATE_YEAR           INTEGER,
    DATE_QUARTER        INTEGER,
    DATE_MONTH_NUMBER   INTEGER,
    DATE_MONTH_WORD     STRING,
    DATE_DAY_NUMBER     INTEGER,
    DATE_DAY_WORD       STRING,
    DATE_WEEKEND        STRING
);

// Populate DATE_DIM
INSERT INTO BASKETBALL_CURATION.CUR_DATE_DIM (
    DATE_KEY,
    DATE_FULL,
    DATE_YEAR,
    DATE_QUARTER,
    DATE_MONTH_NUMBER,
    DATE_MONTH_WORD,
    DATE_DAY_NUMBER,
    DATE_DAY_WORD,
    DATE_WEEKEND
)
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(DATE_FULL, 'YYYYMMDD')) AS DATE_KEY,
    DATE_FULL,
    DATE_YEAR,
    DATE_QUARTER,
    DATE_MONTH_NUMBER,
    DATE_MONTH_WORD,
    DATE_DAY_NUMBER,
    DATE_DAY_WORD,
    DATE_WEEKEND
FROM BASKETBALL_CURATION.SLV_BASKETBALL_STAGING;

// Create/Populate TEAM_DIM
CREATE OR REPLACE TABLE BASKETBALL_CURATION.CUR_TEAM_DIM 
TAG (BASKETBALL_CURATION.PROJECT='true') AS
SELECT DISTINCT
    TEAM_UUID,
    TEAM_NAME,
    TEAM_ABBRV
FROM (
    -- Home teams
    SELECT
        HOME_TEAM_UUID AS TEAM_UUID,
        HOME_TEAM      AS TEAM_NAME,
        HOME_ABBRV     AS TEAM_ABBRV
    FROM BASKETBALL_CURATION.SLV_BASKETBALL_STAGING
    UNION
    -- Away teams
    SELECT
        AWAY_TEAM_UUID AS TEAM_UUID,
        AWAY_TEAM      AS TEAM_NAME,
        AWAY_ABBRV     AS TEAM_ABBRV
    FROM BASKETBALL_CURATION.SLV_BASKETBALL_STAGING
);

// Create/Populate SEASON_DIM
CREATE OR REPLACE TABLE BASKETBALL_CURATION.CUR_SEASON_DIM 
TAG (BASKETBALL_CURATION.PROJECT='true') AS
SELECT DISTINCT
    SEASON_UUID,
    SEASON,
    COMPETITION_UUID,
    COMPETITION
FROM BASKETBALL_CURATION.SLV_BASKETBALL_STAGING;

// Create/Populate LOCATION_DIM
CREATE OR REPLACE TABLE BASKETBALL_CURATION.CUR_LOCATION_DIM 
TAG (BASKETBALL_CURATION.PROJECT='true') AS
SELECT DISTINCT
    VENUE_UUID,
    VENUE,
    COUNTRY_UUID,
    COUNTRY,
    REGION_UUID,
    REGION    
FROM BASKETBALL_CURATION.SLV_BASKETBALL_STAGING;

// ---------- Create and Populate Fact Table --------- //

// Create/Populate GAME_FACT
CREATE OR REPLACE TABLE BASKETBALL_CURATION.CUR_GAME_FACT 
TAG (BASKETBALL_CURATION.PROJECT='true') AS
SELECT
    s.GAME_UUID,                        //PK

    d.DATE_KEY,                         //FK
    loc.VENUE_UUID,                     //FK
    seas.SEASON_UUID,                   //FK
    home.TEAM_UUID  AS HOME_TEAM_UUID,  //FK
    away.TEAM_UUID  AS AWAY_TEAM_UUID,  //FK

    s.ROUND,
    s.GAME_TIME,
    s.HOME_SCORE,
    s.AWAY_SCORE,
    s.HOME_POINT_DIFF,
    s.AWAY_POINT_DIFF,
    s.GAME_RESULT,
    s.GAME_STATUS
FROM BASKETBALL_CURATION.SLV_BASKETBALL_STAGING s
JOIN BASKETBALL_CURATION.CUR_DATE_DIM d
    ON d.DATE_FULL = s.DATE_FULL
JOIN BASKETBALL_CURATION.CUR_TEAM_DIM home
    ON home.TEAM_UUID = s.HOME_TEAM_UUID
JOIN BASKETBALL_CURATION.CUR_TEAM_DIM away
    ON away.TEAM_UUID = s.AWAY_TEAM_UUID
JOIN BASKETBALL_CURATION.CUR_SEASON_DIM seas
    ON seas.SEASON_UUID = s.SEASON_UUID
JOIN BASKETBALL_CURATION.CUR_LOCATION_DIM loc
    ON loc.VENUE_UUID = s.VENUE_UUID;
