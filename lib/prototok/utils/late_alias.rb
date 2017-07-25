module Prototok
  module Utils
    module LateAlias
      def late_alias mname, original
        unless method_defined? mname
          define_method mname do |*args|
            self.class.class_eval do
              undef_method mname
              alias_method mname, original
            end
            self.send mname, *args
          end
        end
      end

      def late_accessor_alias mname, original
        late_alias mname, original
        late_alias "#{mname}=", "#{original}="
      end
    end
  end
end
