require 'spec_helper'

describe 'device_iostore_io' do
  before do
    install_extension
  end
  {
    'bot=>1,mac=>2' => '"bot"=>"1","mac"=>"2"',
    '"bot"=>"1","bot"=>"2"' => '"bot"=>"3"',
    '"bot"=>"1","mac"=>"2"' => '"bot"=>"1","mac"=>"2"',
    '"mac"=>"+1","bot"=>"2"' => '"bot"=>"2","mac"=>"1"',
    ' "mac"=>"+1","bot"=>"2"' => '"bot"=>"2","mac"=>"1"',
    '"mac"=> "+1","bot"=>"2"' => '"bot"=>"2","mac"=>"1"',
    '"mac"=>"+1" ,"bot"=>"2"' => '"bot"=>"2","mac"=>"1"',
    '"mac"=>"+1", "bot"=>"2"' => '"bot"=>"2","mac"=>"1"',
    '"mac"=>"+1","bot"=>"2" ' => '"bot"=>"2","mac"=>"1"',
    '"mac"=>"+1","bot"=>"2" ' => '"bot"=>"2","mac"=>"1"'
  }.each do |input, output|

    it 'should persist device_iostore' do
      query(%{CREATE TABLE device_iostore AS SELECT '#{input}'::device_istore})
      query("SELECT * FROM device_iostore").should match output
    end
  end
end
