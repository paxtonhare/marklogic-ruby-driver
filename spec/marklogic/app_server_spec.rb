require 'spec_helper'

describe MarkLogic::AppServer do

  describe "instance" do
    let(:s) do
      MarkLogic::AppServer.new(
        "marklogic-gem-test",
        8039,
        "http",
        "Default")
    end

    it "should create accessors" do
      expect(s.server_name).to eq("marklogic-gem-test")
      expect(s.server_type).to eq("http")
      expect(s["content-database"]).to eq("marklogic-gem-test-content")
    end

  end

  describe "load" do
    it "should load an existing config from the server" do
      app = MarkLogic::AppServer.load('App-Services')
      expect(app['server-name']).to eq('App-Services')
      expect(app['content-database']).to eq('Documents')
      expect(app['modules-database']).to eq('Modules')
      expect(app['port']).to eq(8000)
    end
  end
end
