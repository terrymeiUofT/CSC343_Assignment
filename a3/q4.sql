-- Q4.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO wetworldschema;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
    siteid INT PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL,
    high DECIMAL,
    low DECIMAL,
    average DECIMAL
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

-- for each site, compute the highest/lowest/average fee charged
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT Site.id, Site.name, high, low, average FROM
    (SELECT siteid, max(total_fee) as high, min(total_fee) as low,
    avg(total_fee) as average
    FROM TotalFee
    GROUP BY siteid) stats
RIGHT JOIN
Site ON siteid = id;