require 'spec_helper'

describe 'cistore' do
  before do
    install_extension
  end

  it 'should pass valid cistores' do
    query("SELECT 'de::phone::ios=>25,us::phone::ios=>10'::cistore").should match \
      '"us::phone::ios"=>"10","de::phone::ios"=>"25"'

    query("SELECT 'de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore").should match \
       '"us::phone::ios::1"=>"10","de::phone::ios::10"=>"25"'

    query("SELECT cistore('de'::country, 'phone'::device_type, 'ios'::os_name, 10)").should match \
       '"de::phone::ios"=>"10"'

    query("SELECT cistore('de'::country, 'phone'::device_type, 'ios'::os_name, 5::smallint, 10::bigint)").should match \
      '"de::phone::ios::5"=>"10"'

    query("SELECT 'de::phone::ios::10=>25,us::phone::ios::1=>10'::cistore + 'de::tablet::ios::10=>25,us::phone::ios::1=>10'::cistore").should match \
      '"us::phone::ios::1"=>"20","de::phone::ios::10"=>"25","de::tablet::ios::10"=>"25"'
  end
end
