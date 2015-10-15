# encoding: utf-8
require 'minitest_helper'

describe Ask do
  before :each do
    IOHelper.output = ""
    IOHelper.keys = nil
  end

  ['list', 'checkbox', 'input', 'confirm'].each do |method|
    it "respond to #{method} method" do
      Ask.method_defined?(method).must_equal true
    end
  end

end
