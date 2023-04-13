-- istore should be downgradeable;
ALTER EXTENSION istore UPDATE TO '0.1.3';
SELECT e.extname, e.extversion FROM pg_catalog.pg_extension e WHERE e.extname = 'istore'ORDER BY 1;
-- istore should be upgradeable;
ALTER EXTENSION istore UPDATE TO '0.1.4';
ALTER EXTENSION istore UPDATE TO '0.1.3';
SELECT e.extname, e.extversion FROM pg_catalog.pg_extension e WHERE e.extname = 'istore'ORDER BY 1;
-- istore should be upgradable to latest version;
ALTER EXTENSION istore UPDATE;
