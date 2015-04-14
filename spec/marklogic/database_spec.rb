require 'spec_helper'

describe MarkLogic::Database do

  describe "instance" do
    let(:d) do
      MarkLogic::Database.new("marklogic-gem-test")
    end

    it "should create accessors" do
      expect(d.database_name).to eq("marklogic-gem-test")
    end

    it "should create adders" do
      d.add_range_element_index("stuff")
      expect(d['range-element-index'].length).to eq(1)
      expect(d['range-element-index'][0].to_json).to eq(
        {
          "scalar-type" => "string",
          "namespace-uri" => "",
          "localname" => "stuff",
          "collation" => MarkLogic::DEFAULT_COLLATION,
          "range-value-positions" => false,
          "invalid-values" => "reject"
        }
      )
    end
  end

  describe "stale?" do
    let(:d) do
      MarkLogic::Database.new("marklogic-gem-test")
    end

    before do
      d.drop if d.exists?
      d.create
    end

    after do
      d.reset_indexes
      d.drop
    end

    it "should determine stale state properly" do

      expect(d).to be_exists
      expect(d).to_not be_stale

      d.add_range_element_index("junk")

      expect(d).to be_stale

      d.update

      expect(d).to_not be_stale

      d.add_range_element_index("whut")
      d.add_range_element_index("stuff")

      expect(d).to be_stale

      d.update

      d.reset_indexes

      d.add_range_element_index("whut")
      d.add_range_element_index("stuff")
      d.add_range_element_index("junk")

      expect(d).to_not be_stale
    end
  end

  describe "#collections" do
    let(:d) do
      MarkLogic::Database.new("marklogic-gem-test", CONNECTION)
    end

    before do
      # d.drop if d.exists?
      d.create
    end

    after do
      d.drop
    end

    it "should return empty array when no collections are present" do
      d.collections.each do |collection|
        d.collection(collection).drop
      end
      expect(d.collections.count).to eq(0)
    end

    it "should return collections" do
      collection = d.collection("my-test")
      collection.save({ name: "testing" })
      collection = d.collection("my-test2")
      collection.save({ name: "testing2" })

      expect(d.collections.count).to eq(2)
    end
  end

  describe "#clear" do
  end
end
