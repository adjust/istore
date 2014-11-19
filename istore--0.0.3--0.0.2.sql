----operators----
DROP OPERATOR / (istore, int4);
----
DROP OPERATOR / (istore, istore);
----
DROP OPERATOR / (device_istore, device_istore);
----
DROP OPERATOR / (device_istore, int4);
----
DROP OPERATOR / (country_istore, int4);
----
DROP OPERATOR / (os_name_istore, int4);
----
DROP OPERATOR / (os_name_istore, os_name_istore);
----
DROP OPERATOR / (country_istore, country_istore);
----functions----
DROP FUNCTION divide(country_istore, integer);
----
DROP FUNCTION divide(country_istore, country_istore);
----
DROP FUNCTION fill_gaps(istore, integer, bigint DEFAULT 0);
----
DROP FUNCTION istore(integer[], integer[]);
----
DROP FUNCTION istore(integer[], bigint[]);
----
DROP FUNCTION divide(istore, integer);
----
DROP FUNCTION divide(istore, istore);
----
DROP FUNCTION each("is" istore, OUT key integer, OUT value bigint);
----
DROP FUNCTION divide(device_istore, integer);
----
DROP FUNCTION divide(device_istore, device_istore);
----
DROP FUNCTION divide(os_name_istore, integer);
----
DROP FUNCTION divide(os_name_istore, os_name_istore);
