SET SEARCH_PATH TO wetworldschema;

INSERT INTO
Diver (id, firstname, surname, birthdate, email, certificate)
VALUES
    (1, 'Michael', 'Scott', '1967-03-15', 'michael@dm.org', 'PADI'),
    (2, 'Dwight', 'Schrute', '1976-07-06', 'dwight@dm.org', 'CMAS'),
    (3, 'Jim', 'Halpert', '1975-04-08', 'jim@dm.org', 'NAUI'),
    (4, 'Pam', 'Beesly', '1978-12-22', 'pam@dm.org', 'NAUI'),
    (5, 'Andy', 'Bernard', '1973-10-10', 'andy@dm.org', 'PADI'),
    (6, 'Phyllis', NULL, '1963-09-10', NULL, 'PADI'),
    (7, 'Oscar', NULL, '1977-08-08', NULL, 'PADI');

INSERT INTO
Monitor (id, firstname, email, watersize, cavesize, deepsize)
VALUES
    (1, 'Maria', 'maria.diving@gmail.com', 10, 5, 5),
    (2, 'John', 'john.diving@hotmail.com', 15, 5, 0),
    (3, 'Ben', 'ben.diving@outlook.com', 15, 8, 5);

INSERT INTO
Shift (monid, secondlast, lastshift)
VALUES
    (1, '2019-07-22 12:30:00', '2019-07-22 20:30:00'),
    (2, NULL, NULL),
    (3, '2019-07-23 09:30:00', '2019-07-24 09:30:00');

INSERT INTO
Site (id, name, loc, max_daywater, max_nightwater, max_daycave, max_nightcave,
max_daydeep, max_nightdeep)
VALUES
    (1, 'Bloody Bay Marine Park', 'Little Cayman', 10, 10, 10, 10, 10, 10),
    (2, 'Widow Makers Cave', 'Montego Bay', 10, 10, 10, 10, 10, 10),
    (3, 'Crystal Bay', 'Crystal Bay', 10, 10, 10, 10, 10, 10),
    (4, 'Batu Bolong', 'Batu Bolong', 10, 10, 10, 10, 10, 10);

INSERT INTO
SiteWaterPrice (siteid, morning, afternoon, night)
VALUES
    (1, 10, 10, 10),
    (2, 20, 20, 20),
    (3, 15, 15, 15),
    (4, 15, 15, 15);

INSERT INTO
SiteCavePrice (siteid, morning, afternoon, night)
VALUES
    (1, 15, 15, 15),
    (2, 25, 25, 25),
    (3, 20, 20, 20),
    (4, 20, 20, 20);

INSERT INTO
SiteDeepPrice (siteid, morning, afternoon, night)
VALUES
    (1, 20, 20, 20),
    (2, 40, 40, 40),
    (3, 30, 30, 30),
    (4, 30, 30, 30);

INSERT INTO
SiteExtraPrice (siteid, mask, regulator, fins, divecomp)
VALUES
    (1, 5, NULL, 10, NULL),
    (2, 3, NULL, 5, NULL),
    (3, NULL, NULL, 5, 20),
    (4, 10, NULL, NULL, 30);

INSERT INTO
MonitorWaterFee (siteid, monid, morning, afternoon, night)
VALUES
    (1, 1, 20, 20, 20),
    (1, 2, 21, 21, 21),
    (1, 3, 22, 22, 22),
    (2, 1, 20, 20, 20),
    (2, 2, 21, 21, 21),
    (2, 3, 22, 22, 22),
    (3, 1, 10, 10, 10),
    (3, 2, 21, 21, 21),
    (3, 3, 22, 22, 22),
    (4, 1, 20, 20, 20),
    (4, 2, 21, 21, 21),
    (4, 3, 22, 22, 22);

INSERT INTO
MonitorCaveFee (siteid, monid, morning, afternoon, night)
VALUES
    (1, 1, 20, 20, 20),
    (1, 2, 21, 21, 21),
    (1, 3, NULL, NULL, NULL),
    (2, 1, 20, 20, 20),
    (2, 2, 21, 21, 21),
    (2, 3, 22, 22, 22),
    (3, 1, 10, 10, 10),
    (3, 2, 21, 21, 21),
    (3, 3, 22, NULL, 22),
    (4, 1, 20, 20, 20),
    (4, 2, NULL, 21, 21),
    (4, 3, 22, 22, 22);

INSERT INTO
MonitorDeepFee (siteid, monid, morning, afternoon, night)
VALUES
    (1, 1, 20, 20, 20),
    (1, 2, 21, 21, 21),
    (1, 3, 22, 22, 22),
    (2, 1, 20, NULL, 20),
    (2, 2, 21, 21, 21),
    (2, 3, 22, 22, 22),
    (3, 1, 10, 10, 10),
    (3, 2, NULL, 21, 21),
    (3, 3, 22, 22, 22),
    (4, 1, 20, 20, 20),
    (4, 2, 21, 21, 21),
    (4, 3, 22, 22, 22);

INSERT INTO
Booking (id, leadid, monid, siteid, s_time, s_size, divetype, num_mask,
num_regulator, num_fins, num_divecomp)
VALUES
    (1, 1, 1, 2, '2019-07-20 09:30:00', 5, 'open', 0, 0, 0, 0),
    (2, 1, 1, 2, '2019-07-21 09:30:00', 3, 'cave', 0, 0, 0, 0),
    (3, 1, 3, 1, '2019-07-22 09:30:00', 2, 'cave', 0, 0, 0, 0),
    (4, 1, 1, 1, '2019-07-22 20:30:00', 1, 'cave', 0, 0, 0, 0),
    (5, 5, 1, 2, '2019-07-22 12:30:00', 7, 'open', 0, 0, 0, 0),
    (6, 5, 3, 1, '2019-07-23 09:30:00', 1, 'cave', 0, 0, 0, 0),
    (7, 5, 3, 1, '2019-07-24 09:30:00', 1, 'cave', 0, 0, 0, 0);

INSERT INTO
Lead (bookingid, leadid, cardnumber, expirymonth, expiryday, cvv)
VALUES
    (1, 1, '1234567812345678', 01, 01, 123),
    (2, 1, '1234567812345678', 01, 01, 123),
    (3, 1, '1234567812345678', 01, 01, 123),
    (4, 1, '1234567812345678', 01, 01, 123),
    (5, 5, '4321432143214321', 12, 31, 321),
    (6, 5, '4321432143214321', 12, 31, 321),
    (7, 5, '4321432143214321', 12, 31, 321);

INSERT INTO
MemberTable (bookingid, diverid)
VALUES
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (2, 2),
    (2, 3),
    (3, 3),
    (5, 1),
    (5, 2),
    (5, 3),
    (5, 4),
    (5, 6),
    (5, 7);

INSERT INTO
PastSession (id, monrating, leadrating)
VALUES
    (1, 2, 4),
    (2, 0, 4),
    (3, 5, 4),
    (4, 2, 4),
    (5, 1, 3),
    (6, 0, 3),
    (7, 2, 3);

INSERT INTO
SiteRating (id, diverid, siteid, rating)
VALUES
    (1, 3, 1, 3),
    (2, 2, 2, 0),
    (3, 4, 2, 1),
    (4, 3, 2, 2),
    (5, 5, 3, 4),
    (6, 4, 3, 5),
    (7, 1, 3, 2),
    (8, 7, 3, 3);