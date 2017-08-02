require 'spec_helper'

=begin
 class Json < Base
      def encode
        MultiJson.encode to_h
      end

      def self.decode(blob, **_)
        obj = new
        MultiJson.decode(blob).each { |k, v| obj[k] = v }
        obj
      end
    end
=end

RSpec.describe Prototok::Encoders::Json do
  describe '#encode' do
  end

  describe '.decode' do
  end
end
