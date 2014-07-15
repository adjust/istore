SELECT 'de::phone::ios=>25,us::phone::ios=>10'::cistore;
SELECT 'de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore;
SELECT cistore('de'::country, 'phone'::device_type, 'ios'::os_name, 10);
SELECT cistore('de'::country, 'phone'::device_type, 'ios'::os_name, 5::smallint, 10::bigint);
SELECT 'de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore + 'de::tablet::ios::10=>25,us::phone::ios::1=>10'::cistore;
-- SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'country')
-- SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'device_type')
-- SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'device_type', 'os_name')
-- SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'country', 'device_type')
-- SELECT slice('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, '*::phone::*')
-- SELECT slice('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'de::phone::*')
