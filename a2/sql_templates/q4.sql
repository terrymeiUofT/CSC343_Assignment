-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.

-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS Departed_capacity CASCADE;
CREATE VIEW Departed_capacity AS
SELECT DISTINCT flight.airline, plane, (capacity_first + capacity_business + capacity_economy) as capacity
FROM flight, departure, plane
WHERE flight.id = departure.flight_id AND flight.plane = plane.tail_number;

DROP VIEW IF EXISTS Departed_booking CASCADE;
CREATE VIEW Departed_booking AS
SELECT flight.airline, plane, count.booked
FROM flight, departure,
    (SELECT flight_id, count(*) booked
    FROM booking GROUP BY flight_id) count
WHERE flight.id = departure.flight_id AND flight.id = count.flight_id;

DROP VIEW IF EXISTS Departed_percent CASCADE;
CREATE VIEW Departed_percent AS
SELECT C.airline, C.plane tail_number, (booked/capacity) as percentage
FROM Departed_capacity C, Departed_booking B
WHERE C.airline = B.airline AND C.plane = B.plane;

-- Your query that answers the question goes below the "insert into" line:
--INSERT INTO q4
