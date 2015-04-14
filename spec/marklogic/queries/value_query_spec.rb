require 'spec_helper'

describe MarkLogic::Queries::ValueQuery do

  describe "#to_xqy" do
    it "should create text values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123")
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("id",("123"),("exact"),1.0)})
    end

    it "should create boolean values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:alive, true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("alive",(fn:true()),("exact"),1.0)})
    end

    it "should create numeric values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, 123)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("exact"),1.0)})
    end

    it "should create null values correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, nil)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(),("exact"),1.0)})
    end

    it "should accept case-sensitive options correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, 123, case_sensitive: true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("case-sensitive"),1.0)})

      q = MarkLogic::Queries::ValueQuery.new(:count, 123, case_sensitive: false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("case-insensitive"),1.0)})
    end

    it "should accept diacritic-sensitive options correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, 123, diacritic_sensitive: true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("diacritic-sensitive"),1.0)})

      q = MarkLogic::Queries::ValueQuery.new(:count, 123, diacritic_sensitive: false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("diacritic-insensitive"),1.0)})
    end

    it "should accept punctuation-sensitive options correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, 123, punctuation_sensitive: true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("punctuation-sensitive"),1.0)})

      q = MarkLogic::Queries::ValueQuery.new(:count, 123, punctuation_sensitive: false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("punctuation-insensitive"),1.0)})
    end

    it "should accept whitespace-sensitive options correctly" do
      q = MarkLogic::Queries::ValueQuery.new(:count, 123, whitespace_sensitive: true)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("whitespace-sensitive"),1.0)})

      q = MarkLogic::Queries::ValueQuery.new(:count, 123, whitespace_sensitive: false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("count",(123),("whitespace-insensitive"),1.0)})
    end

    it "should add multiple options when given" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123", exact: true, case_sensitive: false)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("id",("123"),("exact","case-insensitive"),1.0)})
    end

    it "should add weight when given" do
      q = MarkLogic::Queries::ValueQuery.new(:id, "123", :weight => 2.0)
      expect(q.to_xqy).to eq(%Q{cts:json-property-value-query("id",("123"),("exact"),2.0)})
    end
  end
end
