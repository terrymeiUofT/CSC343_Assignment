-- Q1.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
    divetype dive_type NOT NULL PRIMARY KEY,
    num_site INT NOT NULL,
    monitor VARCHAR(50)
);

-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS OpenSite CASCADE;
CREATE VIEW OpenSite AS
SELECT TOP 1 divetype, numsite, monitor FROM
    (SELECT 'open' as divetype, count(*) num_site FROM Site
    WHERE (max_daywater <> 0) OR (max_nightwater <> 0)) SiteCount
CROSS JOIN
    (SELECT firstname as monitor FROM Monitor
    WHERE watersize <> 0) OpenMonitor;



-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q1