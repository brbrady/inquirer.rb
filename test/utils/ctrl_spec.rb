require 'minitest_helper'

TEST_STRING="  foo   bar baz  "

describe Ctrl do
  include Ctrl
  before :each do
    @value = TEST_STRING
    @pos = 0
  end

  describe "#ctrl" do
    describe :w do
      it "should delete to the beginning of the word before @pos" do
        ctrl :w
        @value.must_equal "  foo   bar "
        ctrl :w
        @value.must_equal "  foo   "
        ctrl :w
        @value.must_equal "  "
        ctrl :w
        @value.must_equal ""
      end

      it "won't delete anything if there's nothing in front of it" do
        @pos = @value.length
        ctrl :w
        @value.must_equal TEST_STRING
      end
    end # describe :w do
    describe :k do
      it "should delete to the end of the line after @pos" do
        @pos = 5
        ctrl :k
        @value.must_equal "  foo   bar "
        @pos = @value.length
        ctrl :k
        @value.must_equal ""
      end
    end # describe :k do
    describe :u do
      it "should delete to the beginning of the line before @pos" do
        @pos = 12
        ctrl :u
        @value.must_equal "   bar baz  "
        @pos = 0
        ctrl :u
        @value.must_equal ""
      end
    end # describe :u do
  end # describe "#ctrl" do
  describe "#alt" do
    describe :d do
      it "will delete to the end of the word after @pos" do
        @pos = @value.length
        alt :d
        @value.must_equal "   bar baz  "
        @pos.must_equal @value.length
        alt :d
        @value.must_equal " baz  "
        @pos.must_equal @value.length
        alt :d
        @value.must_equal "  "
        @pos.must_equal @value.length
        alt :d
        @value.must_equal ""
        @pos.must_equal @value.length
      end

      it "will update the position" do
        @pos = @value.length
        alt :d
        @pos.must_equal @value.length
        @pos = 5
        alt :d
        @pos.must_equal 2
        alt :d
        @pos.must_equal 0
      end

      it "won't delete anything if there's nothing after it" do
        alt :d
        @value.must_equal TEST_STRING
      end
    end # describe :d do

    describe :f do
      it "jumps to the end of the word" do
        @pos = @value.length
        alt :f
        @pos.must_equal 12
        alt :f
        @pos.must_equal 6
        alt :f
        @pos.must_equal 2
        alt :f
        @pos.must_equal 0
        alt :f
        @pos.must_equal 0
      end
    end # describe :f do
    describe :b do
      it "jumps to the beginning of the word" do
        alt :b
        @pos.must_equal 5
        alt :b
        @pos.must_equal 9
        alt :b
        @pos.must_equal 15
        alt :b
        @pos.must_equal 17
        alt :b
      end
    end
  end # describe "#alt" do
end
