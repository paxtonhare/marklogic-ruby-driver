require 'spec_helper'

describe MarkLogic::Queries::AndQuery do

  describe "to_json" do
    it "should create json correctly" do
      q = MarkLogic::Queries::AndQuery.new
      expect(q.to_json).to eq({
        "and-query" => {
          "queries" => []
        }
      })
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::AndQuery.new([])
      expect(q.to_json).to eq({
        "and-query" => {
          "queries" => []
        }
      })
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::AndQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/")
      ])
      expect(q.to_json).to eq({
        "and-query" => {
          "queries" => [
            {
              "directory-query" => {
                "uri" => "/foo/",
                "infinite" => true
              }
            }
          ]
        }
      })
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::AndQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ])
      expect(q.to_json).to eq({
        "and-query" => {
          "queries" => [
            {
              "directory-query" => {
                "uri" => "/foo/",
                "infinite" => true
              }
            },
            {
              "directory-query" => {
                "uri" => "/bar/",
                "infinite" => true
              }
            }
          ]
        }
      })
    end

  end
end
