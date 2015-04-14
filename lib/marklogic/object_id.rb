# encoding: UTF-8

require 'securerandom'

module MarkLogic
  class ObjectId

    def initialize
      @id = SecureRandom.hex
    end

    def to_s
      @id
    end

    class << self
      def from_string(str)
        object_id = allocate
        object_id.instance_variable_set(:@id, str)
        object_id
      end

      def legal?(string)
        string.to_s =~ /^[0-9a-f]{32}$/i ? true : false
      end
    end

    def ==(other)
      to_s == other.to_s
    end

    def as_json(options=nil)
      to_s
    end

    def to_json(options = nil)
      as_json.to_json
    end

    def hash
      to_s.hash
    end

    alias to_str to_s
  end
end
