require 'msgpack'

module Prototok
  module Encoders
    class Msgpack < Base
      def encode
        MessagePack.pack self.to_h
      end

      def self.decode(blob, **_)
        obj = self.new
        MessagePack.unpack(blob).each { |k, v| obj[k] = v }
        obj
      end
    end
  end
end
