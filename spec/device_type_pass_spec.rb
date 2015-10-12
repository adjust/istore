require 'spec_helper'

describe 'device_type_pass' do
  before do
    install_extension
  end

  let(:valid_device_types) do
    [
      'bot', 'console', 'ipod', 'mac', 'pc', 'phone', 'server',
      'simulator', 'tablet', 'tv', 'unknown'
    ]
  end

  it 'should pass valid device_types' do
    valid_device_types.each do |name|
      query("SELECT '#{name}'::device_type").should match name
    end
  end

end
