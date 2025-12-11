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
//            Worksheet 2: Stored Procedure            //
// =================================================== //

// ---------- Stored Procedure #1 ---------- //

// Add TOTAL_POINTS and SCORING_LEVEL
CREATE OR REPLACE PROCEDURE BASKETBALL_CURATION.SP_GAME_FACT_POINTS()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    -- Add columns if they don't exist yet
    ALTER TABLE BASKETBALL_CURATION.CUR_GAME_FACT 
        ADD COLUMN IF NOT EXISTS TOTAL_POINTS NUMBER;

    ALTER TABLE BASKETBALL_CURATION.CUR_GAME_FACT 
        ADD COLUMN IF NOT EXISTS SCORING_LEVEL STRING;

    -- Populate / refresh values
    UPDATE BASKETBALL_CURATION.CUR_GAME_FACT
    SET TOTAL_POINTS = HOME_SCORE + AWAY_SCORE,
        SCORING_LEVEL = CASE 
            WHEN HOME_SCORE + AWAY_SCORE >= 200 THEN 'High'
            WHEN HOME_SCORE + AWAY_SCORE BETWEEN 150 AND 199 THEN 'Medium'
            ELSE 'Low'
        END;

    RETURN 'CUR_GAME_FACT successfully enhanced with TOTAL_POINTS and SCORING_LEVEL by SP_GAME_FACT_POINTS';
END;
$$;

// ---------- Stored Procedure #2 ---------- //

// Blowout flag (Team wins by 20+)
CREATE OR REPLACE PROCEDURE BASKETBALL_CURATION.SP_GAME_FACT_BLOWOUT()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    ALTER TABLE BASKETBALL_CURATION.CUR_GAME_FACT 
        ADD COLUMN IF NOT EXISTS BLOWOUT STRING;

    UPDATE BASKETBALL_CURATION.CUR_GAME_FACT
    SET BLOWOUT = CASE 
        WHEN ABS(HOME_POINT_DIFF) >= 20 THEN 'Y'
        ELSE 'N'
    END;

    RETURN 'CUR_GAME_FACT successfully enhanced with BLOWOUT by SP_GAME_FACT_BLOWOUT';
END;
$$;

// ---------- Calls for stored procedures ---------- //

CALL BASKETBALL_CURATION.SP_GAME_FACT_POINTS();

CALL BASKETBALL_CURATION.SP_GAME_FACT_BLOWOUT();
