require 'spec_helper'

describe MarkLogic::Queries::DirectoryQuery do

  describe "#to_xqy" do
    it "should have a default depth" do
      q = MarkLogic::Queries::DirectoryQuery.new("/foo/")
      expect(q.to_xqy).to eq(%Q{cts:directory-query(("/foo/"))})
    end

    it "should accept a supplied depth" do
      q = MarkLogic::Queries::DirectoryQuery.new("/foo/", "infinity")
      expect(q.to_xqy).to eq(%Q{cts:directory-query(("/foo/"),"infinity")})
    end

    it "should accept multiple uri" do
      q = MarkLogic::Queries::DirectoryQuery.new(["/foo/", "/bar/", "/baz/"], "infinity")
      expect(q.to_xqy).to eq(%Q{cts:directory-query(("/foo/","/bar/","/baz/"),"infinity")})
    end
  end
end
