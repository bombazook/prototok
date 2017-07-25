require 'rbnacl/boxes/curve25519xsalsa20poly1305'

module Prototok
  module Ciphers
    module V1
      class EncryptedSign < Base
        self.cipher_class = RbNaCl::Boxes::Curve25519XSalsa20Poly1305

        def initialize(private_key, remote_public_key)
          @private_key = private_key
          @remote_public_key = remote_public_key
          @cipher = cipher_class.new(@remote_public_key, @private_key)
        end

        def encode(blob)
          nonce = RbNaCl::Random.random_bytes(cipher_class.nonce_bytes)
          [nonce, @cipher.encrypt(nonce, blob)]
        end

        def decode(decoded_nonce, decoded_blob)
          @cipher.decrypt(decoded_nonce, decoded_blob)
        end

        def self.key private_key=nil
          if private_key.nil?
            cipher_class::PrivateKey.generate.to_bytes
          else
            cipher_class::PrivateKey.new(private_key).public_key.to_bytes
          end
        end
      end
    end
  end
end
