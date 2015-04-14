require 'spec_helper'

describe MarkLogic::Cursor do
  before do
    @collection = @database.collection("stuff")
    @collection.drop

    @collection.save((1..101).map do |n|
      {:_id => n, :name => "John#{n}", :age => n, :weight => n % 5, :stuff => "junk"}
    end)
  end

  describe "#sort" do
    it "should sort ascending" do
      c = MarkLogic::Cursor.new(@collection, {
        :sort => [['age', 1]]
      })
      expect(c.count).to eq 101
      expect(c.first['age']).to eq(1)
    end

    it "should sort descending" do
      c = MarkLogic::Cursor.new(@collection, {
        :sort => [['age', -1]]
      })
      expect(c.count).to eq 101
      expect(c.first['age']).to eq(101)
    end

    it "should do multiple sorts asc, desc" do
      options = {
        :sort => [['weight', 1], ['age', -1]]
      }
      c = MarkLogic::Cursor.new(@collection, options)
      expect(c.count).to eq 101
      first = c.first
      expect(first['age']).to eq(100)
      expect(first['weight']).to eq(0)
    end

    it "should do multiple sorts asc, asc" do
      options = {
        :sort => [['weight', 1], ['age', 1]]
      }
      c = MarkLogic::Cursor.new(@collection, options)
      expect(c.count).to eq 101
      first = c.first
      expect(first['age']).to eq(5)
      expect(first['weight']).to eq(0)
    end

    it "should do multiple sorts desc, asc" do
      options = {
        :sort => [['weight', -1], ['age', 1]]
      }
      c = MarkLogic::Cursor.new(@collection, options)
      expect(c.count).to eq 101
      first = c.first
      expect(first['age']).to eq(4)
      expect(first['weight']).to eq(4)
    end

    it "should do multiple sorts desc, asc" do
      options = {
        :sort => [['weight', -1], ['age', -1]]
      }
      c = MarkLogic::Cursor.new(@collection, options)
      expect(c.count).to eq 101
      first = c.first
      expect(first['age']).to eq(99)
      expect(first['weight']).to eq(4)
    end
  end

  describe "#operators" do
    it "should support EQ" do
      criteria = { 'age' => { '$eq' =>  3  } }
      options = {
        :query => @collection.from_criteria(criteria)
      }
      c = MarkLogic::Cursor.new(@collection, options)
      expect(c.count).to eq 1
      expect(c.first['age']).to eq 3

      criteria = { 'age' => 3 }
      options = {
        :query => @collection.from_criteria(criteria)
      }
      c = MarkLogic::Cursor.new(@collection, options)
      expect(c.count).to eq 1
      expect(c.first['age']).to eq 3

      criteria = { 'age' => (1..100).to_a }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 100
    end

    it "should support LT" do
      criteria = { 'age' => { '$lt' =>  3  } }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 2
      expect([1, 2].include?(c.first['age'])).to be true
      expect([1, 2].include?(c.next['age'])).to be true
    end

    it "should support GT" do
      criteria = { 'age' => { '$gt' =>  99  } }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 2
      expect([100, 101].include?(c.first['age'])).to be true
      expect([100, 101].include?(c.next['age'])).to be true
    end

    it "should support LE" do
      criteria = { 'age' => { '$le' =>  2  } }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 2
      expect([1, 2].include?(c.first['age'])).to be true
      expect([1, 2].include?(c.next['age'])).to be true
    end

    it "should support GE" do
      criteria = { 'age' => { '$ge' =>  100  } }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 2
      expect([100, 101].include?(c.first['age'])).to be true
      expect([100, 101].include?(c.next['age'])).to be true
    end

    it "should support NE" do
      criteria = { 'age' => { '$ne' =>  100  } }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 100
    end
  end

  describe "count" do
    it "should work when indexes are provided" do
      criteria = { 'age' => { '$gt' =>  3  } }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })
      expect(c.count).to eq 98
    end

    it "should fail when no indexes are provided and should be" do
      criteria = { 'stuff' => { '$gt' => 3  } }
      expect {@collection.from_criteria(criteria) }.to raise_error(MarkLogic::MissingIndexError)
    end

    it "should return the correct count" do
      c = MarkLogic::Cursor.new(@collection)
      expect(c.count).to eq 101
    end
  end

  describe "each" do
    it "should work when indexes are provided" do
      criteria = { 'age' => { '$gt' => 3  }  }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria)
      })

      count = 0
      c.each do |doc|
        count = count + 1
        expect(doc.kind_of?(Hash)).to eq true
      end
      expect(count).to eq 98
    end

    it "should transform results when a transformer is provided" do
      @user_class = Struct.new(:id, :name, :age, :stuff)

      criteria = { 'age' => { '$gt' => 3  }  }
      c = MarkLogic::Cursor.new(@collection, {
        :query => @collection.from_criteria(criteria),
        :transformer => lambda { |doc| @user_class.new(doc['_id'], doc['name'], doc['age'], doc['stuff']) }
      })

      count = 0
      c.each do |doc|
        count = count + 1
        expect(doc.kind_of?(@user_class)).to be true
        expect(doc.stuff).to eq("junk")
      end
      expect(count).to eq 98
    end

    # it "should fail when no indexes are provided and should be" do
    #   criteria = { 'age' => { '$gt' => 3  }  }
    #   c = MarkLogic::Cursor.new(@collection, {
    #     :query => @collection.from_criteria(criteria)
    #   })
    #   expect { c.each { |doc| doc } }.to raise_error(MarkLogic::MissingIndexError)
    # end

    it "should return the correct count" do
      c = MarkLogic::Cursor.new(@collection)
      count = 0
      c.each do |doc|
        count = count + 1
      end
      expect(count).to eq 101
    end
  end
end
