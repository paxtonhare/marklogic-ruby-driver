require 'spec_helper'

describe MarkLogic::Queries::ValueQuery do

  describe "to_json" do
    it "should create text values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123")
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "id",
             "text" => "123",
             "term-option" => "exact"
          }
      })
    end

    it "should create boolean values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:alive, true)
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "alive",
             "text" => true,
             "type" => "boolean",
             "term-option" => "exact"
          }
      })
    end

    it "should create numeric values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, 123)
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "count",
             "text" => 123,
             "type" => "number",
             "term-option" => "exact"
          }
      })
    end

    it "should create null values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, nil)
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "count",
             "text" => nil,
             "type" => "null",
             "term-option" => "exact"
          }
      })
    end

    it "should add fragment scope when given" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123", :fragment_scope => "properties")
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "id",
             "text" => "123",
             "term-option" => "exact",
             "fragment-scope" => "properties"
          }
      })
    end

    it "should add term options scope when given" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123", :term_options => ["exact", "case-insensitive"])
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "id",
             "text" => "123",
             "term-option" => ["exact", "case-insensitive"]
          }
      })
    end

    it "should add fragment scope when given" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123", :weight => 1.0)
      expect(q.to_json).to eq({
        "value-query" => {
            "json-property" => "id",
             "text" => "123",
             "term-option" => "exact",
             "weight" => 1.0
          }
      })
    end
  end
end
