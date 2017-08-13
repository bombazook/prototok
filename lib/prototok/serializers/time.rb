require 'time'

module Prototok
  module Serializers
    class Time < Base
      def encode
        @object && @object.iso8601(Prototok.config[:time_encoding_precision])
      end

      def self.decode value
        ::Time.iso8601(value)
      end
    end
  end
end
