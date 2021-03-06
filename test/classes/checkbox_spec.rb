# encoding: utf-8
require 'minitest_helper'

describe Inquirer::Prompts::Checkbox do
  before :each do
    Inquirer::IOHelper.output = ""
    Inquirer::IOHelper.keys = nil
  end

  [
    Inquirer::Prompts::Checkbox.method(:ask),
    Ask.method(:checkbox)
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
      Inquirer::IOHelper.output.must_equal "select:\n\e[36m‣\e[0m⬡ one\n ⬡ two\n ⬡ three\n"
    end

    it "renders the dialog with 3 items with defaults" do
      meth.call "select", ["one","two","three"], default: [true, false, true], clear: false, response: false
      Inquirer::IOHelper.output.must_equal "select:\n\e[36m‣\e[0m\e[36m⬢\e[0m one\n ⬡ two\n \e[36m⬢\e[0m three\n"
    end

    it "it finishes selection on pressing enter" do
      Inquirer::IOHelper.keys = "enter"
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal [false,false,false]
    end

    it "it finishes selection on pressing enter with defaults" do
      Inquirer::IOHelper.keys = "enter"
      meth.call( "select", ["one","two","three"], default: [true, false, true], clear: false, response: false
               ).must_equal [true,false,true]
    end

    it "selects and renders other items correctly (press down, press up, space, cycle)" do
      Inquirer::IOHelper.keys = ["down","space","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal [false,true,false]
      Inquirer::IOHelper.output.must_equal "select:\n ⬡ one\n\e[36m‣\e[0m\e[36m⬢\e[0m two\n ⬡ three\n"

      Inquirer::IOHelper.keys = ["space","down","space","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal [true,true,false]
      Inquirer::IOHelper.output.must_equal "select:\n \e[36m⬢\e[0m one\n\e[36m‣\e[0m\e[36m⬢\e[0m two\n ⬡ three\n"

      Inquirer::IOHelper.keys = ["space","down","space","down","space","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal [true,true,true]
      Inquirer::IOHelper.output.must_equal "select:\n \e[36m⬢\e[0m one\n \e[36m⬢\e[0m two\n\e[36m‣\e[0m\e[36m⬢\e[0m three\n"

      Inquirer::IOHelper.keys = ["down","down","down","space","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal [true,false,false]
      Inquirer::IOHelper.output.must_equal "select:\n\e[36m‣\e[0m\e[36m⬢\e[0m one\n ⬡ two\n ⬡ three\n"

      Inquirer::IOHelper.keys = ["up","space","enter"]
      meth.call( "select", ["one","two","three"], clear: false, response: false
               ).must_equal [false,false,true]
      Inquirer::IOHelper.output.must_equal "select:\n ⬡ one\n ⬡ two\n\e[36m‣\e[0m\e[36m⬢\e[0m three\n"
    end

    it "selects and renders response correctly" do
      Inquirer::IOHelper.keys = ["down","space","enter"]
      meth.call( "select", ["one","two","three"])
      Inquirer::IOHelper.output.must_equal "select: \e[36mtwo\e[0m\n"

      Inquirer::IOHelper.keys = ["space","down","space","enter"]
      meth.call( "select", ["one","two","three"])
      Inquirer::IOHelper.output.must_equal "select: \e[36mone, two\e[0m\n"
    end

  end
end
