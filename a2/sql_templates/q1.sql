-- Q1. Airlines

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
    pass_id INT,
    name VARCHAR(100),
    airlines INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.

-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS BookingFlight CASCADE;
CREATE VIEW BookingFlight AS
SELECT pass_id, flight_id, airline
FROM Booking, Flight
WHERE Booking.flight_id=Flight.id AND Booking.flight_id IN
    (SELECT flight_id FROM departure);

DROP VIEW IF EXISTS PassAirCount CASCADE;
CREATE VIEW PassAirCount AS
SELECT pass_id, count(distinct airline) airlines
FROM BookingFlight
GROUP BY pass_id;

DROP VIEW IF EXISTS PassNameAir CASCADE;
CREATE VIEW PassNameAir AS
SELECT PassAirCount.pass_id, firstname||surname, airlines
FROM Passenger LEFT JOIN PassAirCount
WHERE Passenger.id = PassAirCount.pass_id

-- Your query that answers the question goes below the "insert into" line:
--INSERT INTO q1
--SELECT * FROM PassNameAir;