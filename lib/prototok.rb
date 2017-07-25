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
      formatter(opts[:formatter]).new.encode(processed)
    end

    def decode(encoded, *cipher_args, **opts)
      unformatted = formatter(opts[:formatter]).new.decode(encoded)
      unprocessed = cipher(**opts).new(*cipher_args).decode(*unformatted)
      encoder(opts[:encoder]).decode(unprocessed, **opts)
    end

    def key *args, **opts
      cipher(**opts).key(*args)
    end

    private

    def encoder(encoder_name = config[:encoder])
      encoder_name ||= config[:encoder]
      error_msg = 'No such encoder declared'.freeze
      Prototok::Encoders.find(encoder_name) || raise(ArgumentError, error_msg)
    end

    def cipher(**opts)
      op = opts[:op] || config[:op]
      version = opts[:version] || config[:version]
      ver_name = "V#{version}"
      error_msg = 'No such cipher declared'.freeze
      Prototok::Ciphers.find(ver_name, op) || raise(ArgumentError, error_msg)
    end

    def formatter(formatter_name = config[:formatter])
      formatter_name ||= config[:formatter]
      error_msg = 'No such formatter declared'.freeze
      Prototok::Formatters.find(formatter_name) ||
        raise(ArgumentError, error_msg)
    end
  end
end
