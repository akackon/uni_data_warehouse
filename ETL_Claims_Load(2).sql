-- Populate the Dimension tables
-- Populate the fact table

-- first run the SS claims script to create the dimension and fact table

-- Now to populate the time_dim
DROP sequence time_seq;
create sequence time_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;

INSERT INTO time_dim VALUES( time_seq.nextval, '2011');
INSERT INTO time_dim VALUES( time_seq.nextval, '2010');
INSERT INTO time_dim VALUES( time_seq.nextval, '2012');
INSERT INTO time_dim VALUES( time_seq.nextval, '1960');

-- Now repeat similar for the location dimension table
--
DROP table tmp_locations;
Create table tmp_locations as SELECT DISTINCT state FROM S2_STAGEAREA;

DROP sequence loc_seq;
create sequence loc_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;

INSERT INTO location_dim SELECT loc_seq.nextval, state FROM tmp_locations;

-- Or use straight forward code as below
INSERT INTO location_dim VALUES (1, 'WA'); 

-- Populates the Fact table from the cleaned data sets
-- the report in sum of the claims per year
-- Coding approaches are discussed and evaluated
-- Solutions:
-- Option1: Create a detail table, then select from this.
-- Option2: Create a cart-prod of ids from time and location and then update on the fact table.

-- Option1 – solution as below
-- The fact_claims table

DROP sequence fact_seq;
create sequence FACT_SEQ
start with 1
increment by 1
maxvalue 10000
minvalue 1;


DROP table tmp_claim1;
-- this tmp table contains all data we need, with the year (not the whole date)
CREATE TABLE tmp_claim1 AS SELECT state, total_claim_amount, effective_to_date as which_year 
FROM S2_STAGEAREA;

DROP table tmp_claim2;
-- This tmp table contains the sum of the claim by year and state
CREATE TABLE tmp_claim2 AS
SELECT which_year, state, SUM(total_claim_amount) as claim_amount FROM tmp_claim1
GROUP BY which_year, state;

-- check the data
SELECT * FROM tmp_claim2;
SELECT * FROM time_dim;
SELECT * FROM location_dim;

INSERT INTO FACT_claim (report_id, fk1_time_id, fk2_location_id , total_claim_location)
SELECT fact_seq.nextval,  time_dim.time_id, location_dim.location_id, tmp_claim2.claim_amount
FROM tmp_claim2, time_dim, location_dim
WHERE tmp_claim2.which_year = time_dim.the_year AND tmp_claim2.state = location_dim.state;

-- Over to you to check run as reports

SELECT * FROM fact_claim

Lastly consider how data can be extracted from the SS tables and pulled into a visualisation tool, as we did with Excel.

