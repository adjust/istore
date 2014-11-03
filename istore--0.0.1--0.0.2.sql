OPERATOR CLASS device_type_ops USING btree;
OPERATOR CLASS device_type_ops USING hash;

OPERATOR CLASS country_ops USING btree;
OPERATOR CLASS country_ops USING hash;

OPERATOR CLASS os_name_ops USING btree;
OPERATOR CLASS os_name_ops USING hash;

DROP OPERATOR OPERATOR = (device_type, device_type);
DROP OPERATOR OPERATOR = (country, country);
DROP OPERATOR OPERATOR = (os_name, os_name);

----
CREATE OR REPLACE FUNCTION hashcountry(country)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$hashcountry$function$;

----
CREATE OR REPLACE FUNCTION hashdevice_type(device_type)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$hashdevice_type$function$;

----
CREATE OR REPLACE FUNCTION hashos_name(os_name)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$hashos_name$function$;



CREATE OPERATOR = (
    leftarg = device_type, rightarg = device_type, procedure = device_type_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel, HASHES, MERGES
);

CREATE OPERATOR = (
    leftarg = os_name, rightarg = os_name, procedure = os_name_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel, HASHES, MERGES
);

CREATE OPERATOR = (
    leftarg = country, rightarg = country, procedure = country_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel, HASHES, MERGES
);


CREATE OPERATOR CLASS country_ops
    DEFAULT FOR TYPE country USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       country_cmp(country,country);

CREATE OPERATOR CLASS country_ops
    DEFAULT FOR TYPE country USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hashcountry(country);

CREATE OPERATOR CLASS os_name_ops
    DEFAULT FOR TYPE os_name USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       os_name_cmp(os_name,os_name);

CREATE OPERATOR CLASS os_name_ops
    DEFAULT FOR TYPE os_name USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hashos_name(os_name);

CREATE OPERATOR CLASS device_type_ops
    DEFAULT FOR TYPE device_type USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       device_type_cmp(device_type,device_type);

CREATE OPERATOR CLASS device_type_ops
    DEFAULT FOR TYPE device_type USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hashdevice_type(device_type);

