module Prototok
  module Serializers
    Autoloaded.module {}
    extend Utils::Listed

    module Base
      def self.encode value
        value
      end

      def self.decode value
        value
      end
    end

    def serializers
      @serializers ||= {}
    end

    def serializer serializer_name, *attributes, **options
      s = Serializers.find(serializer_name) || Base
      serializers[s] ||= {set: Set.new, options: options}
      attributes.each do |a|
        serializers[s][:set].add a.to_sym
      end
    end

    def decode data={}
      self.new(Prototok::Serializers.process(self, data.to_h, :decode))
    end

    def self.extended base
      base.include InstanceMethods
    end

    KEY_OPERATIONS = [:nil, :empty]

    def self.process klass, data, mname
      klass.serializers.each do |sklass, serializer|
        serializer[:set].each do |attribute_name|
          key = pick_key(data, attribute_name)
          if key
            op_applied = false
            KEY_OPERATIONS.each do |op|
              if op_action = serializer.dig(:options, :nil)
                checking_op = "#{op}?"
                if data[key].respond_to?(checking_op) && data[key].send(checking_op)
                  data.send op_action, key
                  op_applied = true
                  break
                end
              end
            end
            next if op_applied
            data[key] = sklass.send(mname, data[key])
          end
        end
      end
      data
    end

    private

    def self.pick_key data, key
      if data.key?(key)
        key
      elsif data.key?(stringified = key.to_s)
        stringified
      else
        nil
      end
    end

    module InstanceMethods
      def encode
        Prototok::Serializers.process(self.class, self.to_h, :encode)
      end
    end
  end
end
