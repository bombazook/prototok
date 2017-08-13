require 'google/protobuf'
require 'google/protobuf/well_known_types'

module Prototok
  module Encoders
    class Protobuf < Base
      base_token = File.join(__dir__, 'protobuf/token.proto')
      Prototok::Utils::Protoc.process(base_token)

      PROTOBUF_DEFAULTS = {
        payload_class: '::Prototok::Protobuf::Payload'
      }.freeze

      def encode_token payload, **header
        serialized = serialize(payload, **header)
        prepared_token = prepare_token(serialized)
        prepared_token.class.encode(prepared_token)
      end

      def decode_token str
        decoded_token = Prototok::Protobuf::Token.decode(str)
        payload = decoded_token.payload.unpack(payload_class)
        token = deserialize(decoded_token.to_h)
        token.payload = payload
        token
      end

      def encode_payload payload
        payload = payload_class.new(payload.to_h.reject { |_, v| v.nil? })
        payload_class.encode(payload)
      end

      def decode_payload str
        payload_class.decode(str)
      end

      def self.options
        @options ||= super.merge!(PROTOBUF_DEFAULTS)
      end

      private

      def prepare_token serialized_token
        payload = payload_class.new(serialized_token[:payload] || {})
        any = Google::Protobuf::Any.new
        any.pack payload
        serialized_token[:payload] = any
        Prototok::Protobuf::Token.new(serialized_token)
      end

      def payload_class
        self.class.payload_class(options)
      end

      def self.payload_class(opts)
        @cache ||= {}
        @cache[opts] ||= begin
          existing = try_get_existed(opts[:payload_class])
          return existing unless existing.nil?
          unless opts[:payload_file]
            Prototok.send :err, Errors::ConfigurationError, 'no_payload_proto_file'
          end
          Prototok::Utils::Protoc.process(opts[:payload_file])
          Object.const_get opts[:payload_class], false
        end
      end

      def self.try_get_existed(klass_name)
        Object.const_get klass_name, false
      rescue NameError
        nil
      end
    end
  end
end
