----operators----
DROP OPERATOR IF EXISTS / (istore, int4);
----
DROP OPERATOR IF EXISTS / (istore, istore);
----
DROP OPERATOR IF EXISTS / (istore, int8);
----
DROP OPERATOR IF EXISTS / (device_istore, int8);
----
DROP OPERATOR IF EXISTS / (device_istore, int4);
----
DROP OPERATOR IF EXISTS / (device_istore, device_istore);
----
DROP OPERATOR IF EXISTS / (country_istore, int8);
----
DROP OPERATOR IF EXISTS / (country_istore, int4);
----
DROP OPERATOR IF EXISTS / (os_name_istore, int8);
----
DROP OPERATOR IF EXISTS / (os_name_istore, int4);
----
DROP OPERATOR IF EXISTS / (os_name_istore, os_name_istore);
----
DROP OPERATOR IF EXISTS / (country_istore, country_istore);
----functions----
DROP FUNCTION IF EXISTS divide(country_istore, bigint);
----
DROP FUNCTION IF EXISTS divide(country_istore, integer);
----
DROP FUNCTION IF EXISTS divide(country_istore, country_istore);
----
DROP FUNCTION IF EXISTS fill_gaps(istore, integer, bigint);
----
DROP FUNCTION IF EXISTS istore(integer[], integer[]);
----
DROP FUNCTION IF EXISTS istore(integer[], bigint[]);
----
DROP FUNCTION IF EXISTS divide(istore, bigint);
----
DROP FUNCTION IF EXISTS divide(istore, integer);
----
DROP FUNCTION IF EXISTS divide(istore, istore);
----
DROP FUNCTION IF EXISTS each("is" istore, OUT key integer, OUT value bigint);
----
DROP FUNCTION IF EXISTS divide(device_istore, bigint);
----
DROP FUNCTION IF EXISTS divide(device_istore, integer);
----
DROP FUNCTION IF EXISTS divide(device_istore, device_istore);
----
DROP FUNCTION IF EXISTS divide(os_name_istore, bigint);
----
DROP FUNCTION IF EXISTS divide(os_name_istore, integer);
----
DROP FUNCTION IF EXISTS divide(os_name_istore, os_name_istore);
