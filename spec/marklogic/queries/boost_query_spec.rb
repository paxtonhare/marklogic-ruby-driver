require 'spec_helper'

describe MarkLogic::Queries::BoostQuery do

  describe "#to_xqy" do
    it "should create xquery correctly" do
      q = MarkLogic::Queries::BoostQuery.new(
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::CollectionQuery.new("bar"))
      expect(q.to_xqy).to eq(%Q{cts:boost-query(cts:directory-query(("/foo/")),cts:collection-query(("bar")))})
    end
  end
end
