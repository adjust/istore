BEGIN;
-- os_name_op should implement gt;
-- ./spec/os_name_op_spec.rb:8;
CREATE EXTENSION istore;
SELECT 'ios'::os_name > 'android'::os_name;
SELECT 'ios'::os_name >= 'android'::os_name;
SELECT NOT('ios'::os_name < 'android'::os_name);
SELECT NOT('ios'::os_name <= 'android'::os_name);
ROLLBACK;
BEGIN;
-- os_name_op should implement lt;
-- ./spec/os_name_op_spec.rb:15;
CREATE EXTENSION istore;
SELECT 'ios'::os_name > 'android'::os_name;
SELECT 'ios'::os_name >= 'android'::os_name;
SELECT NOT('ios'::os_name < 'android'::os_name);
SELECT NOT('ios'::os_name <= 'android'::os_name);
ROLLBACK;
BEGIN;
-- os_name_op should implement eq;
-- ./spec/os_name_op_spec.rb:22;
CREATE EXTENSION istore;
SELECT NOT('ios'::os_name = 'android'::os_name);
SELECT 'android'::os_name = 'android'::os_name;
ROLLBACK;
BEGIN;
-- os_name_op should implement neq;
-- ./spec/os_name_op_spec.rb:27;
CREATE EXTENSION istore;
SELECT 'ios'::os_name != 'android'::os_name;
SELECT NOT('android'::os_name != 'android'::os_name);
ROLLBACK;
