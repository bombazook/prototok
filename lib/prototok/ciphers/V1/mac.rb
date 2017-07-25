require 'rbnacl/hmac/sha512256'

module Prototok
  module Ciphers
    module V1
      class Mac < Base
        self.cipher_class = RbNaCl::HMAC::SHA512256

        def initialize(private_key)
          @cipher = cipher_class.new(private_key)
        end

        def encode(blob)
          [@cipher.auth(blob), blob]
        end

        def decode(decoded_auth, decoded_blob)
          @cipher.verify(decoded_auth, decoded_blob)
          decoded_blob
        end
      end
    end
  end
end
