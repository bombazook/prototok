module Prototok
  module Ciphers
    autoload :V1, 'prototok/ciphers/v1'
    extend Utils::Listed

    class Base
      class << self
        attr_writer :cipher_class
        def cipher_class
          @cipher_class ||
            raise(Errors::CipherError, 'No cipher_class declared')
        end

        def key
          RbNaCl::Random.random_bytes(cipher_class.key_bytes)
        end
      end

      def cipher_class
        self.class.cipher_class
      end
    end
  end
end
