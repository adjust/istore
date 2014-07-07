SELECT 'de::phone::ios=>25,us::phone::ios=>10'::cistore;
                  cistore
-----------------------------------------------
 "de::phone::ios"=>25, "us::phone::ios"=>10

 SELECT 'de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore;
                  cistore
-----------------------------------------------
 "de::phone::ios::10"=>25, "us::phone::ios::1"=>10

SELECT cistore('de'::country, 'phone'::device_type, 'ios'::os_name, 10);
      cistore
----------------------
 "de::phone::ios"=>10

SELECT cistore('de'::country, 'phone'::device_type, 'ios'::os_name, 5, 10);
      cistore
------------------------
 "de::phone::ios::5"=>10

SELECT 'de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore + 'de::tablet::ios::10=>25,us::phone::ios::1=>10'::cistore;
      cistore
-----------------------------------------------------------------------------
"de::phone::ios::10"=>25, "us::phone::ios::1"=>20, "de::tablet::ios::10"=>25

SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'country')
    cistore
-------------------
"de"=>25, "us"=>10

SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'device_type')
  cistore
------------
"phone"=>35

SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'device_type', 'os_name')
  cistore
------------
"phone::ios"=>35

SELECT agg('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'country', 'device_type')
           cistore
---------------------------------
"de::phone"=>25, "us::phone"=>10

SELECT slice('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, '*::phone::*')
           cistore
---------------------------------
"de::phone::ios::10"=>25,"us::phone::ios::1"=>10

SELECT slice('de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore, 'de::phone::*')
           cistore
-------------------------
"de::phone::ios::10"=>25
