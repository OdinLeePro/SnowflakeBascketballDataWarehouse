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
//                  Worksheet 5: Task                  //
// =================================================== //

// Task that runs stored procedures in Worksheet 2 every Sunday at 4am
CREATE OR REPLACE TASK BASKETBALL_CURATION.TASK_ENHANCE_FACT_TABLE
    WAREHOUSE = COYOTE_WH
    SCHEDULE = 'USING CRON 0 4 * * SUN America/Chicago'
AS
BEGIN
    CALL BASKETBALL_CURATION.SP_GAME_FACT_POINTS();
    CALL BASKETBALL_CURATION.SP_GAME_FACT_BLOWOUT();
END;
