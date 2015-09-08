CREATE FUNCTION istore_in(cstring)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_out(istore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_send(istore)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_recv(internal)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE istore (
    INPUT   = istore_in,
    OUTPUT  = istore_out,
    RECEIVE = istore_recv,
    SEND    = istore_send,
    STORAGE = EXTENDED
);

CREATE FUNCTION bigistore_in(cstring)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_out(bigistore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_send(bigistore)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_recv(internal)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE bigistore (
    INPUT   = bigistore_in,
    OUTPUT  = bigistore_out,
    RECEIVE = bigistore_recv,
    SEND    = bigistore_send,
    STORAGE = EXTENDED
);
