require 'spec_helper'

describe 'os_name_op' do
  before do
    install_extension
  end

  it 'should implement gt' do
    query("SELECT 'uk'::country > 'de'::country").should match 't'
    query("SELECT 'uk'::country >= 'de'::country").should match 't'
    query("SELECT NOT('uk'::country < 'de'::country)").should match 't'
    query("SELECT NOT('uk'::country <= 'de'::country)").should match 't'
  end

  it 'should implement lt' do
    query("SELECT 'uk'::country > 'de'::country").should match 't'
    query("SELECT 'uk'::country >= 'de'::country").should match 't'
    query("SELECT NOT('uk'::country < 'de'::country)").should match 't'
    query("SELECT NOT('uk'::country <= 'de'::country)").should match 't'
  end

  it 'should implement eq' do
    query("SELECT NOT('de'::country = 'uk'::country)").should match 't'
    query("SELECT 'uk'::country = 'uk'::country").should match 't'
  end

  it 'should implement neq' do
    query("SELECT 'de'::country != 'uk'::country").should match 't'
    query("SELECT NOT('uk'::country != 'uk'::country)").should match 't'
  end
end
