module Prototok
  module Encoders
    CLAIM_ALIASES = {
      exp: %i[expires_at use_before],
      nbf: %i[not_before use_after],
      iat: [:created_at],
      jti: %i[token_id id],
      payload: []
    }.freeze

    KEY_OPTIONS = CLAIM_ALIASES.zip.flatten
    raise SyntaxError if KEY_OPTIONS.uniq.size != KEY_OPTIONS.size

    Autoloaded.class {}
    extend Utils::Listed

    class Base < ::Struct.new(*CLAIM_ALIASES.keys)
      extend Utils::LateAlias

      def options
        @options ||= self.class.options.dup
      end

      def self.options
        @options ||= Prototok.config[:encoder_options].dup
      end

      def initialize(payload = nil, header: nil, encoder_options: nil, **_)
        options.merge!(encoder_options) unless encoder_options.nil?
        self[:payload] = payload
        header.each { |k, v| send "#{k}=", v } unless header.nil?
      end

      CLAIM_ALIASES.flat_map do |original, aliases|
        aliases.each do |alias_name|
          late_accessor_alias alias_name, original
        end
      end
    end
  end
end
