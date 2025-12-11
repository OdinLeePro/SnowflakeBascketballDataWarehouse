# SnowflakeBasketballDataWarehouse

SnowflakeBasketballDataWarehouse is a data curation and analytics project built on the OPTA Basketball Schedule and Results dataset from the Snowflake Marketplace. The project ingests, enhances, aggregates, and analyzes professional basketball game data using Snowflake SQL. It emphasizes structured workflows, reproducibility, semantic tagging, curated dimensional models, and multi-layer analytical processing across curation, aggregation, and scheduling tasks.

## Overview

This project was created to transform marketplace basketball data into a clean, enriched, and analytics ready model suitable for sports performance insights. The final outputs include curated dimension and fact tables, enrichment logic via stored procedures, multi-level aggregations, a table function, a scheduled task, and documentation summarizing the pipeline.

The workflow includes:

- Creating a curation layer with enriched date, team, location, and season dimensions  
- Building a structured fact table with point differentials, win/loss classification, and derived attributes  
- Applying additional enhancements via stored procedures  
- Constructing aggregated tables and views for team, venue, season, and daily scoring analytics  
- Creating a materialized view for fast retrieval of top-scoring teams  
- Implementing a reusable table function for team level statistical filtering  
- Automating pipeline execution through a Snowflake task  
- Producing a summary of logic, naming conventions, and data catalog details  

## Features

- **Curation Layer Construction** — Generates:
  - Date dimension with calendar attributes  
  - Team dimension with standardized names and derived abbreviations  
  - Season dimension  
  - Location dimension  
  - Game fact table with enriched metrics such as point differential, scoring level, and win classification  

- **Stored Procedure Enhancements** — Adds:
  - Total game points  
  - Scoring-level classification (High/Medium/Low)  
  - Blowout detection using a 20-point threshold  

- **Aggregation Layer** — Produces:
  - Team-level scoring averages  
  - Venue-level scoring summaries  
  - Daily points-per-game metrics  
  - Season-level scoring overview  

- **Materialized View** — Surfaces top-scoring teams (min. 5 games, ≥ 90 PPG) for rapid BI usage.

- **Table Function** — Returns filtered team statistics based on minimum games played.

- **Scheduled Task** — Runs enhancements weekly at 4 AM every Sunday.

- **Documentation** — Includes a written summary describing dataset context, naming conventions, and transformation logic.

## Project Structure

```
/SnowflakeBascketballDataWarehouse
├── Documents/
│   ├── Dashbard_Screenshots/
│   │   ├── Tile01.png
│   │   ├── Tile02.png
│   │   └── Tile03.png
│   └── ER_Diagram.png
├── SQL/
│   ├── 01_CurationLayer.sql
│   ├── 02_StoredProcedure.sql
│   ├── 03_AggregationLayer.sql
│   ├── 04_Function.sql
│   ├── 05_Task.sql
│   └── 06_Summary.sql
├── LICENSE
├── Project Instructions.pdf
└── README.md
```

## Data Sources

This project uses the OPTA Basketball Schedule and Results (Sample) dataset from the Snowflake Marketplace. The data includes:

- Game identifiers and UUIDs  
- Home and away teams  
- Scores and point differentials  
- Date, venue, competition, and season attributes  
- Status, round, and result fields  

Basketball domain knowledge (e.g., scoring thresholds, blowout conditions) was used to enrich and categorize raw game-level data.

## Key Outputs

### 1. Curated Data Model

A Snowflake-based dimensional model including:

- **CUR_DATE_DIM** — calendar attributes and surrogate keys  
- **CUR_TEAM_DIM** — standardized team info  
- **CUR_LOCATION_DIM** — venue and geography  
- **CUR_SEASON_DIM** — season & competition metadata  
- **CUR_GAME_FACT** — enriched fact table with:
  - Total points  
  - Win/loss result  
  - Point differential  
  - Weekend indicators  
  - Scoring level classification  
  - Blowout flag  

### 2. Aggregated Analytics

Multi-level analytical views and tables:

- Team-level scoring averages (PPG & split home/away metrics)  
- Daily points-per-game trends  
- Venue-level scoring summaries  
- Season scoring metrics  

### 3. Materialized View: Top-Scoring Teams

A performance-optimized object identifying high-scoring teams based on game count and PPG thresholds.

### 4. Table Function

A reusable function:

Returns rows for teams meeting the minimum game requirement with PPG and split scoring stats.

### 5. Scheduled Weekly Task

A Snowflake task that automatically executes data enhancement procedures every Sunday at 4 AM.

### 6. Summary Documentation

A structured write-up describing:

- Dataset details  
- Schema naming conventions  
- Tagging rules  
- Transformation logic  
- Data catalog notes  

## License

This project is licensed under the MIT License.
