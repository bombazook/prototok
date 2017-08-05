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
        if options[:encoding_mode].to_s == 'token'
          encode_token payload, **header
        else
          encode_payload payload
        end
      end

      def decode str
        if options[:encoding_mode].to_s == 'token'
          decode_token str
        else
          decode_payload str
        end
      end

      def build_token payload, **header
        Token.new(header.merge(:payload => payload))
      end
    end
  end
end
