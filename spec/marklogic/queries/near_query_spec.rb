require 'spec_helper'

describe MarkLogic::Queries::NearQuery do

  describe "#to_xqy" do
    it "should handle a single query" do
      q = MarkLogic::Queries::NearQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/")
      ])
      expect(q.to_xqy).to eq(%Q{cts:near-query((cts:directory-query(("/foo/"))),10,(),1.0)})
    end

    it "should handle multiple queries" do
      q = MarkLogic::Queries::NearQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ])
      expect(q.to_xqy).to eq(%Q{cts:near-query((cts:directory-query(("/foo/")),cts:directory-query(("/bar/"))),10,(),1.0)})
    end

    it "should handle multiple queries with a distance" do
      q = MarkLogic::Queries::NearQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ],
      5)
      expect(q.to_xqy).to eq(%Q{cts:near-query((cts:directory-query(("/foo/")),cts:directory-query(("/bar/"))),5,(),1.0)})
    end

    it "should handle multiple queries with a distance and weight" do
      q = MarkLogic::Queries::NearQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ],
      5,
      2.0)
      expect(q.to_xqy).to eq(%Q{cts:near-query((cts:directory-query(("/foo/")),cts:directory-query(("/bar/"))),5,(),2.0)})
    end

    it "should handle multiple queries with a distance and weight and unordered" do
      q = MarkLogic::Queries::NearQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ],
      5,
      2.0,
      ordered: false)
      expect(q.to_xqy).to eq(%Q{cts:near-query((cts:directory-query(("/foo/")),cts:directory-query(("/bar/"))),5,("unordered"),2.0)})
    end

    it "should handle multiple queries with a distance and weight and unordered" do
      q = MarkLogic::Queries::NearQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ],
      5,
      2.0,
      ordered: true)
      expect(q.to_xqy).to eq(%Q{cts:near-query((cts:directory-query(("/foo/")),cts:directory-query(("/bar/"))),5,("ordered"),2.0)})
    end
  end
end
