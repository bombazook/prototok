require 'time'

module Prototok
  module Serializers
    module Time
      def self.encode value
        value.iso8601(Prototok.config[:time_encoding_precision])
      end

      def self.decode value
        ::Time.iso8601(value)
      end
    end
  end
end
