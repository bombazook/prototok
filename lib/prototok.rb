require 'autoloaded'
require 'rbnacl'
require 'prototok/version'
require 'prototok/errors'
require 'prototok/utils'
require 'prototok/config'
require 'prototok/encoders'
require 'prototok/ciphers'
require 'prototok/formatters'

module Prototok
  class << self
    def encode(payload, *cipher_args, **opts)
      unless payload.is_a?(Prototok::Encoders::Base)
        payload = encoder(opts[:encoder]).new(payload, **opts)
      end
      encoded = payload.encode
      processed = cipher(**opts).new(*cipher_args).encode(encoded)
      formatter(opts[:formatter]).new.encode(*processed)
    end

    def decode(encoded, *cipher_args, **opts)
      unformatted = formatter(opts[:formatter]).new.decode(encoded)
      unprocessed = cipher(**opts).new(*cipher_args).decode(*unformatted)
      encoder(opts[:encoder]).decode(unprocessed, **opts)
    end

    def key(*args, **opts)
      cipher(**opts).key(*args)
    end

    private

    def err(error_class, message_name)
      raise(error_class, Errors::MESSAGES[message_name])
    end

    def encoder(encoder_name = nil)
      encoder_name ||= config[:encoder]
      Prototok::Encoders.find(encoder_name) || err(ArgumentError, :encoder)
    end

    def cipher(**opts)
      op = opts[:op] || config[:op]
      version = opts[:version] || config[:version]
      ver_name = "V#{version}"
      Prototok::Ciphers.find(ver_name, op) || err(ArgumentError, :cipher)
    end

    def formatter(frmter_name = nil)
      frmter_name ||= config[:formatter]
      Prototok::Formatters.find(frmter_name) || err(ArgumentError, :formatter)
    end
  end
end
