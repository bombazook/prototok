module Prototok
  module Utils
    module TypeAttributes
      def type type, *attributes
        unless type.is_a? Class
          Prototok.err(Errors::TypeMismatch, :type_expected, :type, Class, type)
        end
        attributes.each do |attrib|
          define_method "#{attrib}=" do |val|
            unless val.is_a? type
              Prototok.err(Errors::TypeMismatch, :type_expected, attrib, type, val)
            end
            super(val)
          end
        end
      end
    end
  end
end
