require 'spec_helper'

describe 'operator' do
  before do
    install_extension
  end

  describe 'istore' do
    it 'should fetch values' do
      query("SELECT '1=>1, -1=>0'::istore -> -1").should match 0
      query("SELECT '1=>1, -1=>3'::istore -> -1").should match 3
    end

    it'should check existense of a key' do
      query("SELECT '1=>1, -1=>3'::istore ? -1").should match 't'
      query("SELECT '1=>1, -1=>3'::istore ? 5").should match 'f'
    end

    it 'should add two istores' do
      query("SELECT '1=>1, -1=>3'::istore + '1=>1'::istore").should match \
      '"-1"=>"3", "1"=>"2"'
      query("SELECT '1=>1, -1=>3'::istore + '-1=>-1'::istore").should match \
      '"-1"=>"2", "1"=>"1"'
      query("SELECT '1=>1, -1=>3'::istore + '1=>-1'::istore").should match \
      '"-1"=>"3", "1"=>"0"'
      query("SELECT '1=>NULL, -1=>3'::istore + '1=>-1'::istore").should match \
      '"-1"=>"3", "1"=>NULL'
      query("SELECT '1=>1, -1=>NULL'::istore + '-1=>-1'::istore").should match \
      '"-1"=>NULL, "1"=>"1"'
   end

    it 'should add an integer to istore' do
      query("SELECT '1=>1, -1=>3'::istore  + 1").should match \
      '"-1"=>"4", "1"=>"2"'
      query("SELECT '-1=>1, 1=>3'::istore  + 1").should match \
      '"-1"=>"2", "1"=>"4"'
      query("SELECT '-1=>1, -1=>3'::istore + 1").should match \
      '"-1"=>"5"'
      query("SELECT '1=>1, -1=>3'::istore  + 0").should match \
      '"-1"=>"3", "1"=>"1"'
      query("SELECT '-1=>1, 1=>3'::istore  + 0").should match \
      '"-1"=>"1", "1"=>"3"'
      query("SELECT '-1=>1, -1=>3'::istore + 0").should match \
      '"-1"=>"4"'
      query("SELECT '1=>1, -1=>3'::istore  + -1").should match \
      '"-1"=>"2", "1"=>"0"'
      query("SELECT '-1=>1, 1=>3'::istore  + -1").should match \
      '"-1"=>"0", "1"=>"2"'
      query("SELECT '-1=>1, -1=>3'::istore + -1").should match \
      '"-1"=>"3"'
   end

    it 'should substract two istores'do
      query("SELECT '1=>1, -1=>3'::istore - '1=>1'::istore").should match \
      '"-1"=>"3", "1"=>"0"'
      query("SELECT '1=>1, -1=>3'::istore - '-1=>-1'::istore").should match \
      '"-1"=>"4", "1"=>"1"'
      query("SELECT '1=>1, -1=>3'::istore - '1=>-1'::istore").should match \
      '"-1"=>"3", "1"=>"2"'
      query("SELECT '1=>NULL, -1=>3'::istore - '1=>-1'::istore").should match \
      '"-1"=>"3", "1"=>NULL'
   end

    it 'should substract integer from istore'do
      query("SELECT '1=>1, -1=>3'::istore  - 1").should match \
      '"-1"=>"2", "1"=>"0"'
      query("SELECT '-1=>1, 1=>3'::istore  - 1").should match \
      '"-1"=>"0", "1"=>"2"'
      query("SELECT '-1=>1, -1=>3'::istore - 1").should match \
      '"-1"=>"3"'
      query("SELECT '1=>1, -1=>3'::istore  - 0").should match \
      '"-1"=>"3", "1"=>"1"'
      query("SELECT '-1=>1, 1=>3'::istore  - 0").should match \
      '"-1"=>"1", "1"=>"3"'
      query("SELECT '-1=>1, -1=>3'::istore - 0").should match \
      '"-1"=>"4"'
      query("SELECT '1=>1, -1=>3'::istore  - -1").should match \
      '"-1"=>"4", "1"=>"2"'
      query("SELECT '-1=>1, 1=>3'::istore  - -1").should match \
      '"-1"=>"2", "1"=>"4"'
      query("SELECT '-1=>1, -1=>3'::istore - -1").should match \
      '"-1"=>"5"'
   end

    it 'should multiply two istores' do
      query("SELECT '1=>3, 2=>2'::istore * '1=>2, 3=>5'::istore").should match \
      '"1"=>"6", "2"=>NULL, "3"=>NULL'
      query("SELECT '-1=>3, 2=>2'::istore * '-1=>2, 3=>5'::istore").should match \
      '"-1"=>"6", "2"=>NULL, "3"=>NULL'
      query("SELECT '-1=>3, 2=>2'::istore * '-1=>-2, 3=>5'::istore").should match \
      '"-1"=>"-6", "2"=>NULL, "3"=>NULL'
      query("SELECT '-1=>3, 2=>NULL'::istore * '-1=>-2, 3=>5'::istore").should match \
      '"-1"=>"-6", "2"=>NULL, "3"=>NULL'
   end

    it 'should multiply istore with integer' do
      query("SELECT '1=>1, -1=>3'::istore  * 1").should match \
      '"-1"=>"3", "1"=>"1"'
      query("SELECT '-1=>1, 1=>3'::istore  * 1").should match \
      '"-1"=>"1", "1"=>"3"'
      query("SELECT '-1=>1, -1=>3'::istore * 1").should match \
      '"-1"=>"4"'
      query("SELECT '1=>1, -1=>3'::istore  * 0").should match \
      '"-1"=>"0", "1"=>"0"'
      query("SELECT '-1=>1, 1=>3'::istore  * 0").should match \
      '"-1"=>"0", "1"=>"0"'
      query("SELECT '-1=>1, -1=>3'::istore * 0").should match \
      '"-1"=>"0"'
      query("SELECT '1=>1, -1=>3'::istore  * -1").should match \
      '"-1"=>"-3", "1"=>"-1"'
      query("SELECT '-1=>1, 1=>3'::istore  * -1").should match \
      '"-1"=>"-1", "1"=>"-3"'
      query("SELECT '-1=>1, -1=>3'::istore * -1").should match \
      '"-1"=>"-4"'
    end
  end

  describe 'device_istore' do
    it 'should fetch values' do
      query("SELECT 'mac=>1, bot=>0'::device_istore -> 'mac'").should match '1'
      query("SELECT 'mac=>1, bot=>3'::device_istore -> 'kermit'").should match nil
    end

    it'should check existense of a key' do
      query("SELECT 'mac=>1, bot=>3'::device_istore ? 'mac'").should match 't'
      query("SELECT 'mac=>1, bot=>3'::device_istore ? 'kermit'").should match 'f'
    end

    it 'should add two istores' do
      query("SELECT 'mac=>1, bot=>3'::device_istore + 'mac=>1'::device_istore").should match \
      '"bot"=>"3", "mac"=>"2"'

      query("SELECT 'mac=>1, bot=>3'::device_istore + 'bot=>-1'::device_istore").should match \
      '"bot"=>"2", "mac"=>"1"'

      query("SELECT 'mac=>1, bot=>3'::device_istore + 'mac=>-1'::device_istore").should match \
      '"bot"=>"3", "mac"=>"0"'
    end

    it 'should add an integer to istore' do
      query("SELECT 'mac=>1, bot=>3'::device_istore  + 1").should match \
      '"bot"=>"4", "mac"=>"2"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  + 1").should match \
      '"bot"=>"2", "mac"=>"4"'
      query("SELECT 'bot=>1, bot=>3'::device_istore + 1").should match \
      '"bot"=>"5"'
      query("SELECT 'mac=>1, bot=>3'::device_istore  + 0").should match \
      '"bot"=>"3", "mac"=>"1"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  + 0").should match \
      '"bot"=>"1", "mac"=>"3"'
      query("SELECT 'bot=>1, bot=>3'::device_istore + 0").should match \
      '"bot"=>"4"'
      query("SELECT 'mac=>1, bot=>3'::device_istore  + -1").should match \
      '"bot"=>"2", "mac"=>"0"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  + -1").should match \
      '"bot"=>"0", "mac"=>"2"'
      query("SELECT 'bot=>1, bot=>3'::device_istore + -1").should match \
      '"bot"=>"3"'
   end

    it 'should substract two istores'do
      query("SELECT 'mac=>1, bot=>3'::device_istore - 'mac=>1'::device_istore").should match \
      '"bot"=>"3", "mac"=>"0"'
      query("SELECT 'mac=>1, bot=>3'::device_istore - 'bot=>-1'::device_istore").should match \
      '"bot"=>"4", "mac"=>"1"'
      query("SELECT 'mac=>1, bot=>3'::device_istore - 'mac=>-1'::device_istore").should match \
      '"bot"=>"3", "mac"=>"2"'
      query("SELECT 'mac=>NULL, bot=>3'::device_istore - 'mac=>-1'::device_istore").should match \
      '"bot"=>"3", "mac"=>NULL'
   end

    it 'should substract integer from istore'do
      query("SELECT 'mac=>1, bot=>3'::device_istore  - 1").should match \
      '"bot"=>"2", "mac"=>"0"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  - 1").should match \
      '"bot"=>"0", "mac"=>"2"'
      query("SELECT 'bot=>1, bot=>3'::device_istore - 1").should match \
      '"bot"=>"3"'
      query("SELECT 'mac=>1, bot=>3'::device_istore  - 0").should match \
      '"bot"=>"3", "mac"=>"1"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  - 0").should match \
      '"bot"=>"1", "mac"=>"3"'
      query("SELECT 'bot=>1, bot=>3'::device_istore - 0").should match \
      '"bot"=>"4"'
      query("SELECT 'mac=>1, bot=>3'::device_istore  - -1").should match \
      '"bot"=>"4", "mac"=>"2"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  - -1").should match \
      '"bot"=>"2", "mac"=>"4"'
      query("SELECT 'bot=>1, bot=>3'::device_istore - -1").should match \
      '"bot"=>"5"'
   end

    it 'should multiply two istores' do
      query("SELECT 'mac=>3, phone=>2'::device_istore * 'mac=>2, tablet=>5'::device_istore").should match \
      '"mac"=>"6", "phone"=>NULL, "tablet"=>NULL'

      query("SELECT 'bot=>3, phone=>2'::device_istore * 'bot=>2, tablet=>5'::device_istore").should match \
      '"bot"=>"6", "phone"=>NULL, "tablet"=>NULL'

      query("SELECT 'bot=>3, phone=>2'::device_istore * 'bot=>-2, tablet=>5'::device_istore").should match \
      '"bot"=>"-6", "phone"=>NULL, "tablet"=>NULL'

   end

    it 'should multiply istore with integer' do
      query("SELECT 'mac=>1, bot=>3'::device_istore  * 1").should match \
      '"bot"=>"3", "mac"=>"1"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  * 1").should match \
      '"bot"=>"1", "mac"=>"3"'
      query("SELECT 'bot=>1, bot=>3'::device_istore * 1").should match \
      '"bot"=>"4"'
      query("SELECT 'mac=>1, bot=>3'::device_istore  * 0").should match \
      '"bot"=>"0", "mac"=>"0"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  * 0").should match \
      '"bot"=>"0", "mac"=>"0"'
      query("SELECT 'bot=>1, bot=>3'::device_istore * 0").should match \
      '"bot"=>"0"'
      query("SELECT 'mac=>1, bot=>3'::device_istore  * -1").should match \
      '"bot"=>"-3", "mac"=>"-1"'
      query("SELECT 'bot=>1, mac=>3'::device_istore  * -1").should match \
      '"bot"=>"-1", "mac"=>"-3"'
      query("SELECT 'bot=>1, bot=>3'::device_istore * -1").should match \
      '"bot"=>"-4"'
    end
  end

  describe 'country_istore' do
    it 'should fetch values' do
      query("SELECT 'es=>1, de=>0'::country_istore -> 'de'").should match 0
      query("SELECT 'es=>1, de=>3'::country_istore -> 'us'").should match nil

    end

    it'should check existense of a key' do
      query("SELECT 'es=>1, de=>3'::country_istore ? 'de'").should match 't'
      query("SELECT 'es=>1, de=>3'::country_istore ? 'us'").should match 'f'
    end

    it 'should add two istores' do
      query("SELECT 'es=>1, de=>3'::country_istore + 'es=>1'::country_istore").should match \
      '"de"=>"3", "es"=>"2"'
      query("SELECT 'es=>1, de=>3'::country_istore + 'de=>-1'::country_istore").should match \
      '"de"=>"2", "es"=>"1"'
      query("SELECT 'es=>1, de=>3'::country_istore + 'es=>-1'::country_istore").should match \
      '"de"=>"3", "es"=>"0"'

    end

    it 'should add an integer to istore' do
      query("SELECT 'es=>1, de=>3'::country_istore  + 1").should match \
      '"de"=>"4", "es"=>"2"'
      query("SELECT 'de=>1, es=>3'::country_istore  + 1").should match \
      '"de"=>"2", "es"=>"4"'
      query("SELECT 'de=>1, de=>3'::country_istore + 1").should match \
      '"de"=>"5"'
      query("SELECT 'es=>1, de=>3'::country_istore  + 0").should match \
      '"de"=>"3", "es"=>"1"'
      query("SELECT 'de=>1, es=>3'::country_istore  + 0").should match \
      '"de"=>"1", "es"=>"3"'
      query("SELECT 'de=>1, de=>3'::country_istore + 0").should match \
      '"de"=>"4"'
      query("SELECT 'es=>1, de=>3'::country_istore  + -1").should match \
      '"de"=>"2", "es"=>"0"'
      query("SELECT 'de=>1, es=>3'::country_istore  + -1").should match \
      '"de"=>"0", "es"=>"2"'
      query("SELECT 'de=>1, de=>3'::country_istore + -1").should match \
      '"de"=>"3"'
      query("SELECT 'de=>NULL, de=>3'::country_istore + -1").should match \
      '"de"=>NULL'
    end

    it 'should substract two istores'do
      query("SELECT 'es=>1, de=>3'::country_istore - 'es=>1'::country_istore").should match \
      '"de"=>"3", "es"=>"0"'
      query("SELECT 'es=>1, de=>3'::country_istore - 'de=>-1'::country_istore").should match \
      '"de"=>"4", "es"=>"1"'
      query("SELECT 'es=>1, de=>3'::country_istore - 'es=>-1'::country_istore").should match \
      '"de"=>"3", "es"=>"2"'
   end

    it 'should substract integer from istore'do
      query("SELECT 'es=>1, de=>3'::country_istore  - 1").should match \
      '"de"=>"2", "es"=>"0"'
      query("SELECT 'de=>1, es=>3'::country_istore  - 1").should match \
      '"de"=>"0", "es"=>"2"'
      query("SELECT 'de=>1, de=>3'::country_istore - 1").should match \
      '"de"=>"3"'
      query("SELECT 'es=>1, de=>3'::country_istore  - 0").should match \
      '"de"=>"3", "es"=>"1"'
      query("SELECT 'de=>1, es=>3'::country_istore  - 0").should match \
      '"de"=>"1", "es"=>"3"'
      query("SELECT 'de=>1, de=>3'::country_istore - 0").should match \
      '"de"=>"4"'
      query("SELECT 'es=>1, de=>3'::country_istore  - -1").should match \
      '"de"=>"4", "es"=>"2"'
      query("SELECT 'de=>1, es=>3'::country_istore  - -1").should match \
      '"de"=>"2", "es"=>"4"'
      query("SELECT 'de=>1, de=>3'::country_istore - -1").should match \
      '"de"=>"5"'
   end

    it 'should multiply two istores' do
      query("SELECT 'es=>3, uk=>2'::country_istore * 'es=>2, io=>5'::country_istore").should match \
      '"es"=>"6", "io"=>NULL, "uk"=>NULL'
      query("SELECT 'de=>3, uk=>2'::country_istore * 'de=>2, io=>5'::country_istore").should match \
      '"de"=>"6", "io"=>NULL, "uk"=>NULL'
      query("SELECT 'de=>3, uk=>2'::country_istore * 'de=>-2, io=>5'::country_istore").should match \
      '"de"=>"-6", "io"=>NULL, "uk"=>NULL'
   end

    it 'should multiply istore with integer' do
      query("SELECT 'es=>1, de=>3'::country_istore  * 1").should match \
      '"de"=>"3", "es"=>"1"'
      query("SELECT 'de=>1, es=>3'::country_istore  * 1").should match \
      '"de"=>"1", "es"=>"3"'
      query("SELECT 'de=>1, de=>3'::country_istore * 1").should match \
      '"de"=>"4"'
      query("SELECT 'es=>1, de=>3'::country_istore  * 0").should match \
      '"de"=>"0", "es"=>"0"'
      query("SELECT 'de=>1, es=>3'::country_istore  * 0").should match \
      '"de"=>"0", "es"=>"0"'
      query("SELECT 'de=>1, de=>3'::country_istore * 0").should match \
      '"de"=>"0"'
      query("SELECT 'es=>1, de=>3'::country_istore  * -1").should match \
      '"de"=>"-3", "es"=>"-1"'
      query("SELECT 'de=>1, es=>3'::country_istore  * -1").should match \
      '"de"=>"-1", "es"=>"-3"'
      query("SELECT 'de=>1, de=>3'::country_istore * -1").should match \
      '"de"=>"-4"'
    end
  end

  describe 'os_name_istore' do
    it 'should fetch values' do
      query("SELECT 'android=>1, ios=>0'::os_name_istore -> 'ios'").should match 0
      query("SELECT 'android=>1, ios=>3'::os_name_istore -> 'windows'").should match nil
    end

    it'should check existense of a key' do
      query("SELECT 'android=>1, ios=>3'::os_name_istore ? 'android'").should match 't'
      query("SELECT 'android=>1, ios=>3'::os_name_istore ? 'windows'").should match 'f'
    end

    it 'should add two istores' do
      query("SELECT 'android=>1, ios=>3'::os_name_istore + 'android=>1'::os_name_istore").should match \
      '"android"=>"2", "ios"=>"3"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore + 'ios=>-1'::os_name_istore").should match \
      '"android"=>"1", "ios"=>"2"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore + 'android=>-1'::os_name_istore").should match \
      '"android"=>"0", "ios"=>"3"'
    end

    it 'should add an integer to istore' do
      query("SELECT 'android=>1, ios=>3'::os_name_istore  + 1").should match \
      '"android"=>"2", "ios"=>"4"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  + 1").should match \
      '"android"=>"4", "ios"=>"2"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore + 1").should match \
      '"ios"=>"5"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore  + 0").should match \
      '"android"=>"1", "ios"=>"3"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  + 0").should match \
      '"android"=>"3", "ios"=>"1"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore + 0").should match \
      '"ios"=>"4"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore  + -1").should match \
      '"android"=>"0", "ios"=>"2"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  + -1").should match \
      '"android"=>"2", "ios"=>"0"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore + -1").should match \
      '"ios"=>"3"'
    end

    it 'should substract two istores'do
      query("SELECT 'android=>1, ios=>3'::os_name_istore - 'android=>1'::os_name_istore").should match \
      '"android"=>"0", "ios"=>"3"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore - 'ios=>-1'::os_name_istore").should match \
      '"android"=>"1", "ios"=>"4"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore - 'android=>-1'::os_name_istore").should match \
      '"android"=>"2", "ios"=>"3"'
    end

    it 'should substract integer from istore'do
      query("SELECT 'android=>1, ios=>3'::os_name_istore  - 1").should match \
      '"android"=>"0", "ios"=>"2"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  - 1").should match \
      '"android"=>"2", "ios"=>"0"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore - 1").should match \
      '"ios"=>"3"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore  - 0").should match \
      '"android"=>"1", "ios"=>"3"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  - 0").should match \
      '"android"=>"3", "ios"=>"1"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore - 0").should match \
      '"ios"=>"4"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore  - -1").should match \
      '"android"=>"2", "ios"=>"4"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  - -1").should match \
      '"android"=>"4", "ios"=>"2"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore - -1").should match \
      '"ios"=>"5"'
      query("SELECT 'ios=>NULL, ios=>3'::os_name_istore - -1").should match \
      '"ios"=>NULL'
    end

    it 'should multiply two istores' do
      query("SELECT 'android=>3, windows-phone=>2'::os_name_istore * 'android=>2, windows=>5'::os_name_istore").should match \
      '"android"=>"6", "windows"=>NULL, "windows-phone"=>NULL'
      query("SELECT 'ios=>3, windows-phone=>2'::os_name_istore * 'ios=>2, windows=>5'::os_name_istore").should match \
      '"ios"=>"6", "windows"=>NULL, "windows-phone"=>NULL'
      query("SELECT 'ios=>3, windows-phone=>2'::os_name_istore * 'ios=>-2, windows=>5'::os_name_istore").should match \
      '"ios"=>"-6", "windows"=>NULL, "windows-phone"=>NULL'

   end

    it 'should multiply istore with integer' do
      query("SELECT 'android=>1, ios=>3'::os_name_istore  * 1").should match \
      '"android"=>"1", "ios"=>"3"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  * 1").should match \
      '"android"=>"3", "ios"=>"1"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore * 1").should match \
      '"ios"=>"4"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore  * 0").should match \
      '"android"=>"0", "ios"=>"0"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  * 0").should match \
      '"android"=>"0", "ios"=>"0"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore * 0").should match \
      '"ios"=>"0"'
      query("SELECT 'android=>1, ios=>3'::os_name_istore  * -1").should match \
      '"android"=>"-1", "ios"=>"-3"'
      query("SELECT 'ios=>1, android=>3'::os_name_istore  * -1").should match \
      '"android"=>"-3", "ios"=>"-1"'
      query("SELECT 'ios=>1, ios=>3'::os_name_istore * -1").should match \
      '"ios"=>"-4"'
    end
  end
end
