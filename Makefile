EXTENSION = istore
EXTVERSION = $(shell grep default_version $(EXTENSION).control | \
                sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
DATA = $(wildcard sql/*--*.sql)

MODULE_big = istore
OBJS = src/istore.o \
       src/data_types.o \
       src/istore_io.o \
       src/device_type.o \
       src/country.o \
       src/aj_types.o \
       src/os_name.o

TESTS        = setup $(filter-out test/sql/setup.sql test/sql/update.sql, $(wildcard test/sql/*.sql))

REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test --load-language=plpgsql

all: concat

concat:
	echo > sql/$(EXTENSION)--$(EXTVERSION).sql
	cat sql/istore.sql \
	    sql/cistore.sql \
	    sql/country.sql \
		sql/device_type.sql \
		sql/os_name.sql >> sql/$(EXTENSION)--$(EXTVERSION).sql


PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
