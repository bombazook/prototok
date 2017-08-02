module Prototok
  module Utils
    module Listed
      def find(*attrs)
        @cache ||= {}
        @cache[attrs] ||= begin
          const_name = attrs.map do |word|
            word.to_s.split(/(?=[[:upper:]])|\_/).map(&:capitalize).join
          end.join('::')
          begin
            const_get const_name, false
          rescue NameError
            nil
          end
        end
      end
    end
  end
end
