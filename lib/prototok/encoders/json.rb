require 'multi_json'

module Prototok
  module Encoders
    class Json < Base
      def encode_token payload, **header
        MultiJson.encode serialize(payload, **header)
      end

      def decode_token str
        deserialize(MultiJson.decode(str))
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
