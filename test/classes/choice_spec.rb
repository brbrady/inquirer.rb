# encoding: utf-8
require 'minitest_helper'

describe Ask::Prompts::Choice do
  before :each do
    IOHelper.output = ''
  end

  [
    Ask::Prompts::Choice.method(:ask),
    Ask.method(:choice)
  ].each do |meth|

    it 'should return the choice character' do
      IOHelper.keys = 'a'
      meth.call('?', ['a','b','c']).must_equal 'a'
      IOHelper.keys = 'b'
      meth.call('?', {'a' => nil,'b' => nil}).must_equal 'b'
    end

    it 'should return the default if there is a default and enter is pressed' do
      IOHelper.keys = "\r"
      meth.call('?', ['a','b', 'c'], default: 'c').must_equal 'c'
      IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('c')}\n"

      IOHelper.keys = "\r"
      meth.call('?', ['foo', 'bar', 'qux'], default: 'bar')
      IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('bar')}\n"
    end

    it 'should print a warning if enter is pressed and there is no default' do
      IOHelper.keys = "\r"
      out, err = capture_io do
        meth.call('?', ['a','b', 'c'])
      end
      err.must_equal Term::ANSIColor.yellow("No default value, please make a selection.") + "\n"
    end

    it 'should print the choice character if choices is an array' do
      IOHelper.keys = 'a'
      meth.call('?', ['a', 'b', 'c'])
      IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('a')}\n"
    end

    it 'should print the value for the choice if choices is a hash, but return the choice' do
      IOHelper.keys = 'a'
      meth.call('?', {'a' => 'Eh?', 'b' => 'Bee'}).must_equal 'a'
      IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('Eh?')}\n"
      IOHelper.keys = 'b'
      meth.call('?', {'aa' => 'Eh?', 'bb' => 'Bee'}).must_equal 'bb'
      IOHelper.output.must_equal "?: #{Term::ANSIColor.cyan('Bee')}\n"
    end

    describe 'prompt output' do
      before { module IOHelper;def clear;end;end }
      after { module IOHelper;def clear;@output = '';end;end }

      it 'should surround the selection characters with brackets' do
        IOHelper.keys = 'a'
        meth.call('?', ['a', 'b', 'c'])
        IOHelper.output.must_equal "?: ([a], [b], [c])?: #{Term::ANSIColor.cyan('a')}\n"

        IOHelper.output = ''
        IOHelper.keys = 'b'
        meth.call('?', ['foo', 'bar', 'qux'])
        IOHelper.output.must_equal "?: ([f]oo, [b]ar, [q]ux)?: #{Term::ANSIColor.cyan('bar')}\n"
      end

      it 'should capitalize the selection character of the default option' do
        IOHelper.keys = ''
        meth.call('?', ['a', 'b', 'c'], default: 'a')
        IOHelper.output.must_equal "?: ([A], [b], [c])?: #{Term::ANSIColor.cyan('')}\n"

        IOHelper.output = ''
        meth.call('?', ['foo', 'bar', 'qux'], default: 'bar')
        IOHelper.output.must_equal "?: ([f]oo, [B]ar, [q]ux)?: #{Term::ANSIColor.cyan('')}\n"

        IOHelper.output = ''
        meth.call('?', ['foo', 'bar', 'baz'], default: 'baz')
        IOHelper.output.must_equal "?: ([f]oo, [b]ar, b[A]z)?: #{Term::ANSIColor.cyan('')}\n"

        IOHelper.output = ''
        meth.call('?', ['foo', 'bar', 'qux'], default: 'bar')
        IOHelper.output.must_equal "?: ([f]oo, [B]ar, [q]ux)?: #{Term::ANSIColor.cyan('')}\n"
      end

      it 'should allow brackets in the option string to override the selection character' do
        IOHelper.keys = 'z'
        meth.call('?', ['foo', 'bar', 'ba[z]']).must_equal 'baz'
        IOHelper.output.must_equal "?: ([f]oo, [b]ar, ba[z])?: #{Term::ANSIColor.cyan('baz')}\n"

        IOHelper.output = ''
        IOHelper.keys = 'b'
        meth.call('?', ['foo', 'bar', '[b]az']).must_equal 'baz'
        IOHelper.output.must_equal "?: ([f]oo, b[a]r, [b]az)?: #{Term::ANSIColor.cyan('baz')}\n"
      end

      it 'should use the next character in the option string as selection character ' +
        'if there is a conflict with unique keys' do
        # also tests:
        # it 'should remove the option brackets from the response value'
        IOHelper.keys = 'g'
        meth.call('?', ['foo', 'bar', 'baz', 'bag']).must_equal 'bag'
        IOHelper.output.must_equal "?: ([f]oo, [b]ar, b[a]z, ba[g])?: #{Term::ANSIColor.cyan('bag')}\n"
      end

      it 'will allow a capital bracketed letter in the option string to override the default choice ' +
        'if no default is explicitly specified as a method argument' do
        IOHelper.keys = "\r"
        meth.call('?', ['foo', 'b[A]r', 'baz']).must_equal 'bar'
        IOHelper.output.must_equal "?: ([f]oo, b[A]r, [b]az)?: #{Term::ANSIColor.cyan('bar')}\n"

        IOHelper.output = ''
        IOHelper.keys = "\r"
        meth.call('?', ['[f]oo', 'b[A]r', '[B]az'], default: 'foo').must_equal 'foo'
        IOHelper.output.must_equal "?: ([F]oo, b[A]r, [B]az)?: #{Term::ANSIColor.cyan('foo')}\n"
      end

      it 'will not set a default if default is explicitly specified as false' do
        IOHelper.keys = "\r"
        out, err = capture_io do
          meth.call('?', ['a', 'b', 'c'], default: false)
        end
        err.must_equal Term::ANSIColor.yellow("No default value, please make a selection.") + "\n"
      end
    end # describe 'prompt output' do

    describe 'errors' do
      it 'should throw an error if unable to select a unique selection character' do
        err = ->{meth.call('?', ['b', 'bar', 'ba'])}.must_raise ArgumentError
        err.message.must_equal 'No unique selection character available!'
      end
    end # describe 'errors' do
  end
end
