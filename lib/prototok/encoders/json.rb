require 'multi_json'

module Prototok
  module Encoders
    class Json < Base
      def encode_token payload, **header
        MultiJson.encode build_token(payload, **header).to_h
      end

      def decode_token str
        Token.new(MultiJson.decode(str))
      end

      def encode_payload payload
         MultiJson.encode payload.to_h
      end

      def decode_payload str
        MultiJson.decode(str)
      end
    end
  end
end
