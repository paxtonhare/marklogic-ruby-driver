require 'spec_helper'

describe MarkLogic::Queries::OrQuery do

  describe "to_xqy" do
    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new
      expect(q.to_xqy).to eq(%Q{cts:or-query(())})
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new([])
      expect(q.to_xqy).to eq(%Q{cts:or-query(())})
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/")
      ])
      expect(q.to_xqy).to eq(%Q{cts:or-query((cts:directory-query(("/foo/"))))})
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ])
      expect(q.to_xqy).to eq(%Q{cts:or-query((cts:directory-query(("/foo/")), cts:directory-query(("/bar/"))))})
    end

  end
end
