CREATE OPERATOR -> (
    leftarg   = istore,
    rightarg  = integer,
    procedure = fetchval
);
