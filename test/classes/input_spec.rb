# encoding: utf-8
require 'minitest_helper'

describe Input do
  before :each do
    IOHelper.output = ""
    IOHelper.keys = ['t','y','p','e','d',' ','i','n','p','u','t',"\r"]
  end

  it "should use chars value from the user" do
    Input.ask("please type input").must_equal "typed input"
  end

  it "accepts and renders response correctly" do
    Input.ask("please type input")
    IOHelper.output.must_equal "please type input: \e[36mtyped input\e[0m\n"
  end

  it "should return default value if given and there is no input" do
    IOHelper.keys = "\r"
    Confirm.ask("Are you sure?", default: "I'm default").must_equal "I'm default"
  end

  it "should print out a warning if argument validation fails" do
    out, err = capture_io do
      Input.ask("please type input", validate: /valid/)
    end
    assert_equal "#{Term::ANSIColor.yellow("Invalid answer (must match /valid/)")}\n", err
  end

  it "accepts an override to the validation failure message" do
    out, err = capture_io do
      Input.ask("please type input",
                validate: proc do false end,
                invalid_response: "Response failed validation Proc"
               )
    end
    assert_equal "#{Term::ANSIColor.yellow("Response failed validation Proc")}\n", err
  end
end
