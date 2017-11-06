require 'spec_helper'
describe "isagg" do
  before do
    install_extension
  end

  %w(int bigint).each do |type|
    describe type do
      it 'should skip null keys' do
        query("SELECT id, isagg(NULLIF(i%10,3), NULLIF(i::#{type}, 50) ) FROM generate_series(1,100) i, generate_series(1,3) id GROUP BY id ORDER BY id;").should match \
        ['1', '"0"=>"500", "1"=>"460", "2"=>"470", "4"=>"490", "5"=>"500", "6"=>"510", "7"=>"520", "8"=>"530", "9"=>"540"' ],
        ['2', '"0"=>"500", "1"=>"460", "2"=>"470", "4"=>"490", "5"=>"500", "6"=>"510", "7"=>"520", "8"=>"530", "9"=>"540"' ],
        ['3', '"0"=>"500", "1"=>"460", "2"=>"470", "4"=>"490", "5"=>"500", "6"=>"510", "7"=>"520", "8"=>"530", "9"=>"540"' ]
      end

      it 'should skip null values' do
        query("SELECT id, isagg((i%10), NULL::#{type}) FROM generate_series(1,100) i, generate_series(1,3) id GROUP BY id ORDER BY id;").should match \
        ['1', nil ],
        ['2', nil ],
        ['3', nil ]
      end
    end
  end
end