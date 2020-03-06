-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

CREATE VIEW n AS
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
--INSERT INTO q5
--WITH RECURSIVE Flight_hopping AS (
--    (SELECT id, inbound node, s_arv node_arv, 1 as num_flights FROM Flight
--    WHERE outbound = 'YYZ' AND s_dep >= (SELECT day FROM day)
--    AND s_dep < (SELECT day FROM day) + time '24:00:00')
--    UNION ALL
--    (SELECT Flight.id, Flight.inbound node, Flight.s_arv node_arv, Flight_hopping.num_flights+1
--    FROM Flight, Flight_hopping
--    WHERE Flight.id = Flight_hopping.id
--    AND Flight.outbound = Flight_hopping.node
--    AND Flight.s_dep > Flight_hopping.node_arv
--    AND (Flight.s_dep < Flight_hopping.node_arv + time '24:00:00')
--    AND num_flights < (SELECT n FROM n))
--)
--
--SELECT node as destination, num_flights FROM Flight_hopping;

INSERT INTO q5
WITH RECURSIVE hops AS (
	(SELECT id as id1, inbound as ib, 1 as num, s_arv as a
		FROM flight
		where outbound = 'YYZ'
			AND s_dep >= (select day from day)
			AND s_dep < (select day + INTERVAL '24' HOUR from day))
	UNION ALL
	(SELECT id, inbound as ib, num + 1, a
		FROM hops NATURAL JOIN flight
		WHERE num < 2--(select n from n)
			AND outbound = ib
			AND s_dep > a
			AND s_dep <= a + INTERVAL '24' HOUR)
)

select ib as destination, num as num_flights
from hops;















