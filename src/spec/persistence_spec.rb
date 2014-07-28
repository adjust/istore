require 'spec_helper'

describe 'persistence' do
  before do
    install_extension
  end

  it 'should persist countries' do
    query("CREATE TABLE country_test AS SELECT 'de'::country, 1 as num")
    query("SELECT * FROM country_test").should match  'de',  1
    query("UPDATE country_test SET num = 2")
    query("SELECT * FROM country_test").should match  'de',  2
  end

  it 'should persist os_names' do
    query("CREATE TABLE os_name_test AS SELECT 'ios'::os_name, 1 as num")
    query("SELECT * FROM os_name_test").should match 'ios',  1
    query("UPDATE os_name_test SET num = 2")
    query("SELECT * FROM os_name_test").should match 'ios',  2
  end

  it 'should persist device_type' do
    query("CREATE TABLE device_type_test AS SELECT 'phone'::device_type, 1 as num")
    query("SELECT * FROM device_type_test").should match 'phone',  1
    query("UPDATE device_type_test SET num = 2")
    query("SELECT * FROM device_type_test").should match 'phone',  2
  end

end
