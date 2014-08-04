require 'spec_helper'

describe 'os_name_op' do
  before do
    install_extension
  end

  it 'should implement gt' do
    query("SELECT 'ios'::os_name > 'android'::os_name").should match 't'
    query("SELECT 'ios'::os_name >= 'android'::os_name").should match 't'
    query("SELECT NOT('ios'::os_name < 'android'::os_name)").should match 't'
    query("SELECT NOT('ios'::os_name <= 'android'::os_name)").should match 't'
  end

  it 'should implement lt' do
    query("SELECT 'ios'::os_name > 'android'::os_name").should match 't'
    query("SELECT 'ios'::os_name >= 'android'::os_name").should match 't'
    query("SELECT NOT('ios'::os_name < 'android'::os_name)").should match 't'
    query("SELECT NOT('ios'::os_name <= 'android'::os_name)").should match 't'
  end

  it 'should implement eq' do
    query("SELECT NOT('ios'::os_name = 'android'::os_name)").should match 't'
    query("SELECT 'android'::os_name = 'android'::os_name").should match 't'
  end

  it 'should implement neq' do
    query("SELECT 'ios'::os_name != 'android'::os_name").should match 't'
    query("SELECT NOT('android'::os_name != 'android'::os_name)").should match 't'
  end
end
