module Prototok
  module Serializers
    class Attribute
      attr_reader :options
      attr_reader :serializer

      def initialize(options)
        @options = options || {}
        @serializer = Serializers.find(@options[:serializer])
      end

      def serialize(value)
        if @serializer
          @serializer.new(value).encode
        else
          value
        end
      end
    end
  end
end
