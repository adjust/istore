DROP OPERATOR CLASS device_type_ops USING btree;
DROP OPERATOR CLASS device_type_ops USING hash;

DROP OPERATOR CLASS country_ops USING btree;
DROP OPERATOR CLASS country_ops USING hash;

DROP OPERATOR CLASS os_name_ops USING btree;
DROP OPERATOR CLASS os_name_ops USING hash;

DROP OPERATOR OPERATOR = (device_type, device_type);
DROP OPERATOR OPERATOR = (country, country);
DROP OPERATOR OPERATOR = (os_name, os_name);

----
DROP FUNCTION hashcountry(country);

----
DROP FUNCTION hashdevice_type(device_type);

----
DROP FUNCTION hashos_name(os_name);

CREATE OPERATOR = (
    leftarg = device_type, rightarg = device_type, procedure = device_type_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel
);

CREATE OPERATOR = (
    leftarg = os_name, rightarg = os_name, procedure = os_name_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel
);

CREATE OPERATOR = (
    leftarg = country, rightarg = country, procedure = country_eq,
    commutator = = , negator = <> ,
    restrict = eqsel, join = eqjoinsel
);


CREATE OPERATOR CLASS country_ops
    DEFAULT FOR TYPE country USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       country_cmp(country,country);

CREATE OPERATOR CLASS os_name_ops
    DEFAULT FOR TYPE os_name USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       os_name_cmp(os_name,os_name);

CREATE OPERATOR CLASS device_type_ops
    DEFAULT FOR TYPE device_type USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       device_type_cmp(device_type,device_type);
