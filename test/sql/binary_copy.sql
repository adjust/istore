CREATE TABLE before (a country);
INSERT INTO before values('de');
INSERT INTO before values('us');
INSERT INTO before values('es');
INSERT INTO before values('de');
INSERT INTO before values('zz');
CREATE TABLE after (a country);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;

CREATE TABLE before (a device_type);
INSERT INTO before values('bot');
INSERT INTO before values('console');
INSERT INTO before values('ipod');
INSERT INTO before values('ipod');
INSERT INTO before values('unknown');
CREATE TABLE after (a device_type);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;

CREATE TABLE before (a os_name);
INSERT INTO before values('android');
INSERT INTO before values('ios');
INSERT INTO before values('windows');
INSERT INTO before values('ios');
INSERT INTO before values('unknown');
CREATE TABLE after (a os_name);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;
