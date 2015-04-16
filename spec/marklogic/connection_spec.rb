require 'spec_helper'

describe MarkLogic::Connection do

  class Response

    def initialize(b)
      @body = b
    end

    def body
      @body
    end

    def body=(val)
      @body = val
    end

    def read_body
      true
    end

    def [](x)
      "multipart/mixed; boundary=4ae338aa9d1fc38e"
    end
  end

  before do
    @b = MarkLogic::Connection.app_services_connection
  end

  describe "split_multipart" do
    it "should split properly when multiple values are returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: text/plain\r\nX-Primitive: integer\r\n\r\n5\r\n--4ae338aa9d1fc38e\r\nContent-Type: text/plain\r\nX-Primitive: integer\r\n\r\n6\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to eq([5, 6])
    end

    it "should split properly when a single value is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: text/plain\r\nX-Primitive: integer\r\n\r\n5\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to eq(5)
    end

    it "should split properly when an array value is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: application/json\r\nX-Primitive: array\r\n\r\n["5", 6]\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to eq(["5", 6])
    end

    it "should split properly when an object value is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: application/json\r\nX-Primitive: map\r\n\r\n{"hi":"stuff"}\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to eq({"hi" => "stuff"})
    end

    it "should split properly when a true boolean is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: text/plain\r\nX-Primitive: boolean\r\n\r\ntrue\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to be true
    end

    it "should split properly when a false boolean is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: text/plain\r\nX-Primitive: boolean\r\n\r\nfalse\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to be false
    end

    it "should split properly when a decimal is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: text/plain\r\nX-Primitive: decimal\r\n\r\n3.1\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to eq(3.1)
    end

    it "should split properly when a crazy object is returned" do
      response = Response.new(%Q{\r\n--4ae338aa9d1fc38e\r\nContent-Type: application/json\r\nX-Primitive: map\r\n\r\n{"stuff":[1, 2, 3], "junk":false}\r\n--4ae338aa9d1fc38e--\r\n})
      expect(@b.send(:split_multipart, response)).to eq({"stuff" => [1, 2, 3], "junk" => false})
    end

  end

  describe "run_query" do
    it "should split properly when multiple values are returned" do
      expect(@b.run_query('(5, 6)', 'xquery').body).to eq([5, 6])
    end

    it "should split properly when a single value is returned" do
      expect(@b.run_query('5').body).to eq(5)
    end

    it "should split properly when an array value is returned" do
      expect(@b.run_query(%Q{x = ["5", 6]; x}).body).to eq(["5", 6])
    end

    it "should split properly when an object value is returned" do
      expect(@b.run_query('x = {hi: "stuff"}; x').body).to eq({"hi" => "stuff"})
    end

    it "should split properly when a true boolean is returned" do
      expect(@b.run_query('true').body).to be true
    end

    it "should split properly when a false boolean is returned" do
      expect(@b.run_query('false').body).to be false
    end

    it "should split properly when a decimal is returned" do
      expect(@b.run_query('3.1').body).to eq(3.1)
    end

    it "should split properly when a crazy object is returned" do
      expect(@b.run_query(%Q{x = { stuff: [1, 2, 3], junk: false}; x}).body).to eq({"stuff" => [1, 2, 3], "junk" => false})
    end

    it "should handle url unencoded stuff" do
      expect(@b.run_query(%Q{
        let $x := "Hi &amp; stuff"
        return
          $x
      }, 'xquery').body).to eq("Hi & stuff")
    end
  end

  describe "#digest" do
    it "#digest should cache login creds" do
      expect(@b.run_query('(5, 6)', 'xquery').body).to eq([5, 6])
      expect(@b.run_query('(5, 6)', 'xquery').body).to eq([5, 6])
      expect(@b.run_query('(5, 6)', 'xquery').body).to eq([5, 6])
      expect(@b.run_query('(5, 6)', 'xquery').body).to eq([5, 6])
    end
  end

  describe "run_query" do
    it "should work" do
      expect(@b.run_query('(5, 6)', 'xquery').body).to eq([5, 6])
      expect(@b.run_query('<a/>,<a/>', 'xquery').body).to eq(['<a/>', '<a/>'])

      res = @b.run_query('<a/>, try { fn:error((), "stuff") } catch($ex) { $ex }', 'xquery').body
      expect(res[0]).to eq('<a/>')
      expect(res[1]).to match(/<error:error.*/)
    end
  end
end
