require 'spec_helper'

describe MarkLogic::Queries::OrQuery do

  describe "to_json" do
    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new
      expect(q.to_json).to eq({
        "or-query" => {
          "queries" => []
        }
      })
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new([])
      expect(q.to_json).to eq({
        "or-query" => {
          "queries" => []
        }
      })
    end

    it "should create json correctly" do
      q = MarkLogic::Queries::OrQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/")
      ])
      expect(q.to_json).to eq({
        "or-query" => {
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
      q = MarkLogic::Queries::OrQuery.new([
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::DirectoryQuery.new("/bar/")
      ])
      expect(q.to_json).to eq({
        "or-query" => {
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
