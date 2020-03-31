-- Q1.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TYPE dive_type AS ENUM ('open', 'cave', 'deep');
CREATE TABLE q1 (
    divetype divetype NOT NULL PRIMARY KEY,
    num_site INT NOT NULL,
    monitor VARCHAR(50)
);

-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS OpenSite CASCADE;
CREATE VIEW OpenSite AS
SELECT count(*) num_site FROM Site
WHERE (max_daywater <> 0) OR (max_nightwater <> 0);



-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q1