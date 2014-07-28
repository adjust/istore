require 'spec_helper'

describe 'istore' do
  before do
    install_extension
  end

  describe "function foo" do
    it "shoul return the input" do
      query("SELECT foo(10)").should match '10'
    end
  end
end
