module Prototok
  module Ciphers
    module V1
      autoload :Mac, 'prototok/ciphers/V1/mac'
      autoload :EncryptedMac, 'prototok/ciphers/V1/encrypted_mac'
      autoload :Sign, 'prototok/ciphers/V1/sign'
      autoload :EncryptedSign, 'prototok/ciphers/V1/encrypted_sign'
    end
  end
end
