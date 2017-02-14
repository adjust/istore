CREATE FUNCTION istore_serial(internal)
    RETURNS bytea
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_deserial(bytea, internal)
    RETURNS internal
    AS 'istore', 'istore_deserial'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_agg_combine(internal, internal)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;
