require 'spec_helper'

describe 'country' do
  before do
    install_extension
  end

  it 'should be case insensitive' do
    %w(de De dE DE dE).product(%w(de De dE DE dE)).each do |comb|
      query("SELECT '#{comb[0]}'::country = '#{comb[1]}'::country").should match 't'
    end
  end
end
