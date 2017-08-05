require 'rbnacl/signatures/ed25519'

module Prototok
  module Ciphers
    module V1
      class Sign < Base
        self.cipher_class = RbNaCl::Signatures::Ed25519

        def initialize(private_or_public_key)
          @key = private_or_public_key
        end

        def encode(blob)
          cipher = cipher_class::SigningKey.new(@key)
          [cipher.sign(blob), blob]
        end

        def decode(decoded_auth, decoded_blob)
          cipher = cipher_class::VerifyKey.new(@key)
          cipher.verify(decoded_auth, decoded_blob)
          decoded_blob
        end

        def self.key(private_key = nil)
          if private_key.nil?
            cipher_class::SigningKey.generate.to_bytes
          else
            cipher_class::SigningKey.new(private_key).verify_key.to_bytes
          end
        end
      end
    end
  end
end
