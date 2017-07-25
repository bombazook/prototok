module Prototok
  CONFIG_DEFAULTS = {
    formatter: 'default',
    version: 1,
    op: :encrypted_mac,
    encoder: 'json',
    token_delimiter: '.',
    encoder_options: {}
  }.freeze

  class << self
    def configuration
      @configutation ||= CONFIG_DEFAULTS.dup
    end

    def configure
      yield(configuration)
    end

    alias_method :config, :configuration
  end
end
