require 'spec_helper'
describe "isagg" do

  it 'should be upgradeable' do
    query("CREATE EXTENSION istore VERSION '0.1.3'")
    query("ALTER EXTENSION istore UPDATE TO '0.1.4'")
    query("ALTER EXTENSION istore UPDATE TO '0.1.3'")
    query("SELECT e.extname, e.extversion FROM pg_catalog.pg_extension e WHERE e.extname = 'istore'ORDER BY 1;").should match\
    "istore", "0.1.3"
  end

  it 'should be downgradeable' do
    query "CREATE EXTENSION istore;"
    query "ALTER EXTENSION istore UPDATE TO '0.1.3';"
    query("SELECT e.extname, e.extversion FROM pg_catalog.pg_extension e WHERE e.extname = 'istore'ORDER BY 1;").should match\
    "istore", "0.1.3"
  end
end