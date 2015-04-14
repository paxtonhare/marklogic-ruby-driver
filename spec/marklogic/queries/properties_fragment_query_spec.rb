require 'spec_helper'

describe MarkLogic::Queries::PropertiesFragmentQuery do

  describe "#to_xqy" do
    it "should create xquery correctly" do
      q = MarkLogic::Queries::PropertiesFragmentQuery.new(MarkLogic::Queries::ValueQuery.new("bar", "baz"))
      expect(q.to_xqy).to eq(%Q{cts:properties-fragment-query(cts:json-property-value-query("bar",("baz"),("exact"),1.0))})
    end
  end
end
