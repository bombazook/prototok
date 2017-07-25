require 'google/protobuf'
require 'google/protobuf/well_known_types'

module Prototok
  module Encoders
    class Protobuf < Base
      Prototok::Utils::Protoc.process(File.join(__dir__, 'protobuf/token.proto'))
      PROTOBUF_DEFAULTS = {
        payload_class: '::Prototok::Payload'
      }.freeze

      def encode
        payload_klass = self.class.payload_class(options)
        payload = payload_klass.new(self.payload)
        any = Google::Protobuf::Any.new
        any.pack payload
        token_attributes = self.to_h.select{|k,v| !v.nil?}.merge(payload: any)
        token = Prototok::Token.new token_attributes
        Prototok::Token.encode(token)
      end

      def self.decode(blob, encoder_options: nil, **_)
        opts = options.merge(encoder_options) unless encoder_options.nil?
        payload_klass = payload_class(opts)
        obj = new
        decoded_token = Prototok::Token.decode(blob)
        obj.each_pair{|k,v| obj[k] = decoded_token[k.to_s]}
        obj.payload = obj.payload.unpack(payload_klass)
        obj
      end

      def self.options
        @options ||= super.merge!(PROTOBUF_DEFAULTS)
      end

      private

      def self.payload_class(options)
        existing = try_get_existed(options[:payload_class])
        return existing unless existing.nil?
        Prototok::Utils::Protoc.process(options[:payload_file])
        Object.const_get options[:payload_class], false
      end

      def self.try_get_existed(klass_name)
        Object.const_get klass_name, false
      rescue NameError
        nil
      end
    end
  end
end
