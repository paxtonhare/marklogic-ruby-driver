require 'spec_helper'

describe MarkLogic::Queries::DocumentFragmentQuery do

  describe "#to_xqy" do
    it "should create xquery correctly" do
      q = MarkLogic::Queries::DocumentFragmentQuery.new(MarkLogic::Queries::ValueQuery.new("bar", "baz"))
      expect(q.to_xqy).to eq(%Q{cts:document-fragment-query(cts:json-property-value-query("bar",("baz"),("exact"),1.0))})
    end
  end
end
