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

CREATE TABLE before (a istore);
INSERT INTO before values('1=>1');
INSERT INTO before values('1=>2');
INSERT INTO before values('1=>3');
INSERT INTO before values('2=>1');
INSERT INTO before values('2=>NULL');
INSERT INTO before values('2=>2');
CREATE TABLE after (a istore);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;

CREATE TABLE before (a country_istore);
INSERT INTO before values('de=>1');
INSERT INTO before values('es=>2');
INSERT INTO before values('de=>3');
INSERT INTO before values('us=>1');
INSERT INTO before values('zz=>2');
INSERT INTO before values('de=>NULL');
CREATE TABLE after (a country_istore);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;

CREATE TABLE before (a device_istore);
INSERT INTO before values('bot=>1');
INSERT INTO before values('phone=>2');
INSERT INTO before values('bot=>3');
INSERT INTO before values('resolver=>1');
INSERT INTO before values('server=>2');
INSERT INTO before values('server=>NULL');
CREATE TABLE after (a device_istore);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;

CREATE TABLE before (a os_name_istore);
INSERT INTO before values('android=>1');
INSERT INTO before values('windows=>2');
INSERT INTO before values('android=>3');
INSERT INTO before values('ios=>1');
INSERT INTO before values('unknown=>2');
INSERT INTO before values('ios=>NULL');
CREATE TABLE after (a os_name_istore);
COPY after
FROM PROGRAM 'psql -U postgres -c "COPY before TO STDOUT WITH (FORMAT binary)" contrib_regression '
WITH (FORMAT binary);
SELECT * FROM after;
DROP TABLE before;
DROP TABLE after;

