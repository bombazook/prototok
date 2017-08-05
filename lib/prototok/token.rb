module Prototok
  CLAIM_ALIASES = [
    [:exp, %i[expires_at use_before]],
    [:nbf, %i[not_before use_after]],
    [:iat, [:created_at]],
    [:jti, %i[token_id id]],
    [:payload, []]
  ].freeze

  KEY_OPTIONS = CLAIM_ALIASES.flatten
  raise SyntaxError if KEY_OPTIONS.uniq.size != KEY_OPTIONS.size

  class Token < Struct.new(*CLAIM_ALIASES.map(&:first))
    def initialize opts={}
      super()
      opts.each{|k,v| self.send "#{k}=", v}
    end

    CLAIM_ALIASES.each do |(original, aliases)|
      aliases.each do |alias_name|
        alias_method alias_name, original
        alias_method "#{alias_name}=", "#{original}="
      end
    end

  end
end


