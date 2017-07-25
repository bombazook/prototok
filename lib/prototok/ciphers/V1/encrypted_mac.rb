require 'rbnacl/secret_boxes/xsalsa20poly1305'

module Prototok
  module Ciphers
    module V1
      class EncryptedMac < Base
        self.cipher_class = RbNaCl::SecretBoxes::XSalsa20Poly1305

        def initialize(private_key)
          @cipher = cipher_class.new(private_key)
        end

        def encode(blob)
          nonce = RbNaCl::Random.random_bytes @cipher.nonce_bytes
          [nonce, @cipher.box(nonce, blob)]
        end

        def decode(decoded_nonce, decoded_blob)
          @cipher.open(decoded_nonce, decoded_blob)
        end
      end
    end
  end
end
