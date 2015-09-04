# encoding: utf-8
require 'minitest_helper'

describe Password do
  before :each do
    IOHelper.output = ""
    IOHelper.keys = ['t','y','p','e','d',' ','i','n','p','u','t',"\r"]
  end

  it "should use chars value from the user" do
    Password.ask("please type input").must_equal "typed input"
  end

  it "accepts and renders response correctly" do
    Password.ask("please type input")
    IOHelper.output.must_equal "please type input: \e[36m***********\e[0m\n"
  end
end
