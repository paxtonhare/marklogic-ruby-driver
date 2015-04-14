require 'spec_helper'

describe MarkLogic::Queries::AndQuery do

  describe "#to_xqy" do
    it "should create xquery correctly" do
      q = MarkLogic::Queries::AndQuery.new
      expect(q.to_xqy).to eq(%Q{cts:and-query(())})
    end

    it "should create xquery correctly" do
      q = MarkLogic::Queries::AndQuery.new([])
      expect(q.to_xqy).to eq(%Q{cts:and-query(())})
    end

    it "should create xquery correctly" do
      q = MarkLogic::Queries::AndQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/")
      ])
      expect(q.to_xqy).to eq(%Q{cts:and-query((cts:directory-query(("/foo/"))))})
    end

    it "should create xquery correctly" do
      q = MarkLogic::Queries::AndQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ])
      expect(q.to_xqy).to eq(%Q{cts:and-query((cts:directory-query(("/foo/")),cts:directory-query(("/bar/"))))})
    end
  end
end
