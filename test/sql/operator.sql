SELECT '1=>1, -1=>0'::istore -> -1;
SELECT '1=>1, -1=>3'::istore -> -1;

SELECT '1=>1, -1=>3'::istore ? -1;
SELECT '1=>1, -1=>3'::istore ? 5;

SELECT '1=>1, -1=>3'::istore + '1=>1'::istore;
SELECT '1=>1, -1=>3'::istore + '-1=>-1'::istore;
SELECT '1=>1, -1=>3'::istore + '1=>-1'::istore;
SELECT '1=>NULL, -1=>3'::istore + '1=>-1'::istore;
SELECT '1=>1, -1=>NULL'::istore + '-1=>-1'::istore;

SELECT '1=>1, -1=>3'::istore  + 1;
SELECT '-1=>1, 1=>3'::istore  + 1;
SELECT '-1=>1, -1=>3'::istore + 1;
SELECT '1=>1, -1=>3'::istore  + 0;
SELECT '-1=>1, 1=>3'::istore  + 0;
SELECT '-1=>1, -1=>3'::istore + 0;
SELECT '1=>1, -1=>3'::istore  + -1;
SELECT '-1=>1, 1=>3'::istore  + -1;
SELECT '-1=>1, -1=>3'::istore + -1;

SELECT '1=>1, -1=>3'::istore - '1=>1'::istore;
SELECT '1=>1, -1=>3'::istore - '-1=>-1'::istore;
SELECT '1=>1, -1=>3'::istore - '1=>-1'::istore;
SELECT '1=>NULL, -1=>3'::istore - '1=>-1'::istore;

SELECT '1=>1, -1=>3'::istore  - 1;
SELECT '-1=>1, 1=>3'::istore  - 1;
SELECT '-1=>1, -1=>3'::istore - 1;
SELECT '1=>1, -1=>3'::istore  - 0;
SELECT '-1=>1, 1=>3'::istore  - 0;
SELECT '-1=>1, -1=>3'::istore - 0;
SELECT '1=>1, -1=>3'::istore  - -1;
SELECT '-1=>1, 1=>3'::istore  - -1;
SELECT '-1=>1, -1=>3'::istore - -1;

SELECT '1=>3, 2=>2'::istore * '1=>2, 3=>5'::istore;
SELECT '-1=>3, 2=>2'::istore * '-1=>2, 3=>5'::istore;
SELECT '-1=>3, 2=>2'::istore * '-1=>-2, 3=>5'::istore;
SELECT '-1=>3, 2=>NULL'::istore * '-1=>-2, 3=>5'::istore;

SELECT '1=>1, -1=>3'::istore  * 1;
SELECT '-1=>1, 1=>3'::istore  * 1;
SELECT '-1=>1, -1=>3'::istore * 1;
SELECT '1=>1, -1=>3'::istore  * 0;
SELECT '-1=>1, 1=>3'::istore  * 0;
SELECT '-1=>1, -1=>3'::istore * 0;
SELECT '1=>1, -1=>3'::istore  * -1;
SELECT '-1=>1, 1=>3'::istore  * -1;
SELECT '-1=>1, -1=>3'::istore * -1;


SELECT 'mac=>1, bot=>0'::device_istore -> 'mac';
SELECT 'mac=>1, bot=>3'::device_istore -> 'kermit';

SELECT 'mac=>1, bot=>3'::device_istore ? 'mac';
SELECT 'mac=>1, bot=>3'::device_istore ? 'kermit';

SELECT 'mac=>1, bot=>3'::device_istore + 'mac=>1'::device_istore;
SELECT 'mac=>1, bot=>3'::device_istore + 'bot=>-1'::device_istore;
SELECT 'mac=>1, bot=>3'::device_istore + 'mac=>-1'::device_istore;

SELECT 'mac=>1, bot=>3'::device_istore  + 1;
SELECT 'bot=>1, mac=>3'::device_istore  + 1;
SELECT 'bot=>1, bot=>3'::device_istore + 1;
SELECT 'mac=>1, bot=>3'::device_istore  + 0;
SELECT 'bot=>1, mac=>3'::device_istore  + 0;
SELECT 'bot=>1, bot=>3'::device_istore + 0;
SELECT 'mac=>1, bot=>3'::device_istore  + -1;
SELECT 'bot=>1, mac=>3'::device_istore  + -1;
SELECT 'bot=>1, bot=>3'::device_istore + -1;

SELECT 'mac=>1, bot=>3'::device_istore - 'mac=>1'::device_istore;
SELECT 'mac=>1, bot=>3'::device_istore - 'bot=>-1'::device_istore;
SELECT 'mac=>1, bot=>3'::device_istore - 'mac=>-1'::device_istore;
SELECT 'mac=>NULL, bot=>3'::device_istore - 'mac=>-1'::device_istore;

SELECT 'mac=>1, bot=>3'::device_istore  - 1;
SELECT 'bot=>1, mac=>3'::device_istore  - 1;
SELECT 'bot=>1, bot=>3'::device_istore - 1;
SELECT 'mac=>1, bot=>3'::device_istore  - 0;
SELECT 'bot=>1, mac=>3'::device_istore  - 0;
SELECT 'bot=>1, bot=>3'::device_istore - 0;
SELECT 'mac=>1, bot=>3'::device_istore  - -1;
SELECT 'bot=>1, mac=>3'::device_istore  - -1;
SELECT 'bot=>1, bot=>3'::device_istore - -1;

SELECT 'mac=>3, phone=>2'::device_istore * 'mac=>2, tablet=>5'::device_istore;
SELECT 'bot=>3, phone=>2'::device_istore * 'bot=>2, tablet=>5'::device_istore;
SELECT 'bot=>3, phone=>2'::device_istore * 'bot=>-2, tablet=>5'::device_istore;

SELECT 'mac=>1, bot=>3'::device_istore  * 1;
SELECT 'bot=>1, mac=>3'::device_istore  * 1;
SELECT 'bot=>1, bot=>3'::device_istore * 1;
SELECT 'mac=>1, bot=>3'::device_istore  * 0;
SELECT 'bot=>1, mac=>3'::device_istore  * 0;
SELECT 'bot=>1, bot=>3'::device_istore * 0;
SELECT 'mac=>1, bot=>3'::device_istore  * -1;
SELECT 'bot=>1, mac=>3'::device_istore  * -1;
SELECT 'bot=>1, bot=>3'::device_istore * -1;


SELECT 'es=>1, de=>0'::country_istore -> 'de';
SELECT 'es=>1, de=>3'::country_istore -> 'us';

SELECT 'es=>1, de=>3'::country_istore ? 'de';
SELECT 'es=>1, de=>3'::country_istore ? 'us';

SELECT 'es=>1, de=>3'::country_istore + 'es=>1'::country_istore;
SELECT 'es=>1, de=>3'::country_istore + 'de=>-1'::country_istore;
SELECT 'es=>1, de=>3'::country_istore + 'es=>-1'::country_istore;

SELECT 'es=>1, de=>3'::country_istore  + 1;
SELECT 'de=>1, es=>3'::country_istore  + 1;
SELECT 'de=>1, de=>3'::country_istore + 1;
SELECT 'es=>1, de=>3'::country_istore  + 0;
SELECT 'de=>1, es=>3'::country_istore  + 0;
SELECT 'de=>1, de=>3'::country_istore + 0;
SELECT 'es=>1, de=>3'::country_istore  + -1;
SELECT 'de=>1, es=>3'::country_istore  + -1;
SELECT 'de=>1, de=>3'::country_istore + -1;
SELECT 'de=>NULL, de=>3'::country_istore + -1;

SELECT 'es=>1, de=>3'::country_istore - 'es=>1'::country_istore;
SELECT 'es=>1, de=>3'::country_istore - 'de=>-1'::country_istore;
SELECT 'es=>1, de=>3'::country_istore - 'es=>-1'::country_istore;

SELECT 'es=>1, de=>3'::country_istore  - 1;
SELECT 'de=>1, es=>3'::country_istore  - 1;
SELECT 'de=>1, de=>3'::country_istore - 1;
SELECT 'es=>1, de=>3'::country_istore  - 0;
SELECT 'de=>1, es=>3'::country_istore  - 0;
SELECT 'de=>1, de=>3'::country_istore - 0;
SELECT 'es=>1, de=>3'::country_istore  - -1;
SELECT 'de=>1, es=>3'::country_istore  - -1;
SELECT 'de=>1, de=>3'::country_istore - -1;

SELECT 'es=>3, uk=>2'::country_istore * 'es=>2, io=>5'::country_istore;
SELECT 'de=>3, uk=>2'::country_istore * 'de=>2, io=>5'::country_istore;
SELECT 'de=>3, uk=>2'::country_istore * 'de=>-2, io=>5'::country_istore;

SELECT 'es=>1, de=>3'::country_istore  * 1;
SELECT 'de=>1, es=>3'::country_istore  * 1;
SELECT 'de=>1, de=>3'::country_istore * 1;
SELECT 'es=>1, de=>3'::country_istore  * 0;
SELECT 'de=>1, es=>3'::country_istore  * 0;
SELECT 'de=>1, de=>3'::country_istore * 0;
SELECT 'es=>1, de=>3'::country_istore  * -1;
SELECT 'de=>1, es=>3'::country_istore  * -1;
SELECT 'de=>1, de=>3'::country_istore * -1;


SELECT 'android=>1, ios=>0'::os_name_istore -> -1;
SELECT 'android=>1, ios=>3'::os_name_istore -> -1;

SELECT 'android=>1, ios=>3'::os_name_istore ? -1;
SELECT 'android=>1, ios=>3'::os_name_istore ? 5;

SELECT 'android=>1, ios=>3'::os_name_istore + 'android=>1'::os_name_istore;
SELECT 'android=>1, ios=>3'::os_name_istore + 'ios=>-1'::os_name_istore;
SELECT 'android=>1, ios=>3'::os_name_istore + 'android=>-1'::os_name_istore;

SELECT 'android=>1, ios=>3'::os_name_istore  + 1;
SELECT 'ios=>1, android=>3'::os_name_istore  + 1;
SELECT 'ios=>1, ios=>3'::os_name_istore + 1;
SELECT 'android=>1, ios=>3'::os_name_istore  + 0;
SELECT 'ios=>1, android=>3'::os_name_istore  + 0;
SELECT 'ios=>1, ios=>3'::os_name_istore + 0;
SELECT 'android=>1, ios=>3'::os_name_istore  + -1;
SELECT 'ios=>1, android=>3'::os_name_istore  + -1;
SELECT 'ios=>1, ios=>3'::os_name_istore + -1;

SELECT 'android=>1, ios=>3'::os_name_istore - 'android=>1'::os_name_istore;
SELECT 'android=>1, ios=>3'::os_name_istore - 'ios=>-1'::os_name_istore;
SELECT 'android=>1, ios=>3'::os_name_istore - 'android=>-1'::os_name_istore;

SELECT 'android=>1, ios=>3'::os_name_istore  - 1;
SELECT 'ios=>1, android=>3'::os_name_istore  - 1;
SELECT 'ios=>1, ios=>3'::os_name_istore - 1;
SELECT 'android=>1, ios=>3'::os_name_istore  - 0;
SELECT 'ios=>1, android=>3'::os_name_istore  - 0;
SELECT 'ios=>1, ios=>3'::os_name_istore - 0;
SELECT 'android=>1, ios=>3'::os_name_istore  - -1;
SELECT 'ios=>1, android=>3'::os_name_istore  - -1;
SELECT 'ios=>1, ios=>3'::os_name_istore - -1;
SELECT 'ios=>NULL, ios=>3'::os_name_istore - -1;

SELECT 'android=>3, windows-phone=>2'::os_name_istore * 'android=>2, windows=>5'::os_name_istore;
SELECT 'ios=>3, windows-phone=>2'::os_name_istore * 'ios=>2, windows=>5'::os_name_istore;
SELECT 'ios=>3, windows-phone=>2'::os_name_istore * 'ios=>-2, windows=>5'::os_name_istore;

SELECT 'android=>1, ios=>3'::os_name_istore  * 1;
SELECT 'ios=>1, android=>3'::os_name_istore  * 1;
SELECT 'ios=>1, ios=>3'::os_name_istore * 1;
SELECT 'android=>1, ios=>3'::os_name_istore  * 0;
SELECT 'ios=>1, android=>3'::os_name_istore  * 0;
SELECT 'ios=>1, ios=>3'::os_name_istore * 0;
SELECT 'android=>1, ios=>3'::os_name_istore  * -1;
SELECT 'ios=>1, android=>3'::os_name_istore  * -1;
SELECT 'ios=>1, ios=>3'::os_name_istore * -1;

