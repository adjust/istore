CREATE FUNCTION slice(istore, min integer, max integer)
    RETURNS istore
    AS 'istore', 'istore_slice_min_max'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice(bigistore, min integer, max integer)
    RETURNS bigistore
    AS 'istore', 'bigistore_slice_min_max'
    LANGUAGE C IMMUTABLE STRICT;