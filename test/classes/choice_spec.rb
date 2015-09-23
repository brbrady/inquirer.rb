# encoding: utf-8
require 'minitest_helper'

describe Choice do
  before :each do
    IOHelper.output = ''
  end

  it 'should return the choice character' do
    IOHelper.keys = 'a'
    Choice.ask('?', ['a','b','c']).must_equal 'a'
    IOHelper.keys = 'b'
    Choice.ask('?', {'a' => nil,'b' => nil}).must_equal 'b'
  end

  it 'should return the default if there is a default and enter is pressed' do
    IOHelper.keys = "\r"
    Choice.ask('?', ['a','b', 'c'], 'c').must_equal 'c'
  end

  it 'should print a warning if there is no default' do
    IOHelper.keys = ["\r"]
    out, err = capture_io do
      Choice.ask('?', ['a','b', 'c'])
    end
    err.must_equal Term::ANSIColor.yellow("No default value, please make a selection.") + "\n"
  end

  it 'should print the choice character if choices is an array' do
    IOHelper.keys = 'a'
    Choice.ask('?', ['a', 'b', 'c'])
    IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('a')}\n"
  end

  it 'should print the value for the choice if choices is a hash, but return the choice' do
    IOHelper.keys = 'a'
    Choice.ask('?', {'a' => 'Eh?', 'b' => 'Bee'}).must_equal 'a'
    IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('Eh?')}\n"
  end
end
