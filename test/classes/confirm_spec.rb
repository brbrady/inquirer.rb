# encoding: utf-8
require 'minitest_helper'

describe Ask::Prompts::Confirm do
  before :each do
    IOHelper.output = ""
  end

  [
    Ask::Prompts::Confirm.method(:ask),
    Ask.method(:confirm)
  ].each do |meth|

    it "should return true for y and Y and enter when default" do
      IOHelper.keys = "y"
      meth.call("Are you sure?").must_equal true
      IOHelper.keys = "Y"
      meth.call("Are you sure?").must_equal true
      IOHelper.keys = "\r"
      meth.call("Are you sure?", default: true).must_equal true
    end

    it "should return false for n and N and enter when default" do
      IOHelper.keys = "n"
      meth.call("Are you sure?").must_equal false
      IOHelper.keys = "N"
      meth.call("Are you sure?").must_equal false
      IOHelper.keys = "\r"
      meth.call("Are you sure?", default: false).must_equal false
    end

    it "should return true if not default given" do
      IOHelper.keys = "\r"
      meth.call("Are you sure?").must_equal true
    end

    it "accepts and renders response correctly" do
      IOHelper.keys = "n"
      meth.call("Are you sure?")
      IOHelper.output.must_equal "Are you sure?: \e[36mNo\e[0m\n"

      IOHelper.keys = "N"
      meth.call("Are you sure?")
      IOHelper.output.must_equal "Are you sure?: \e[36mNo\e[0m\n"

      IOHelper.keys = "y"
      meth.call("Are you sure?")
      IOHelper.output.must_equal "Are you sure?: \e[36mYes\e[0m\n"

      IOHelper.keys = "y"
      meth.call("Are you sure?")
      IOHelper.output.must_equal "Are you sure?: \e[36mYes\e[0m\n"
    end

    it "should return default value if given and there is no input" do
      IOHelper.keys = "\r"
      meth.call("Are you sure?", default: "I'm default").must_equal "I'm default"
    end

  end
end
