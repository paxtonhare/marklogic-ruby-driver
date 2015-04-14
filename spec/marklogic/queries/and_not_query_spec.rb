require 'spec_helper'

describe MarkLogic::Queries::AndNotQuery do

  describe "#to_xqy" do
    it "should create xquery correctly" do
      q = MarkLogic::Queries::AndNotQuery.new(
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::CollectionQuery.new("bar"))
      expect(q.to_xqy).to eq(%Q{cts:and-not-query(cts:directory-query(("/foo/")),cts:collection-query(("bar")))})
    end
  end
end
