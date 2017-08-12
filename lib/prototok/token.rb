require 'time'

module Prototok
  CLAIM_ALIASES = [
    [:exp, %i[expires_at use_before]],
    [:nbf, %i[not_before use_after]],
    [:iat, [:created_at]],
    [:jti, %i[token_id id]],
    [:payload, []]
  ].freeze

  KEY_OPTIONS = CLAIM_ALIASES.flatten
  TIME_KEYS = [:exp, :nbf, :iat]
  raise SyntaxError if KEY_OPTIONS.uniq.size != KEY_OPTIONS.size

  class Token < Struct.new(*CLAIM_ALIASES.map(&:first))
    extend Utils::TypeAttributes
    type ::Time, *TIME_KEYS

    extend Serializers
    serializer :time, *TIME_KEYS, nil: :delete, empty: :delete
    serializer nil, :jti, :payload, nil: :delete

    def initialize opts={}
      super()
      update!(opts)
    end

    CLAIM_ALIASES.each do |(original, aliases)|
      aliases.each do |alias_name|
        alias_method alias_name, original
        alias_method "#{alias_name}=", "#{original}="
      end
    end

    def update! opts={}
      opts.each{|k,v| self.send "#{k}=", v}
      self
    end

  end
end


