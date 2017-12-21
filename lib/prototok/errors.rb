module Prototok
  module Errors
    class FormatError < RuntimeError; end
    class ConfigurationError < RuntimeError; end
    class CipherError < RuntimeError; end
    class TypeMismatch < RuntimeError; end
    class ExternalError < RuntimeError; end
    MESSAGES = {
      encoder: 'No such encoder declared',
      cipher: 'No such cipher declared',
      formatter: 'No such formatter declared',
      no_payload_proto_file: 'No payload .proto file path configured',
      type_expected: '%s expects %s value, got %s',
      external_command: 'have issues with system util "%s".
      Try to run "%s" by hand. Maybe you have to install it'
    }.freeze

    def err(error_class, message_name, *args, **keywords)
      message = (Errors::MESSAGES[message_name] || "")
      message %= args unless args.empty?
      message %= keywords unless keywords.empty?
      raise(error_class, message)
    end
  end
end
