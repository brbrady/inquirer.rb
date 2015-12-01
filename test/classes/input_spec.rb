# encoding: utf-8
require 'minitest_helper'

describe Ask::Prompts::Input do
  before :each do
    IOHelper.output = ""
    IOHelper.keys = ['t','y','p','e','d',' ','i','n','p','u','t',"\r"]
  end

  [
    Ask::Prompts::Input.method(:ask),
    Ask.method(:input)
  ].each do |meth|

    it "should use chars value from the user" do
      meth.call("please type input").must_equal "typed input"
    end

    it "accepts and renders response correctly" do
      meth.call("please type input")
      IOHelper.output.must_equal "please type input: \e[36mtyped input\e[0m\n"
    end

    it "should provide a password input without displaying the value" do
      meth.call("please type password", password: true)
      IOHelper.output.must_equal "please type password: \e[36m***********\e[0m\n"
    end
  end
end
