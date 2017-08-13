require 'spec_helper'

RSpec.describe Prototok::Serializers::Token do
  let(:token) { Prototok::Token.new(:created_at => Time.now) }
  subject{ described_class.new(token) }

  describe '#encode' do
    it 'doesnt raise an error' do
      expect{subject.encode}.not_to raise_error
    end
    Prototok::CLAIM_ALIASES.map(&:first).each do |k|
      options = Hash[Prototok::CLAIM_ALIASES.map{|k,v| [k, Time.now]}]
      options.delete(k)
      context "#{k} is nil" do
        let(:token){ Prototok::Token.new(options) }
        it "doesnt preserve #{k}" do
          expect(subject.encode).to_not include(k)
        end

        it "preserves all other items #{options.keys.inspect}" do
          expect(subject.encode).to include(*options.keys)
        end
      end
    end
  end

  describe '.decode' do
    it 'doesnt raise an error on decoding encoded token' do
      expect{described_class.decode(subject.encode)}.not_to raise_error
    end
  end
end
