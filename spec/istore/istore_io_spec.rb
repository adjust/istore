require 'spec_helper'
types.each do |type|
  describe "#{type}" do
    describe 'istore_io' do
      before do
        install_extension
      end

      it 'should persist istores' do
        query(%{CREATE TABLE istore_io AS SELECT #{sample[type]}::#{type}})
        query("SELECT * FROM istore_io").should match \
        sample_out[type]
      end

      it 'should persist istores' do
        query(%{CREATE TABLE istore_io AS SELECT '"-1"=>"+1","1"=>"2"'::#{type}})
        query("SELECT * FROM istore_io").should match \
        '"-1"=>"1", "1"=>"2"'
      end

      it 'should persist istores' do
        query(%{CREATE TABLE istore_io AS SELECT ' "-1"=>"+1","1"=>"2"'::#{type}})
        query("SELECT * FROM istore_io").should match \
        '"-1"=>"1", "1"=>"2"'
      end

      it 'should persist empty istores' do
        query(%{CREATE TABLE istore_io AS SELECT ''::#{type}})
        query("SELECT * FROM istore_io").should match ''
      end

      describe 'invalid input' do
        it 'should report invalid value input' do
          expect{query("SELECT '2=>4, 1=>foo, 5=>17'::#{type}")}.to throw_error "invalid input syntax for #{type}: \"2=>4, 1=>foo, 5=>17\""
        end

        it 'should report invalid value input' do
          expect{query("SELECT '2=>4, 1=>5foo, 5=>17'::#{type}")}.to throw_error "invalid input syntax for #{type}: \"2=>4, 1=>5foo, 5=>17\""
        end

        it 'should report to big value input' do
          expect{query("SELECT '2=>4, 1=>#{values[type][:high]*2}, 5=>17'::#{type}")}.to throw_error "#{type} \"2=>4, 1=>#{values[type][:high]*2}, 5=>17\" is out of range"
        end

        it 'should report to small value input' do
          expect{query("SELECT '2=>4, 1=>#{values[type][:low]*2}, 5=>17'::#{type}")}.to throw_error "#{type} \"2=>4, 1=>#{values[type][:low]*2}, 5=>17\" is out of range"
        end

        it 'should report invalid key input' do
          expect{query("SELECT '2=>4, 54foo=>5, 5=>17'::#{type}")}.to throw_error "invalid input syntax for #{type}: \"2=>4, 54foo=>5, 5=>17\""
        end

        it 'should report invalid key input' do
          expect{query("SELECT '2=>4, foo=>5, 5=>17'::#{type}")}.to throw_error "invalid input syntax for #{type}: \"2=>4, foo=>5, 5=>17\""
        end

        it 'should report to big key input' do
          expect{query("SELECT '2=>4, 4000000000=>5, 5=>17'::#{type}")}.to throw_error "#{type} \"2=>4, 4000000000=>5, 5=>17\" is out of range"
        end

        it 'should report to small key input' do
          expect{query("SELECT '2=>4, -4000000000=>5, 5=>17'::#{type}")}.to throw_error "#{type} \"2=>4, -4000000000=>5, 5=>17\" is out of range"
        end

        it 'should report invalid delimiter input' do
          expect{query("SELECT '2=>4, 10=5, 5=>17'::#{type}")}.to throw_error "invalid input syntax for #{type}: \"2=>4, 10=5, 5=>17\""
        end
      end
    end
  end
end