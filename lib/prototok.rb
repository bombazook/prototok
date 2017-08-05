require 'autoloaded'
require 'rbnacl'
require 'prototok/version'
require 'prototok/errors'
require 'prototok/utils'
require 'prototok/config'
require 'prototok/token'
require 'prototok/encoders'
require 'prototok/ciphers'
require 'prototok/formatters'

module Prototok
  class << self
    def encode(payload, *cipher_args, **opts)
      header = opts[:header] || {}
      encoded = encoder_instance(**opts).encode(payload, **header)
      processed = cipher(**opts).new(*cipher_args).encode(encoded)
      formatter(opts[:formatter]).new.encode(*processed)
    end

    def decode(encoded, *cipher_args, **opts)
      unformatted = formatter(opts[:formatter]).new.decode(encoded)
      unprocessed = cipher(**opts).new(*cipher_args).decode(*unformatted)
      encoder_instance(**opts).decode(unprocessed)
    end

    def key(*args, **opts)
      cipher(**opts).key(*args)
    end

    private

    def err(error_class, message_name)
      raise(error_class, Errors::MESSAGES[message_name])
    end

    def encoder_instance(encoder: nil, encoder_options: nil, **_)
      encoder ||= config[:encoder]
      klass = Prototok::Encoders.find(encoder) || err(ArgumentError, :encoder)
      encoder_options ||= {}
      klass.new(**encoder_options)
    end

    def cipher(op: nil, version: nil, **_)
      op ||= config[:op]
      version ||= config[:version]
      ver_name = "V#{version}"
      Prototok::Ciphers.find(ver_name, op) || err(ArgumentError, :cipher)
    end

    def formatter(frmter_name = nil)
      frmter_name ||= config[:formatter]
      Prototok::Formatters.find(frmter_name) || err(ArgumentError, :formatter)
    end
  end
end
