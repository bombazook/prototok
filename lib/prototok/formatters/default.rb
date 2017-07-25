module Prototok
  module Formatters
    class Default < Base
      def encode(*args)
        raise Errors::FormatError if args.first.size != 2
        args.first.map { |part| RbNaCl::Util.bin2hex(part) }
            .join(Prototok.config[:token_delimiter])
      end

      def decode(blob)
        parts = blob.split(Prototok.config[:token_delimiter])
        raise Errors::FormatError if parts.size != 2
        parts.map { |part| RbNaCl::Util.hex2bin(part) }
      end
    end
  end
end
