require 'spec_helper'

describe MarkLogic::Queries::CollectionQuery do

  describe "#to_xqy" do
    it "should handle a single collection" do
      q = MarkLogic::Queries::CollectionQuery.new("foo")
      expect(q.to_xqy).to eq(%Q{cts:collection-query(("foo"))})
    end

    it "should handle multiple collections" do
      q = MarkLogic::Queries::CollectionQuery.new(["foo", "bar", "baz"])
      expect(q.to_xqy).to eq(%Q{cts:collection-query(("foo","bar","baz"))})
    end
  end
end
