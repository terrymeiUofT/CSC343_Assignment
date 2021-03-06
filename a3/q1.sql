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
SELECT * FROM
    (SELECT CAST('open' AS dive_type) as divetype, count(*) num_site FROM Site
    WHERE (max_daywater <> 0) OR (max_nightwater <> 0)) SiteCount
CROSS JOIN
    (SELECT firstname as monitor FROM Monitor
    WHERE watersize <> 0 ORDER BY watersize DESC) OpenMonitor
LIMIT 1;

DROP VIEW IF EXISTS CaveSite CASCADE;
CREATE VIEW CaveSite AS
SELECT * FROM
    (SELECT CAST('cave' AS dive_type) as divetype, count(*) num_site FROM Site
    WHERE (max_daycave <> 0) OR (max_nightcave <> 0)) SiteCount
CROSS JOIN
    (SELECT firstname as monitor FROM Monitor
    WHERE cavesize <> 0 ORDER BY cavesize DESC) CaveMonitor
LIMIT 1;

DROP VIEW IF EXISTS DeepSite CASCADE;
CREATE VIEW DeepSite AS
SELECT * FROM
    (SELECT CAST('deep' AS dive_type) as divetype, count(*) num_site FROM Site
    WHERE (max_daydeep <> 0) OR (max_nightdeep <> 0)) SiteCount
CROSS JOIN
    (SELECT firstname as monitor FROM Monitor
    WHERE deepsize <> 0 ORDER BY deepsize DESC) DeepMonitor
LIMIT 1;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
(SELECT * FROM OpenSite)
UNION
(SELECT * FROM CaveSite)
UNION
(SELECT * FROM DeepSite);