-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.

-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS Outcity_flight CASCADE;
CREATE VIEW Outcity_flight AS
SELECT id, outbound, city out_city, country out_country, inbound, s_dep, s_arv,
EXTRACT(YEAR FROM s_dep) as year, EXTRACT(DOY FROM s_dep) as doy
FROM Flight, Airport
WHERE outbound = code;

DROP VIEW IF EXISTS All_flight CASCADE;
CREATE VIEW All_flight AS
SELECT id, outbound, out_city, out_country, inbound, city in_city, country in_country, s_dep, s_arv
FROM Outcity_flight, Airport
WHERE inbound = code AND year = 2020 AND doy = 121;

DROP VIEW IF EXISTS Direct_flight CASCADE;
CREATE VIEW Direct_flight AS
SELECT id, outbound, out_city, out_country, inbound, in_city, in_country, s_dep, s_arv
FROM All_flight
WHERE out_country != in_country AND (out_country = 'Canada' || out_country = 'USA')
AND (in_country = 'Canada' || in_country = 'USA');

--DROP VIEW IF EXISTS Direct_flight CASCADE;
--CREATE VIEW Direct_flight AS
--SELECT

-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q3
