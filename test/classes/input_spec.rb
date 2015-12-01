# encoding: utf-8
require 'minitest_helper'

describe Inquirer::Prompts::Input do
  before :each do
    Inquirer::IOHelper.output = ""
    Inquirer::IOHelper.keys = ['t','y','p','e','d',' ','i','n','p','u','t',"\r"]
  end

  [
    Inquirer::Prompts::Input.method(:ask),
    Ask.method(:input)
  ].each do |meth|

    it "should use chars value from the user" do
      meth.call("please type input").must_equal "typed input"
    end

    it "accepts and renders response correctly" do
      meth.call("please type input")
      Inquirer::IOHelper.output.must_equal "please type input: \e[36mtyped input\e[0m\n"
    end

    it "should provide a password input without displaying the value" do
      meth.call("please type password", password: true)
      Inquirer::IOHelper.output.must_equal "please type password: \e[36m***********\e[0m\n"
    end
  end

end
