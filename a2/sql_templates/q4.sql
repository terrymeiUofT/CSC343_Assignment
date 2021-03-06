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
SELECT departed.id, departed.airline, plane, (capacity_first + capacity_business + capacity_economy) as capacity
FROM Plane LEFT JOIN
    (SELECT flight.id, flight.airline, plane
    FROM flight LEFT JOIN departure
    ON flight.id = departure.flight_id) departed
ON Departed.plane = Plane.tail_number;

--DROP VIEW IF EXISTS Departed_capacity CASCADE;
--CREATE VIEW Departed_capacity AS
--SELECT DISTINCT flight.airline, plane, (capacity_first + capacity_business + capacity_economy) as capacity
--FROM flight, departure, plane
--WHERE flight.id = departure.flight_id AND flight.plane = plane.tail_number;

DROP VIEW IF EXISTS Departed_booking CASCADE;
CREATE VIEW Departed_booking AS
SELECT flight.id, flight.airline, plane, count.booked
FROM flight, departure,
    (SELECT flight_id, count(*) booked
    FROM booking GROUP BY flight_id) count
WHERE flight.id = departure.flight_id AND flight.id = count.flight_id;

DROP VIEW IF EXISTS Departed_percent CASCADE;
CREATE VIEW Departed_percent AS
SELECT C.id, C.airline, C.plane tail_number, coalesce((booked::float)/capacity, 0) as percentage
FROM Departed_capacity C LEFT JOIN Departed_booking B
ON C.airline = B.airline AND C.plane = B.plane;

DROP TABLE IF EXISTS Departed_hist CASCADE;
CREATE TABLE Departed_hist AS
SELECT * FROM Departed_percent;

ALTER Table Departed_hist
ADD COLUMN very_low INT DEFAULT 0;

ALTER Table Departed_hist
ADD COLUMN low INT DEFAULT 0;

ALTER Table Departed_hist
ADD COLUMN fair INT DEFAULT 0;

ALTER Table Departed_hist
ADD COLUMN normal INT DEFAULT 0;

ALTER Table Departed_hist
ADD COLUMN high INT DEFAULT 0;

DROP VIEW IF EXISTS Departed_result CASCADE;
CREATE VIEW Departed_result AS
SELECT id, airline, tail_number,
    CASE WHEN percentage > 0 AND percentage < 0.2 THEN 1
         ELSE 0 END
         AS very_low,
    CASE WHEN percentage >= 0.2 AND percentage < 0.4 THEN 1
         ELSE 0 END
         AS low,
    CASE WHEN percentage >= 0.4 AND percentage < 0.6 THEN 1
         ELSE 0 END
         AS fair,
    CASE WHEN percentage >= 0.6 AND percentage < 0.8 THEN 1
         ELSE 0 END
         AS normal,
    CASE WHEN percentage >= 0.8 THEN 1
         ELSE 0 END
         AS high
FROM Departed_hist;
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT airline, tail_number, SUM(very_low) as very_low, SUM(low) as low, SUM(fair) as fair,
SUM(normal) as normal, SUM(high) as high
FROM Departed_result GROUP BY airline, tail_number;