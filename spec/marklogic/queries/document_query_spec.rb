require 'spec_helper'

describe MarkLogic::Queries::DocumentQuery do

  describe "#to_xqy" do
    it "should have a default depth" do
      q = MarkLogic::Queries::DocumentQuery.new("/foo/blah.json")
      expect(q.to_xqy).to eq(%Q{cts:document-query(("/foo/blah.json"))})
    end

    it "should accept multiple uris" do
      q = MarkLogic::Queries::DocumentQuery.new(["/foo/blah.json", "/bar/stuff.json"])
      expect(q.to_xqy).to eq(%Q{cts:document-query(("/foo/blah.json","/bar/stuff.json"))})
    end
  end
end
