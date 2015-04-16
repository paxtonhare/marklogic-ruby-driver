require 'spec_helper'

describe MarkLogic::Application do

  before do
    @a = MarkLogic::Application.new("marklogic-gem-application-test2", :port => PORT + 1)
    @content_db = MarkLogic::Database.new("marklogic-gem-application-test2-content")
    @content_forest = MarkLogic::Forest.new("marklogic-gem-application-test2-content")
    @modules_db = MarkLogic::Database.new("marklogic-gem-application-test2-modules")
    @modules_forest = MarkLogic::Database.new("marklogic-gem-application-test2-modules")
    @app_server = MarkLogic::AppServer.new("marklogic-gem-application-test2", PORT + 1, "http", "Default")
  end

  after do
    @a.drop
  end


  describe "new" do
    it "should create an instance" do
      expect(@a.app_name).to eq("marklogic-gem-application-test2")
      expect(@a.databases.length).to eq(0)
    end
  end

  describe "exists?" do
    it "should return if it exists or not" do
      @a.drop if @a.exists?
      expect(@a).to_not be_exists
      @a.create
      expect(@a).to be_exists
      @a.drop
      expect(@a).to_not be_exists
    end
  end

  describe "create" do
    it "should bootstrap" do
      @a.drop if @a.exists?

      expect(@content_forest).to_not be_exists
      expect(@content_db).to_not be_exists
      expect(@modules_db).to_not be_exists
      expect(@modules_forest).to_not be_exists
      expect(@app_server).to_not be_exists

      @a.create
      expect(@content_forest).to be_exists
      expect(@content_db).to be_exists
      expect(@modules_forest).to be_exists
      expect(@modules_db).to be_exists
      expect(@app_server).to be_exists

      @a.drop
    end
  end

  describe "drop" do
    it "should drop" do
      @a.drop if @a.exists?
      @a.create
      expect(@content_db).to be_exists
      expect(@modules_db).to be_exists
      expect(@app_server).to be_exists

      @a.drop
      expect(@content_db).to_not be_exists
      expect(@modules_db).to_not be_exists
      expect(@app_server).to_not be_exists
    end
  end

  describe "stale?" do
    it "should be stale when appropriate" do
      @a.drop if @a.exists?

      expect(@a).to be_stale

      @a.create
      expect(@a).to_not be_stale

      @a.content_databases[0].add_range_element_index("stuff")
      expect(@a).to be_stale

      @a.drop
      expect(@a).to be_stale
    end

    it "should be stale when indexes are added via the app" do
      @a.drop if @a.exists?
      expect(@a).to be_stale
      @a.create
      expect(@a).to_not be_stale

      @a.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:_id, :type => 'string'))
      @a.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:name, :type => 'string'))
      @a.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:age, :type => 'int'))

      expect(@a).to be_stale

      @a.drop
      expect(@a).to be_stale
    end
  end

  describe "load" do
    it "should load from existing config" do
      app = MarkLogic::Application.load('App-Services', connection: CONNECTION)
      expect(app.port).to eq(8000)
      expect(app.app_servers.count).to eq(1)
      expect(app.app_servers['App-Services'].server_name).to eq('App-Services')
      expect(app.content_databases.count).to eq(1)
      expect(app.content_databases.first.database_name).to eq('Documents')
      expect(app.content_databases.first['forest']).to eq(['Documents'])
      expect(app.modules_databases.count).to eq(1)
      expect(app.modules_databases.first.database_name).to eq('Modules')
    end
  end
end
