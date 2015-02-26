require 'spec_helper'

describe MarkLogic::Queries::RangeQuery do

  describe "to_json" do
    it "should create json correctly" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123")
      expect(q.to_json).to eq({
        "range-query" => {
          "type" => "string",
          "json-property" => "id",
           "value" => "123",
           "range-operator" => "="
        }
      })
    end

    it "should add a collation when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :collation => "http://marklogic.com/collation/codepoint")
      expect(q.to_json).to eq({
        "range-query" => {
          "type" => "string",
          "json-property" => "id",
           "value" => "123",
           "range-operator" => "=",
           "collation" => "http://marklogic.com/collation/codepoint"
        }
      })
    end

    it "should add a fragment scope when given" do
      q = MarkLogic::Queries::RangeQuery.new(:id, "=", "string", "123", :fragment_scope => "properties")
      expect(q.to_json).to eq({
        "range-query" => {
          "type" => "string",
          "json-property" => "id",
           "value" => "123",
           "range-operator" => "=",
           "fragment-scope" => "properties"
        }
      })
    end
  end
end
