//////////////////////////////////////////////
// SnowflakeBascketballDataWarehouse
// OPTA_DATA_BASKETBALL_SCHEDULE_AND_RESULTS_DATA__SAMPLE
// Odin Lee
//////////////////////////////////////////////

// =================================================== //
//                 Worksheet 6: Summary                //
// =================================================== //

/*

Dataset Name:
    Basketball Schedule and Result Data 
    (OPTA_DATA_BASKETBALL_SCHEDULE_AND_RESULTS_DATA__SAMPLE)

Description:
    This dataset contains detailed basketball game level data from the 2022 FIBA EuroBasket Basketball tournement. 
The original datset consists of one singule table with 23 columns that provide descriptive attributes for each game, 
including team information, venue, competition details, and final scores. The dataset consisted of 76 rows, 
with each row representing each individual game played during the tournement.

Nameing Information:
    Schemas:
        BASKETBALL_CURATION 
            - Contains 5 curation tables (CUR_), 1 staging view (SLV_), 2 stored prcedures (SP_), and 1 task (TASK_)
        
        BASKETBALL_AGGREGATION 
            - Contains 1 aggregated table (AGG_), 4 aggregated views (AGG_), and 1 table function (FUN_)

    Naming Conventions:
        SLV_ - Stageing-Level View
        CUR_ - Curation Layer Tables
        AGG_ - Aggregation layer tables and views
        SP_ - Stored Procedures
        FUN_ - Table Functions

Mini Data Catalog:
    1. Date Enhancements
    
        DATE_YEAR, DATE_QUARTER, DATE_MONTH_NUMBER, DATE_DAY_NUMBER
            - Extracted from column DATE_TIME using Snowflake date functions
        
        DATE_MONTH_WORD, DATE_DAY_WORD
            - Human-readable month and weekday names.
            Functions: MONTHNAME() & DAYNAME()
        
        DATE_WEEKEND
            - Flag to identify if a game took place on a weekend or weekday
            Formula: IFF(DAYNAME(DATE_TIME) IN ('Sat','Sun'),'Weekend','Weekday')
    
    2. Team Field Enhancements
    
        HOME_ABBRV / AWAY_ABBRV
            - When a teams abbreviation is null then replace the null with the capitalized first three letters of the team name
            Formula: CASE WHEN HOME_SHORT IS NULL THEN SUBSTRING(HOME,1,3) ELSE HOME_SHORT END
        
    
    3. Game Result Logic
    
        HOME_POINT_DIFF / AWAY_POINT_DIFF
            - Simple subtraction between home and away scores.
    
        GAME_RESULT
            - Indicates whether the home team won, the away team won, or the game ended in a draw.
            Formula: CASE WHEN HOME_SCORE > AWAY_SCORE THEN 'Home Win' WHEN HOME_SCORE < AWAY_SCORE THEN 'Away Win' ELSE 'Draw' END
    
    4. Surrogate Date Key
    
        DATE_KEY
            - A surrogate key created for the Date Dimension due to the absence of a natural primary key in the source dataset.            
            Formula: TO_NUMBER(TO_CHAR(DATE_FULL,'YYYYMMDD'))

*/
