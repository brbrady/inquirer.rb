# encoding: utf-8
require 'minitest_helper'

describe Inquirer::Prompts::List do
  before :each do
    Inquirer::IOHelper.output = ""
    Inquirer::IOHelper.keys = nil
  end

  [
    Inquirer::Prompts::List.method(:ask),
    Ask.method(:list)
  ].each do |meth|

    it "finishes rendering with a clear" do
      meth.call "select", ["one","two","three"], response: false
      Inquirer::IOHelper.output.must_equal ""
    end

    it "doesn't render the dialog with 0 items" do
      meth.call "select", [], clear: false, response: false
      Inquirer::IOHelper.output.must_equal ""
    end

    it "renders the dialog with 3 items" do
      meth.call "select", ["one","two","three"], clear: false, response: false
      Inquirer::IOHelper.output.must_equal "select:\n\e[36m‣\e[0m \e[36mone\e[0m\n  two\n  three\n"
    end

    it "it finishes selection on pressing enter" do
      Inquirer::IOHelper.keys = "enter"
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal 0
    end

    it "selects and renders other items correctly (press down, press up, cycle)" do
      Inquirer::IOHelper.keys = ["down","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal 1
      Inquirer::IOHelper.output.must_equal "select:\n  one\n\e[36m‣\e[0m \e[36mtwo\e[0m\n  three\n"

      Inquirer::IOHelper.keys = ["down","down","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal 2
      Inquirer::IOHelper.output.must_equal "select:\n  one\n  two\n\e[36m‣\e[0m \e[36mthree\e[0m\n"

      Inquirer::IOHelper.keys = ["down","down","down","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal 0
      Inquirer::IOHelper.output.must_equal "select:\n\e[36m‣\e[0m \e[36mone\e[0m\n  two\n  three\n"

      Inquirer::IOHelper.keys = ["down","up","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal 0
      Inquirer::IOHelper.output.must_equal "select:\n\e[36m‣\e[0m \e[36mone\e[0m\n  two\n  three\n"

      Inquirer::IOHelper.keys = ["up","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal 2
      Inquirer::IOHelper.output.must_equal "select:\n  one\n  two\n\e[36m‣\e[0m \e[36mthree\e[0m\n"
    end

    it "selects and renders response correctly" do
      Inquirer::IOHelper.keys = ["down","enter"]
      meth.call( "select", ["one","two","three"])
      Inquirer::IOHelper.output.must_equal "select: \e[36mtwo\e[0m\n"

      Inquirer::IOHelper.keys = ["down","down","enter"]
      meth.call( "select", ["one","two","three"])
      Inquirer::IOHelper.output.must_equal "select: \e[36mthree\e[0m\n"
    end

  end
end
