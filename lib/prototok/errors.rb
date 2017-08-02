module Prototok
  module Errors
    class FormatError < RuntimeError; end
    class ConfigurationError < RuntimeError; end
    class CipherError < RuntimeError; end
    MESSAGES = {
      encoder: 'No such encoder declared',
      cipher: 'No such cipher declared',
      formatter: 'No such formatter declared',
      no_payload_proto_file: 'No payload .proto file path configured'
    }.freeze
  end
end
