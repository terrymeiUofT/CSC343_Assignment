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
DROP VIEW IF EXISTS MonRating CASCADE;
CREATE VIEW MonRating AS
SELECT monid, siteid, monrating FROM
Booking JOIN PastSession
ON Booking.id = PastSession.id;


-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q2
