require 'spec_helper'

describe 'join' do
  before do
    install_extension
  end

  let(:jon_sql) do
    <<-SQL
    SELECT os_name, device_type, country, a.num+b.num FROM(
    VALUES
    ('android'::os_name, 'phone'::device_type, 'de'::country, 10),
    ('android', 'phone', 'us', 10),
    ('android', 'phone', 'de', 10)
    )a(os_name, device_type, country, num)
    JOIN (
    VALUES
    ('android'::os_name, 'phone'::device_type, 'de'::country, 10),
    ('android', 'phone', 'us', 10),
    ('android', 'phone', 'de', 10),
    ('windows', 'phone', 'de', 10)
    )b(os_name, device_type, country, num)
    USING (os_name, device_type, country)
    SQL
  end

  it 'join two tables' do
    query(jon_sql).should match \
       ['android' , 'phone'       , 'de'      ,       20],
       ['android' , 'phone'       , 'de'      ,       20],
       ['android' , 'phone'       , 'us'      ,       20],
       ['android' , 'phone'       , 'de'      ,       20],
       ['android' , 'phone'       , 'de'      ,       20]
  end
end