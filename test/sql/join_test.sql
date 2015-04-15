BEGIN;
-- join join two tables;
-- ./spec/join_spec.rb:27;
CREATE EXTENSION istore;
SELECT os_name, device_type, country, a.num+b.num FROM(
VALUES
('android'::os_name, 'phone'::device_type, 'de'::country, 10),
('android', 'phone', 'us', 10),
('android', 'phone', 'de', 10)
)a(os_name, device_type, country, num)
JOIN (
VALUES
('android'::os_name, 'phone'::device_type, 'de'::country, 10),
('android', 'phone', 'us', 10),
('android', 'phone', 'de', 10),
('windows', 'phone', 'de', 10)
)b(os_name, device_type, country, num)
USING (os_name, device_type, country)
;
ROLLBACK;
