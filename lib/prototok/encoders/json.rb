require 'multi_json'

module Prototok
  module Encoders
    class Json < Base
      def encode
        MultiJson.encode to_h
      end

      def self.decode(blob, **_)
        obj = new
        MultiJson.decode(blob).each { |k, v| obj[k] = v }
        obj
      end
    end
  end
end
