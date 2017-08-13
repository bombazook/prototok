require 'time'

module Prototok
  CLAIM_ALIASES = [
    [:exp, %i[expires_at use_before]],
    [:nbf, %i[not_before use_after]],
    [:iat, [:created_at]],
    [:jti, %i[token_id id]],
    [:payload, []]
  ].freeze

  class Token < Struct.new(*CLAIM_ALIASES.map(&:first))
    extend Utils::TypeAttributes
    type ::Time, :exp, :nbf, :iat

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


