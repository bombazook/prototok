module Prototok
  module Serializers
    Autoloaded.class {}
    extend Utils::Listed

    class Base
      attr_reader :object

      def initialize(object)
        @object = object
      end

      KEY_OPERATIONS = %i[nil empty].freeze

      def encode
        if attribute_storage.empty?
          @object.respond_to?(:to_h) ? @object.to_h : @object
        else
          Hash[map_attributes]
        end
      end

      private

      def attribute_storage
        self.class.attribute_storage
      end

      def default_getter(name)
        @object.respond_to?(name) ? @object.send(name) : @object[name]
      end

      def map_attributes
        result = attribute_storage.keys.map {|name| [name, send(name)] }
        self.class.apply_key_ops!(Hash[result])
      end

      class << self
        def attribute(*names, **options)
          names.uniq!
          update_key_ops(*names, options)
          names.each do |name|
            attribute_storage[name] = Attribute.new(options)
            define_attribute_method name
          end
        end

        def decode(data)
          apply_key_ops!(data)
          result = attribute_storage.map do |name, attribute|
            serializer = attribute.serializer
            key = pick_key data, name
            next unless key
            value = data[key]
            if serializer
              [name, serializer.decode(value)]
            else
              [name, value]
            end
          end.compact
          Hash[result]
        end

        def attribute_storage
          @attribute_storage ||= {}
        end

        def key_ops
          @key_ops ||= {}
        end

        def apply_op(result, key, op)
          if op.is_a? Symbol
            result.send op, key
          else
            op.call(result, key)
          end
        end

        def apply_key_ops!(result)
          key_ops.each do |key, ops|
            ops.each do |check, op|
              val = result[key]
              apply_op(result, key, op) if check_value val, check
            end
          end
          result
        end

        def check_value(val, check)
          if check.is_a?(Symbol)
            check_method = "#{check}?"
            val.respond_to?(check_method) && val.send(check_method)
          else
            check.call(val)
          end
        end

        alias_method :attributes, :attribute

        private

        def pick_key(data, key)
          if data.key?(key)
            key
          elsif data.key?(stringified = key.to_s)
            stringified
          end
        end

        def define_attribute_method(name)
          if attribute_storage[name].options.empty?
            define_method(name) { default_getter(name) }
          else
            define_getter(name)
          end
        end

        def define_getter(name)
          attribute = attribute_storage[name]
          define_method name do
            attribute.serialize default_getter(name)
          end
        end

        def update_key_ops(*names, **options)
          current_key_ops = {}
          options.each do |k, v|
            external_option = false
            raise ArgumentError if v.is_a?(Proc) && v.arity != 2
            if k.is_a?(Proc)
              raise ArgumentError if k.arity != 1
              external_option = true
            else
              external_option = KEY_OPERATIONS.include?(k)
            end
            current_key_ops[k] = options.delete(k) if external_option
          end
          names.each do |name|
            key_ops[name] = current_key_ops unless current_key_ops.empty?
          end
        end
      end
    end
  end
end
