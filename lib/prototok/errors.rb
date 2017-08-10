module Prototok
  module Errors
    class FormatError < RuntimeError; end
    class ConfigurationError < RuntimeError; end
    class CipherError < RuntimeError; end
    MESSAGES = {
      encoder: 'No such encoder declared',
      cipher: 'No such cipher declared',
      formatter: 'No such formatter declared',
      no_payload_proto_file: 'No payload .proto file path configured',
      time_expected: '%s expects Time value, got %s'
    }.freeze

    def err(error_class, message_name, *args, **keywords)
      message = (Errors::MESSAGES[message_name] || "")
      message %= args unless args.empty?
      message %= keywords unless keywords.empty?
      raise(error_class, message)
    end
  end
end
