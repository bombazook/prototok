module Prototok
  module Encoders
    Autoloaded.class {}
    extend Utils::Listed

    class Base
      TIME_ENCODED_OPTIONS = [:exp, :nbf, :iat]

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

      def build_token payload, **header
        Token.new(header.merge(:payload => payload))
      end
    end
  end
end
