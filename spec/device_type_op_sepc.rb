require 'spec_helper'

describe 'os_name_op' do
  before do
    install_extension
  end

  it 'should implement gt' do
    query("SELECT 'tablet'::devie_type > 'phone'::devie_type").should match 't'
    query("SELECT 'tablet'::devie_type >= 'phone'::devie_type").should match 't'
    query("SELECT NOT('tablet'::devie_type < 'phone'::devie_type)").should match 't'
    query("SELECT NOT('tablet'::devie_type <= 'phone'::devie_type)").should match 't'
  end

  it 'should implement lt' do
    query("SELECT 'tablet'::devie_type > 'phone'::devie_type").should match 't'
    query("SELECT 'tablet'::devie_type >= 'phone'::devie_type").should match 't'
    query("SELECT NOT('tablet'::devie_type < 'phone'::devie_type)").should match 't'
    query("SELECT NOT('tablet'::devie_type <= 'phone'::devie_type)").should match 't'
  end

  it 'should implement eq' do
    query("SELECT NOT('tablet'::devie_type = 'phone'::devie_type)").should match 't'
    query("SELECT 'phone'::devie_type = 'phone'::devie_type").should match 't'
  end

  it 'should implement neq' do
    query("SELECT 'tablet'::devie_type != 'phone'::devie_type").should match 't'
    query("SELECT NOT('phone'::devie_type != 'phone'::devie_type)").should match 't'
  end
end
