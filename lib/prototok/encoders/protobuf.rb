require 'google/protobuf'
require 'google/protobuf/well_known_types'

module Prototok
  module Encoders
    class Protobuf < Base
      # token proto initial load
      base_token = File.join(__dir__, 'protobuf/token.proto')
      Prototok::Utils::Protoc.process(base_token)

      PROTOBUF_DEFAULTS = {
        payload_class: '::Prototok::Payload'
      }.freeze

      def encode
        payload_klass = self.class.payload_class(options)
        payload = payload_klass.new(self.payload || {})
        any = Google::Protobuf::Any.new
        any.pack payload
        token_attributes = to_h.reject { |_, v| v.nil? }.merge!(payload: any)
        token = Prototok::Token.new token_attributes
        token.class.encode(token)
      end

      def self.decode(blob, **opts)
        obj = new **opts
        payload_klass = payload_class(obj.options)
        decoded_token = Prototok::Token.decode(blob)
        obj.each_pair { |k, _| obj[k] = decoded_token[k.to_s] }
        obj.payload = obj.payload.unpack(payload_klass)
        obj
      end

      def self.options
        @options ||= super.merge!(PROTOBUF_DEFAULTS)
      end

      private

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
