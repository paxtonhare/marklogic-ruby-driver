require 'spec_helper'

describe MarkLogic::Collection do
  before do
    @collection = @database.collection("stuff")
    @collection.drop
  end

  def save_ten
    @collection.save((1..10).map do |n|
      {:_id => n, :name => "John#{n}", :age => n, :stuff => "junk"}
    end)
  end

  describe "count" do
    it "returns the correct document count" do
      expect(@collection.count).to eq 0
      @collection.save( {:_id => "123", :name => "John", :age => 33, :stuff => "junk"} )
      expect(@collection.count).to eq 1
      @collection.save( {:_id => "456", :name => "Bill", :age => 33, :stuff => "junk"} )
      expect(@collection.count).to eq 2
      @collection.save( {:_id => "456", :name => "Bill", :age => 33, :stuff => "junk"} )
      expect(@collection.count).to eq 2
    end
  end

  describe "load" do
    it "loads a document" do
      expect(@collection.count).to eq 0
      @collection.save( {:_id => "123", :name => "John", :age => 33, :stuff => "junk"} )
      expect(@collection.count).to eq 1
      doc = @collection.load("123")
      expect(doc).to be_a_kind_of(Hash)
      expect(doc["_id"]).to eq "123"
      expect(doc['name']).to eq "John"
    end
  end

  describe "save" do
    it "saves a document" do
      expect(@collection.count).to eq 0
      @collection.save( {:_id => "123", :name => "John", :age => 33, :stuff => "junk"} )
      expect(@collection.count).to eq 1
    end

    it "save with a Time object" do
      expect(@collection.count).to eq 0
      current_time = Time.now
      @collection.save( {:_id => "123", :name => "John", :age => 33, created_at: current_time} )

      tdoc = @collection.load('123')
      expect(tdoc).to eq({"_id" => "123", "name" => "John", "age" => 33, "created_at" => current_time.as_json })
      expect(@collection.count).to eq 1
    end
  end

  describe "#save multiples" do
    it "saves a bunch of documents in one transaction" do
      expect(@collection.count).to eq 0
      @collection.save((1..10).map do |n|
        {:_id => n.to_s, :name => "John#{n}", :age => 30 + n, :stuff => "junk#{n}"}
      end)
      expect(@collection.count).to eq 10
    end
  end

  describe "remove" do
    it "removes all document when no params given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      @collection.remove
      expect(@collection.count).to eq 0
    end

    it "removes all document when an empty hash is given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      @collection.remove()
      expect(@collection.count).to eq 0
    end

    it "removes documents matching the criteria given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      @collection.remove({:_id => 1})
      expect(@collection.count).to eq 9

      @collection.remove(@collection.from_criteria({:_id => 2}))
      expect(@collection.count).to eq 8
    end

    it "removes documents matching the criteria given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      @collection.remove({:_id => [1, 2, 3]})
      expect(@collection.count).to eq 7

      @collection.remove(@collection.from_criteria({:_id => [4, 5, 6]}))
      expect(@collection.count).to eq 4
    end

    it "removes documents matching the criteria given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      @collection.remove({ 'age' => { '$lt' => 7} })
      expect(@collection.count).to eq 4

      @collection.remove(@collection.from_criteria({ 'age' => { '$lt' => 8} }))
      expect(@collection.count).to eq 3
    end
  end

  describe "drop" do
    it "removes all documents" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      @collection.drop
      expect(@collection.count).to eq 0
    end
  end

  describe "find" do
    it "finds documents matching the criteria given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      expect(@collection.find({:_id => 1}).count).to eq 1
      expect(@collection.find(@collection.from_criteria({:_id => 1})).count).to eq 1
    end

    it "finds documents matching the criteria given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      expect(@collection.find({:_id => [1, 2, 3]}).count).to eq 3
      expect(@collection.find(@collection.from_criteria({:_id => [1, 2, 3]})).count).to eq 3
    end

    it "finds documents matching the criteria given" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      expect(@collection.find({ 'age' => { '$lt' => 7 } }).count).to eq 6
      expect(@collection.find(@collection.from_criteria({ 'age' => { '$lt' => 7 } })).count).to eq 6
    end
  end

  describe "#find_one" do
    it "finds one document" do
      expect(@collection.count).to eq 0
      save_ten
      expect(@collection.count).to eq 10
      c = @collection.find_one({:_id => 1})
      c = @collection.find_one(@collection.from_criteria({:_id => 1}))
      expect(c['_id']).to eq(1)
    end
  end
end
