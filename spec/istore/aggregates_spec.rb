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

describe "extend" do
  before do
    install_extension
  end
  %w(istore bigistore).each do |type|
    describe type do
      it 'should correctly extend internal aggregation state while summing istores which total length is larger than default capacity' do
        query("CREATE TABLE test (v #{type})")
        query("INSERT INTO test SELECT #{type}(array_agg(x), array_agg(x)) FROM generate_series(1, 31, 2) AS a(x)")
        query("INSERT INTO test SELECT #{type}(array_agg(x), array_agg(x)) FROM generate_series(2, 32, 2) AS a(x)")
        query("SELECT SUM(v) FROM test").should match \
        '"1"=>"1", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5", "6"=>"6", "7"=>"7", "8"=>"8", "9"=>"9", "10"=>"10", "11"=>"11", "12"=>"12", "13"=>"13", "14"=>"14", "15"=>"15", "16"=>"16", "17"=>"17", "18"=>"18", "19"=>"19", "20"=>"20", "21"=>"21", "22"=>"22", "23"=>"23", "24"=>"24", "25"=>"25", "26"=>"26", "27"=>"27", "28"=>"28", "29"=>"29", "30"=>"30", "31"=>"31", "32"=>"32"'
      end
    end
  end
end

describe "extend" do
  before do
    install_extension
  end
  %w(istore bigistore).each do |type|
    describe type do
      it 'should correctly aggregate using sum_floor' do
        query("CREATE TABLE test (v #{type})")
        query("INSERT INTO test SELECT #{type}(array_agg(x), array_agg(x)) FROM generate_series(1, 21, 2) AS a(x)")
        query("INSERT INTO test SELECT #{type}(array_agg(x), array_agg(x)) FROM generate_series(2, 22, 2) AS a(x)")
        query("INSERT INTO test SELECT #{type}(array_agg(x), array_agg(x)) FROM generate_series(1, 21, 2) AS a(x)")
        query("SELECT SUM_FLOOR(v, 10) FROM test").should match \
        '"10"=>"10", "11"=>"22", "12"=>"12", "13"=>"26", "14"=>"14", "15"=>"30", "16"=>"16", "17"=>"34", "18"=>"18", "19"=>"38", "20"=>"20", "21"=>"42", "22"=>"22"'
      end
    end
  end
end
