-- Q3.
-- Assumptions:
-- 1. The average fee charged per dive
--    = (The sum of past dives' total fee)/(number of dives)
--    The total fee of one dive accounts for all the fees occurred to the group.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    site_type VARCHAR(10) PRIMARY KEY NOT NULL,
    average_fee DECIMAL NOT NULL
);

-- Define views for your intermediate steps here:

-- Combine all prices a site charges in one table
DROP VIEW IF EXISTS SiteAllPrices CASCADE;
CREATE VIEW SiteAllPrices AS
SELECT temp.siteid, mor_w, aft_w, nit_w, mor_c, aft_c, nit_c,
SiteDeepPrice.morning as mor_d, SiteDeepPrice.afternoon as aft_d,
SiteDeepPrice.night as nit_d FROM
    (SELECT SiteWaterPrice.siteid, SiteWaterPrice.morning as mor_w,
    SiteWaterPrice.afternoon as aft_w, SiteWaterPrice.night as nit_w,
    SiteCavePrice.morning as mor_c, SiteCavePrice.afternoon as aft_c,
    SiteCavePrice.night as nit_c
    FROM SiteWaterPrice JOIN SiteCavePrice
    ON SiteWaterPrice.siteid = SiteCavePrice.siteid) temp
JOIN
    SiteDeepPrice
ON temp.siteid = SiteDeepPrice.siteid;

-- Get useful info on past sessions in one table
DROP VIEW IF EXISTS PastInfo CASCADE;
CREATE VIEW PastInfo AS
SELECT id, extraInfo.siteid, s_time, s_size, divetype, num_mask, num_regulator,
num_fins, num_divecomp, mask, regulator, fins, divecomp,
    CASE WHEN extract(hour from s_time) = '09' AND divetype = 'open' THEN mor_w
         WHEN extract(hour from s_time) = '12' AND divetype = 'open' THEN aft_w
         WHEN extract(hour from s_time) = '20' AND divetype = 'open' THEN nit_w
         WHEN extract(hour from s_time) = '09' AND divetype = 'cave' THEN mor_c
         WHEN extract(hour from s_time) = '12' AND divetype = 'cave' THEN aft_c
         WHEN extract(hour from s_time) = '20' AND divetype = 'cave' THEN nit_c
         WHEN extract(hour from s_time) = '09' AND divetype = 'deep' THEN mor_d
         WHEN extract(hour from s_time) = '12' AND divetype = 'deep' THEN aft_d
         WHEN extract(hour from s_time) = '20' AND divetype = 'deep' THEN nit_d
         END
         AS session_price
FROM
    (SELECT id, itemInfo.siteid, s_time, s_size, divetype, num_mask,
    num_regulator, num_fins, num_divecomp, mask, regulator, fins, divecomp
    FROM
        (SELECT PastSession.id, siteid, s_time, s_size, divetype, num_mask,
        num_regulator, num_fins, num_divecomp
        FROM PastSession JOIN Booking
        ON PastSession.id = Booking.id) itemInfo
    JOIN
        SiteExtraPrice
    ON itemInfo.siteid = SiteExtraPrice.siteid) extraInfo
JOIN
    SiteAllPrices
ON extrainfo.siteid = SiteAllPrices.siteid;

-- calculate the total fee for each past dive
DROP VIEW IF EXISTS TotalFee CASCADE;
CREATE VIEW TotalFee AS
SELECT id, siteid, (session_price + extra_price) as total_fee FROM
    (SELECT id, siteid, session_price, (num_mask*coalesce(mask, 0) +
    num_regulator*coalesce(regulator, 0) + num_fins*coalesce(fins, 0) +
    num_divecomp*coalesce(divecomp, 0)) as
    extra_price
    FROM PastInfo) temp;

-- Calculate Site Capacity per day
DROP VIEW IF EXISTS SiteCapacity CASCADE;
CREATE VIEW SiteCapacity AS
SELECT id, name, (max_daywater + max_nightwater + max_daycave + max_nightcave
+ max_daydeep + max_nightdeep) as capacity
FROM Site;

-- Find out Site occupancy for each booking
DROP VIEW IF EXISTS SiteOccupancy CASCADE;
CREATE VIEW SiteOccupancy AS
SELECT Booking.id, siteid, s_size
FROM Booking JOIN PastSession
ON Booking.id = PastSession.id;

-- Calculate average occupancy for each site
DROP VIEW IF EXISTS AvgOccupancy CASCADE;
CREATE VIEW AvgOccupancy AS
SELECT siteid, avg(s_size) avg_occ FROM SiteOccupancy
GROUP BY siteid;

-- Identify the sites that have avg occupancy that is above half of its capacity
DROP VIEW IF EXISTS FullerSites CASCADE;
CREATE VIEW FullerSites AS
SELECT siteid FROM
    (SELECT siteid, avg_occ, capacity
    FROM AvgOccupancy JOIN SiteCapacity
    ON siteid = id) temp
WHERE avg_occ > (0.5)*capacity;

-- The rest of the sites are the less full sites
DROP VIEW IF EXISTS LessFullSites CASCADE;
CREATE VIEW LessFullSites AS
(SELECT id FROM Site)
EXCEPT
(SELECT siteid FROM FullerSites);

-- assign site_type: {fuller, lessfull} to each past booking
DROP VIEW IF EXISTS SplitBookings CASCADE;
CREATE VIEW SplitBookings AS
(SELECT id, TotalFee.siteid, total_fee, 'fuller' as site_type
FROM TotalFee JOIN FullerSites
ON TotalFee.siteid = FullerSites.siteid)
UNION
(SELECT TotalFee.id, TotalFee.siteid, total_fee, 'lessfull' as site_type
FROM TotalFee JOIN LessFullSites
ON TotalFee.siteid = LessFullSites.id);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT site_type, avg(total_fee) average_fee FROM SplitBookings
GROUP BY site_type;