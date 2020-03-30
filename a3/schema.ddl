-- Wet World Schema.
--
-- Assumptions:
-- 1. A monitor could also be a diver, but when a monitor tries to book
--    a diving session, he/she will register as a diver and the information
--    will be created and stored in the Diver table. He/She would also need
--    to book a monitor to complete the booking.
--
-- 2. A dive site always offer open water dive, with different pricing for
--    morning, afternoon, and night sessions. A dive site might additionally
--    offer cave dive and/or deep dive (deeper than 30m), with a separate set of
--    pricing for morning, afternoon, and night sessions.
--
-- 3. While a monitor may be affliated with (have privileges at) some sites,
--    any monitor should be able to work at any site. The privileges some
--    monitors have might lead to a more competitive price for monitoring at
--    the affliated sites. However, this condition is not enforced in this
--    schema.
--
-- 4. The restriction on monitors to only work 2 shifts in any 24-hour period
--    is also not enforced by this schema design. Instead, a table called
--    'Shift' is designated to record the last 2 shifts completed by any
--    monitors. The assumption here is that the application will check the
--    eligibility of a monitor when he/she is being booked for a new
--    session; and the application will also update the information in the
--    Shift table when a session is completed.

drop schema if exists wetworldschema cascade;
create schema wetworldschema;
set search_path to wetworldschema;


-- A diver
CREATE TYPE certificate AS ENUM ('NAUI', 'CMAS', 'PADI');
CREATE TABLE Diver (
  id INT PRIMARY KEY,
  -- The first name of the diver.
  firstname VARCHAR(50) NOT NULL,
  -- The surname of the diver.
  surname VARCHAR(50),
  -- The birth date of the diver.
  birthdate date NOT NULL,
  -- The email of the diver.
  email varchar(30),
  -- The certification of the diver.
  certificate certificate NOT NULL
);

-- A dive monitor.
CREATE TABLE Monitor (
  id INT PRIMARY KEY,
  -- The first name of the monitor.
  firstname VARCHAR(50) NOT NULL,
  -- The maximum group size a monitor is willing to take for each category.
  -- The monitor does not accept bookings to a type of dive if the maximum
  -- capacity is zero.
  watersize INT NOT NULL,
  cavesize INT NOT NULL,
  deepsize INT NOT NULL
);

-- A shift table for monitors.
CREATE TABLE Shift (
  monid INT KEY REFERENCES Monitor,
  -- the timestamp of last two shifts
  secondlast timestamp,
  lastshift timestamp
);

-- A dive site.
CREATE TABLE Site (
  id INT PRIMARY KEY,
  -- The name of the dive site.
  name VARCHAR(50) NOT NULL,
  -- The location of the dive site.
  loc VARCHAR(50) NOT NULL,
  -- The maximum capacity for daylight and night hour of open water/cave/deep
  -- at a site. The site does not provide the corresponding type of dive
  -- if the maximum capacity is zero.
  max_daywater INT NOT NULL,
  max_nightwater INT NOT NULL,
  max_daycave INT NOT NULL,
  max_nightcave INT NOT NULL,
  max_daydeep INT NOT NULL,
  max_nightdeep INT NOT NULL
);


-- A dive site's price list
-- categorized into 3 tables by the dive types to reduce null values
CREATE TABLE SiteWaterPrice (
  siteid INT PRIMARY KEY REFERENCES Site,
  -- The morning/afternoon/night open water diving price per diver.
  morning DECIMAL NOT NULL,
  afternoon DECIMAL NOT NULL,
  night DECIMAL NOT NULL
);

CREATE TABLE SiteCavePrice (
  siteid INT PRIMARY KEY REFERENCES Site,
  -- The morning/afternoon/night cave diving price per diver.
  morning DECIMAL NOT NULL,
  afternoon DECIMAL NOT NULL,
  night DECIMAL NOT NULL
);

CREATE TABLE SiteDeepPrice (
  siteid INT PRIMARY KEY REFERENCES Site,
  -- The morning/afternoon/night deep diving (>30m) price per diver.
  morning DECIMAL NOT NULL,
  afternoon DECIMAL NOT NULL,
  night DECIMAL NOT NULL
);

CREATE TABLE SiteExtraPrice (
  siteid INT PRIMARY EKY REFERENCES Site,
  -- The price for additional rental items.
  -- The value is NULL if such an item is not provided at a site.
  mask DECIMAL,
  regulator DECIMAL,
  fins DECIMAL,
  divecomp DECIMAL
);

-- A list of monitors' fees at different sites and times
-- categorized into 3 tables by dive types to reduce null values
CREATE TABLE MonitorWaterFee (
  siteid INT REFERENCES Site,
  monid INT REFERENCES Monitor,
  morning DECIMAL,
  afternoon DECIMAL,
  night DECIMAL,
  UNIQUE (siteid, monid)
);

CREATE TABLE MonitorCaveFee (
  siteid INT REFERENCES Site,
  monid INT REFERENCES Monitor,
  morning DECIMAL,
  afternoon DECIMAL,
  night DECIMAL,
  UNIQUE (siteid, monid)
);

CREATE TABLE MonitorDeepFee (
  siteid INT REFERENCES Site,
  monid INT REFERENCES Monitor,
  morning DECIMAL,
  afternoon DECIMAL,
  night DECIMAL,
  UNIQUE (siteid, monid)
);


-- A booking to a diving session.
CREATE TYPE dive_type AS ENUM ('open', 'cave', 'deep');
CREATE TABLE Booking (
  id INT PRIMARY KEY,
  leadid INT REFERENCES Diver,
  monid INT REFERENCES Monitor,
  siteid INT REFERENCES Site,
  -- The date and time of this booking.
  time timestamp NOT NULL,
  -- The group size of this booking.
  size INT NOT NULL,
  -- The dive type of this booking.
  divetype dive_type NOT NULL,
  -- The additional rental items for this booking.
  -- If non is used, the corresponding value is zero.
  num_mask INT NOT NULL,
  num_regulator INT NOT NULL,
  num_fins INT NOT NULL,
  num_divecomp INT NOT NULL
);

-- A lead
CREATE TABLE Lead (
  -- The diver is the lead of this booking.
  bookingid INT PRIMARY KEY REFERENCES Booking,
  leadid INT REFERENCES Diver,
  -- The credit card info of the lead diver.
  cardnumber VARCHAR(16) NOT NULL,
  expirymonth INT NOT NULL,
  expiryday INT NOT NULL,
  cvv INT NOT NULL
);

-- A table to list every non-lead member for each diving session
CREATE TABLE MemberTable (
  bookingid INT NOT NULL REFERENCES Booking,
  diverid INT NOT NULL REFERENCES Diver,
  UNIQUE (bookingid, diverid)
);

-- A diving session that actually took place.
CREATE TABLE PastSession (
  id INT PRIMARY KEY REFERENCES Booking,
  -- The rating for the monitor by the lead.
  monrating INT,
  -- The rating for the lead by the monitor.
  leadrating INT
);

-- A table to record the rating on a dive site by a diver.
CREATE TABLE SiteRating (
  id INT PRIMARY KEY,
  diverid INT NOT NULL REFERENCES Diver,
  siteid INT NOT NULL REFERENCES Site,
  rating INT NOT NULL
);