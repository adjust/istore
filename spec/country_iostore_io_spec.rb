require 'spec_helper'

describe 'country_iostore_io' do
  before do
    install_extension
  end

  {
    'de=>1,de=>2' => '"de"=>"3"',
    '"de"=>"1", "de"=>"2"' => '"de"=>"3"',
    '"de"=>"1", "zz"=>"2"' => '"de"=>"1", "zz"=>"2"',
    '"zz"=>"+1","de"=>"2"' => '"de"=>"2", "zz"=>"1"',
    ' "zz"=>"+1","de"=>"2"' => '"de"=>"2", "zz"=>"1"',
    '"zz"=> "+1","de"=>"2"' => '"de"=>"2", "zz"=>"1"',
    '"zz"=>"+1" ,"de"=>"2"' => '"de"=>"2", "zz"=>"1"',
    '"zz"=>"+1", "de"=>"2"' => '"de"=>"2", "zz"=>"1"',
    '"zz"=>"+1","de"=>"2" ' => '"de"=>"2", "zz"=>"1"',
    'zz=>+1,de=>2 '         => '"de"=>"2", "zz"=>"1"',
    ''                      => ''
  }.each do |input, output|

    it 'should persist country_iostores' do
      query(%{CREATE TABLE country_istore_io AS SELECT '#{input}'::country_istore})
      query("SELECT * FROM country_istore_io").should match output
    end
  end
end
