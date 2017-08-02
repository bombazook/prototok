require 'msgpack'

module Prototok
  module Encoders
    class Msgpack < Base
      def encode
        MessagePack.pack to_h
      end

      def self.decode(blob, **_)
        obj = new
        MessagePack.unpack(blob).each { |k, v| obj[k] = v }
        obj
      end
    end
  end
end
