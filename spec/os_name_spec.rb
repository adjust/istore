require 'spec_helper'

describe 'os_name' do
  before do
    install_extension
  end

  it 'should pass valid os_name' do
    %w(android ios windows windows unknown).each do |name|
      query("SELECT '#{name}'::os_name").should match name
    end
  end

  it 'should rais an exception on invalid os_name' do
    expect{query("SELECT 'kermit'::os_name")}.to throw_error('unknown input os_name')
  end
end
