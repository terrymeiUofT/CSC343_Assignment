-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.


-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS OutCountry CASCADE;
CREATE VIEW OutCountry AS
SELECT id, airline, outbound, country out_country, inbound, s_dep, s_arv
FROM Flight, Airport
WHERE Flight.outbound = Airport.code;

DROP VIEW IF EXISTS InCountry CASCADE;
CREATE VIEW InCountry AS
SELECT id, airline, outbound, out_country, inbound, country as in_country, s_dep, s_arv
FROM OutCountry, Airport
WHERE OutCountry.inbound = Airport.code;

DROP VIEW IF EXISTS InternationalFlight CASCADE;
CREATE VIEW InternationalFlight AS
SELECT id, airline, out_country, in_country, s_dep, s_arv
FROM InCountry
WHERE out_country != in_country;

DROP VIEW IF EXISTS DomesticFlight CASCADE;
CREATE VIEW DomesticFlight AS
SELECT id, airline, out_country, in_country, s_dep, s_arv
FROM InCountry
WHERE out_country = in_country;

DROP VIEW IF EXISTS Inter_Actual CASCADE;
CREATE VIEW Inter_Actual AS
SELECT id fid, airline, out_country, in_country, s_dep, s_arv, Departure.datetime a_dep, Arrival.datetime a_arv
FROM InternationalFlight, Departure, Arrival
WHERE id = Departure.flight_id AND id = Arrival.flight_id;

DROP VIEW IF EXISTS Dome_Actual CASCADE;
CREATE VIEW Dome_Actual AS
SELECT id fid, airline, out_country, in_country, s_dep, s_arv, Departure.datetime a_dep, Arrival.datetime a_arv
FROM DomesticFlight, Departure, Arrival
WHERE id = Departure.flight_id AND id = Arrival.flight_id;

DROP VIEW IF EXISTS InterFlight_delay CASCADE;
CREATE VIEW InterFlight_delay AS
SELECT *, a_dep - s_dep dep_delay, a_arv - s_arv arv_delay
FROM Inter_Actual;

DROP VIEW IF EXISTS DomeFlight_delay CASCADE;
CREATE VIEW DomeFlight_delay AS
SELECT *, a_dep - s_dep dep_delay, a_arv - s_arv arv_delay
FROM Dome_Actual;

DROP VIEW IF EXISTS InterFlight_price CASCADE;
CREATE VIEW InterFlight_price AS
SELECT fid, airline, out_country, in_country, s_dep, dep_delay, arv_delay, Booking.seat_class, Booking.price
FROM InterFlight_delay, Booking
WHERE fid = flight_id;

DROP VIEW IF EXISTS DomeFlight_price CASCADE;
CREATE VIEW DomeFlight_price AS
SELECT fid, airline, out_country, in_country, s_dep, dep_delay, arv_delay, Booking.seat_class, Booking.price
FROM DomeFlight_delay, Booking
WHERE fid = flight_id;

DROP VIEW IF EXISTS InterFlight_refund_35 CASCADE;
CREATE VIEW InterFlight_refund_35 AS
SELECT fid, airline, s_dep, dep_delay, arv_delay, seat_class, price, 0.35*price refund
FROM InterFlight_price
WHERE (time '07:00:00' <= dep_delay) AND (time '12:00:00' > dep_delay) AND (arv_delay > 0.5*dep_delay);

DROP VIEW IF EXISTS InterFlight_refund_50 CASCADE;
CREATE VIEW InterFlight_refund_50 AS
SELECT fid, airline, s_dep, dep_delay, arv_delay, seat_class, price, 0.5*price refund
FROM InterFlight_price
WHERE (time '12:00:00' <= dep_delay) AND (arv_delay > 0.5*dep_delay);

DROP VIEW IF EXISTS DomeFlight_refund_35 CASCADE;
CREATE VIEW DomeFlight_refund_35 AS
SELECT fid, airline, s_dep, dep_delay, arv_delay, seat_class, price, 0.35*price refund
FROM DomeFlight_price
WHERE (time '04:00:00' <= dep_delay) AND (time '10:00:00' > dep_delay) AND (arv_delay > 0.5*dep_delay);

DROP VIEW IF EXISTS DomeFlight_refund_50 CASCADE;
CREATE VIEW DomeFlight_refund_50 AS
SELECT fid, airline, s_dep, dep_delay, arv_delay, seat_class, price, 0.5*price refund
FROM DomeFlight_price
WHERE (time '10:00:00' <= dep_delay) AND (arv_delay > 0.5*dep_delay);

DROP VIEW IF EXISTS Flight_refund CASCADE;
CREATE VIEW Flight_refund AS
(SELECT * FROM InterFlight_refund_35)
UNION
(SELECT * FROM InterFlight_refund_50)
UNION
(SELECT * FROM DomeFlight_refund_35)
UNION
(SELECT * FROM DomeFlight_refund_50);
-- Your query that answers the question goes below the "insert into" line:
--INSERT INTO q2
