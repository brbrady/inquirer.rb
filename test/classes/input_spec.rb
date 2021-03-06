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
      Inquirer::IOHelper.keys = ['t','y','p','e','d',' ','i','n','p','u','t',"\r"]
      meth.call("please type password", password: true)
      Inquirer::IOHelper.frames[-2].must_equal "please type password: ***********"
      Inquirer::IOHelper.output.must_equal "please type password: \e[36m\e[0m\n"
    end

    it "shouldn't get messed up when you move around" do
      Inquirer::IOHelper.keys = ['i','n','p','u','t',(['left']*5),'t','y','p','e','d',' ',"\r"].flatten
      meth.call("please type input")
      Inquirer::IOHelper.frames[-2].must_equal "please type input: typed input"
      Inquirer::IOHelper.output.must_equal "please type input: \e[36mtyped input\e[0m\n"
    end

    it "should delete the character at the specified position" do
      Inquirer::IOHelper.keys = ['t','y','u','p','e','d',' ','i','n','p','u','t',['left']*9,'backspace',"\r"].flatten
      meth.call("please type input")
      Inquirer::IOHelper.frames[-2].must_equal "please type input: typed input"
      Inquirer::IOHelper.output.must_equal "please type input: \e[36mtyped input\e[0m\n"
    end

    it "should delete the character at the specified position" do
      Inquirer::IOHelper.keys = ['t','y','u','p','e','d',' ','i','n','p','u','t',['left']*10,'delete',"\r"].flatten
      meth.call("please type input")
      Inquirer::IOHelper.frames[-2].must_equal "please type input: typed input"
      Inquirer::IOHelper.output.must_equal "please type input: \e[36mtyped input\e[0m\n"
    end
  end
end
