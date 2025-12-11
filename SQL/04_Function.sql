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
//                Worksheet 4: Function                //
// =================================================== //

// Function that takes in the perameter of a number and returns the stats of the teams that have played at least said number of games
CREATE OR REPLACE FUNCTION BASKETBALL_AGGREGATION.FUN_STATS_MIN_GAMES(min_games NUMBER)
RETURNS TABLE (
    TEAM_UUID       STRING,
    TEAM_NAME       STRING,
    GAMES_PLAYED    NUMBER,
    AVG_PPG         NUMBER,
    AVG_PPG_HOME    NUMBER,
    AVG_PPG_AWAY    NUMBER
)
LANGUAGE SQL
AS
$$
    SELECT
        TEAM_UUID,
        TEAM_NAME,
        GAMES_PLAYED,
        AVG_PPG,
        AVG_PPG_HOME,
        AVG_PPG_AWAY
    FROM BASKETBALL_AGGREGATION.AGG_TEAM_STATS
    WHERE GAMES_PLAYED >= min_games
$$;

// ---------- Calls for Function ---------- //

SELECT *
FROM TABLE(BASKETBALL_AGGREGATION.FUN_STATS_MIN_GAMES(6));
