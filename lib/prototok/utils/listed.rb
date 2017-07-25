module Prototok
  module Utils
    module Listed
      def find *attrs
        @cache ||= {}
        @cache[attrs] ||= begin
          const_name = attrs.map do |word|
            word.to_s.split(/(?=[[:upper:]])|\_/).map(&:capitalize).join
          end.join("::")
          const_get const_name
        end
      end
    end
  end
end
