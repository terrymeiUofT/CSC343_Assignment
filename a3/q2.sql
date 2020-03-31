-- Q2.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    monid INT NOT NULL PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    avg_fees DECIMAL NOT NULL,
    email VARCHAR(50) NOT NULL
);

-- Define views for your intermediate steps here:

-- for each site, calculate its average rating
DROP VIEW IF EXISTS SiteAvgRating CASCADE;
CREATE VIEW SiteAvgRating AS
SELECT siteid, avg(rating) site_avg
FROM SiteRating
GROUP BY siteid;

-- for each monitor, calculate his/her average rating
DROP VIEW IF EXISTS MonAvgRating CASCADE;
CREATE VIEW MonAvgRating AS
SELECT monid, avg(monrating) mon_avg FROM
    (SELECT monid, monrating FROM
    Booking JOIN PastSession
    ON Booking.id = PastSession.id) info
GROUP BY monid;

-- create a view of all monitor-site pair (not every possible one, but only
-- the ones that have a relationship), attached with the two avg rating
-- calculated above.
DROP VIEW IF EXISTS SiteMonRatings CASCADE;
CREATE VIEW SiteMonRatings AS
SELECT siteid, MonAvgRating.monid, site_avg, mon_avg FROM
    (SELECT SiteAvgRating.siteid, monid, site_avg FROM
        ((SELECT siteid, monid FROM MonitorWaterFee)
        UNION
        (SELECT siteid, monid FROM MonitorCaveFee)
        UNION
        (SELECT siteid, monid FROM MonitorDeepFee)) pair
    JOIN
        SiteAvgRating
    ON pair.siteid = SiteAvgRating.siteid) temp
JOIN
    MonAvgRating
ON temp.monid = MonAvgRating.monid;


-- for each monitor-site pair, calculate its average rating
DROP VIEW IF EXISTS MonRating CASCADE;
CREATE VIEW MonRating AS
SELECT monid, siteid, avg(monrating) avgrating FROM
    (SELECT monid, siteid, monrating FROM
    Booking JOIN PastSession
    ON Booking.id = PastSession.id) info
GROUP BY monid, siteid;

-- for each site, find the highest average rating
DROP VIEW IF EXISTS BestRating CASCADE;
CREATE VIEW BestRating AS
SELECT siteid, max(avgrating)
FROM MonRating
GROUP BY siteid;





-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q2
