require 'spec_helper'

describe MarkLogic::Queries::RangeQuery do

  describe "#to_xqy" do
    it "should handle numeric values correctly" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "integer", 123)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",(123),(),1.0)})
    end

    it "should handle boolean values correctly" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "boolean", true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",(fn:true()),(),1.0)})
    end

    it "should handle boolean values correctly" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "boolean", false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",(fn:false()),(),1.0)})
    end

    it "should handle string values correctly" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123")
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),(),1.0)})
    end

    it "should add a collation when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :collation => "http://marklogic.com/collation/codepoint")
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("collation=http://marklogic.com/collation/codepoint"),1.0)})
    end

    it "should add a min-occurs when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :min_occurs => 1)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("min-occurs=1"),1.0)})
    end

    it "should add a max-occurs when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :max_occurs => 1)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("max-occurs=1"),1.0)})
    end

    it "should add a score-function when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :score_function => "linear")
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("score-function=linear"),1.0)})
    end

    it "should add a slope-factor when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :slope_factor => 1.0)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("slope-factor=1.0"),1.0)})
    end

    it "should set the cached option" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :cached => true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("cached"),1.0)})
    end

    it "should set the uncached option" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :cached => false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("uncached"),1.0)})
    end

    it "should set the synonym option" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :synonym => true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("synonym"),1.0)})
    end

    it "should set the multiple options" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", collation: "http://marklogic.com/collation/codepoint", cached: false, synonym: true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-range-query("id","=",("123"),("collation=http://marklogic.com/collation/codepoint","uncached","synonym"),1.0)})
    end
  end
end
