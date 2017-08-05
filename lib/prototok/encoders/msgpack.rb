require 'msgpack'

module Prototok
  module Encoders
    class Msgpack < Base
      def encode_token payload, **header
        MessagePack.pack build_token(payload, **header).to_h
      end

      def decode_token str
        Token.new(MessagePack.unpack(str))
      end

      def encode_payload payload
         MessagePack.pack payload.to_h
      end

      def decode_payload str
        MessagePack.unpack(str)
      end
    end
  end
end
