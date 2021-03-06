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
EXTRACT(YEAR FROM s_dep) as dep_year, EXTRACT(DOY FROM s_dep) as dep_doy,
EXTRACT(YEAR FROM s_arv) as arv_year, EXTRACT(DOY FROM s_arv) as arv_doy
FROM Flight, Airport
WHERE outbound = code;

DROP VIEW IF EXISTS All_flight CASCADE;
CREATE VIEW All_flight AS
SELECT id, outbound, out_city, out_country, inbound, city in_city, country in_country, s_dep, s_arv
FROM Outcity_flight, Airport
WHERE inbound = code AND dep_year = 2020 AND dep_doy = 121 AND arv_year = 2020 AND arv_doy = 121;

DROP VIEW IF EXISTS Direct_flight CASCADE;
CREATE VIEW Direct_flight AS
SELECT id, outbound, out_city, out_country, inbound, in_city, in_country, s_dep, s_arv
FROM All_flight
WHERE out_country != in_country AND (out_country = 'Canada' OR out_country = 'USA')
AND (in_country = 'Canada' OR in_country = 'USA');

DROP VIEW IF EXISTS Direct_flight_info CASCADE;
CREATE VIEW Direct_flight_info AS
SELECT out_city outbound, in_city inbound, count(*) direct, MIN(s_arv) earliest
FROM Direct_flight
GROUP BY out_city, in_city;

DROP VIEW IF EXISTS Onecon_flight CASCADE;
CREATE VIEW Onecon_flight AS
SELECT F1.id f1id, F1.outbound, F1.out_city, F1.out_country, F1.inbound con, F1.in_city con_city, F1.in_country con_country, F1.s_dep,
F2.id f2id, F2.inbound dest, F2.in_city dest_city, F2.in_country dest_country, F2.s_arv
FROM All_flight F1, All_flight F2
WHERE F1.inbound = F2.outbound AND (F2.s_dep - F1.s_arv) >= time '00:30:00'
AND F1.out_country != F2.in_country AND (F1.out_country = 'Canada' OR F1.out_country = 'USA')
AND (F2.in_country = 'Canada' OR F2.in_country = 'USA');

DROP VIEW IF EXISTS Onecon_flight_info CASCADE;
CREATE VIEW Onecon_flight_info AS
SELECT out_city outbound, dest_city inbound, count(*) one_con, MIN(s_arv) earliest
FROM Onecon_flight
GROUP BY out_city, dest_city;

DROP VIEW IF EXISTS Twocon_flight CASCADE;
CREATE VIEW Twocon_flight AS
SELECT F1.id f1id, F1.outbound, F1.out_city, F1.out_country,
F1.inbound con, F1.in_city con_city, F1.s_dep,
F2.id f2id, F2.inbound con2, F2.in_city con2_city,
F3.id f3id, F3.inbound dest, F3.in_city dest_city, F3.in_country dest_country, F3.s_arv
FROM All_flight F1, All_flight F2, All_flight F3
WHERE F1.inbound = F2.outbound AND F2.inbound = F3.outbound
AND (F2.s_dep - F1.s_arv) >= time '00:30:00' AND (F3.s_dep - F2.s_arv) >= time '00:30:00'
AND F1.out_country != F3.in_country AND (F1.out_country = 'Canada' OR F1.out_country = 'USA')
AND (F3.in_country = 'Canada' OR F3.in_country = 'USA');

DROP VIEW IF EXISTS Twocon_flight_info CASCADE;
CREATE VIEW Twocon_flight_info AS
SELECT out_city outbound, dest_city inbound, count(*) two_con, MIN(s_arv) earliest
FROM Twocon_flight
GROUP BY out_city, dest_city;

DROP VIEW IF EXISTS City_pair CASCADE;
CREATE VIEW City_pair AS
SELECT DISTINCT C1.city outbound, C2.city inbound
FROM Airport C1, Airport C2
WHERE C1.city != C2.city AND (C1.country = 'Canada' OR C1.country = 'USA')
AND (C2.country = 'Canada' OR C2.country = 'USA');

DROP VIEW IF EXISTS Combined_info CASCADE;
CREATE VIEW Combined_info AS
SELECT City_pair.outbound, City_pair.inbound, coalesce(direct, 0) as direct, Dir.earliest earliest_dir
FROM Direct_flight_info Dir RIGHT JOIN City_pair
ON Dir.outbound = City_pair.outbound AND Dir.inbound = City_pair.inbound;

DROP VIEW IF EXISTS Combined_info2 CASCADE;
CREATE VIEW Combined_info2 AS
SELECT Combined_info.outbound, Combined_info.inbound, direct, coalesce(one_con, 0) as one_con,
earliest_dir, One.earliest earliest_one
FROM Combined_info LEFT JOIN Onecon_flight_info One
ON One.outbound = Combined_info.outbound AND One.inbound = Combined_info.inbound;

DROP VIEW IF EXISTS Combined_info3 CASCADE;
CREATE VIEW Combined_info3 AS
SELECT Combined_info2.outbound, Combined_info2.inbound, direct, one_con, coalesce(two_con, 0) as two_con,
earliest_dir, earliest_one, Two.earliest earliest_two
FROM Combined_info2 LEFT JOIN Twocon_flight_info Two
ON Two.outbound = Combined_info2.outbound AND Two.inbound = Combined_info2.inbound;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT outbound, inbound, direct, one_con, two_con,
LEAST(earliest_dir, earliest_one, earliest_two) as earliest
FROM Combined_info3;

