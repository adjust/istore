--require types

CREATE FUNCTION istore(bigistore)
    RETURNS istore
    AS '$libdir/istore.so', 'bigistore_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(istore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'istore_to_big_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (istore as bigistore) WITH FUNCTION bigistore(istore) AS IMPLICIT;
CREATE CAST (bigistore as istore) WITH FUNCTION istore(bigistore) AS ASSIGNMENT;