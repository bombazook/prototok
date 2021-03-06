module Prototok
  module Encoders
    autoload :Json, 'prototok/encoders/json'
    autoload :Msgpack, 'prototok/encoders/msgpack'
    autoload :Protobuf, 'prototok/encoders/protobuf'
    extend Utils::Listed

    class Base
      def options
        @options ||= self.class.options.dup
      end

      def self.options
        @options ||= Prototok.config[:encoder_options].dup
      end

      def initialize(**encoder_options)
        options.merge!(encoder_options)
      end

      def encode payload, **header
        case options[:encoding_mode].to_s
        when 'token'
          encode_token payload, **header
        when 'payload'
          encode_payload payload
        end
      end

      def decode str
        case options[:encoding_mode].to_s
        when 'token'
          decode_token str
        when 'payload'
          decode_payload str
        end
      end

      def serialize payload=nil, **header
        if payload.is_a? Token
          token = payload.dup.update!(header)
        else
          token = Token.new.update!(header.merge(:payload => payload))
        end
         Serializers.find(:token).new(token).encode
      end

      def deserialize data
        Token.new(Serializers.find(:token).decode (data))
      end
    end
  end
end
