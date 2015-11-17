make;
make install;
psql -c "DROP EXTENSION istore CASCADE;"
psql -c "CREATE EXTENSION istore;"
psql -c "DROP TABLE bigitest;"
psql -c "CREATE TABLE bigitest(bi bigistore);"
