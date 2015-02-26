require 'spec_helper'

describe MarkLogic::Forest do

  describe "#init" do
    let(:forest) do
      MarkLogic::Forest.new("marklogic-gem-test")
    end

    it "should create accessors" do
      expect(forest.forest_name).to eq("marklogic-gem-test")
    end
  end

  describe "#create" do
    before do
      @forest = MarkLogic::Forest.new("marklogic-gem-test")
    end

    it "should create a forest" do
      expect(@forest).to_not be_exists
      @forest.create
      expect(@forest).to be_exists

      @forest.drop
      expect(@forest).to_not be_exists
    end

  end
end
