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
    def initialize opts={}
      super()
      update!(opts)
    end

    TIME_KEYS.each do |key|
      define_method "#{key}=" do |val|
        err(ArgumentError, :time_expected, key, val) unless val.is_a? Time
        super(val)
      end
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

    def prepare
      values = to_h
      values.reject! { |_, v| v.nil? }
      TIME_KEYS.each do |key|
        if values.key?(key)
          values[key] = values[key].iso8601(Prototok.config[:time_encoding_precision])
        end
      end
      values
    end

    def self.build values={}
      values = Hash[values.map{|k,v| [k.to_s, v]}]
      values.reject! { |_, v| v.nil? }
      TIME_KEYS.map(&:to_s).each do |key|
        if values.key? key
          if values[key].empty?
            values.delete(key)
          else
            values[key] = Time.iso8601(values[key])
          end
        end
      end
      new(values)
    end

  end
end


