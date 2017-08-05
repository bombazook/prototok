require 'spec_helper'

RSpec.describe Prototok::Encoders::Base do
  let(:args) { [] }
  let(:keyword_options) { {} }
  subject { described_class.new(*args, **keyword_options) }

  describe '#initialize' do
    context 'with options' do
      let(:keyword_options) { { some_option: true } }
      it 'sets options from keyword :encoder_options to options' do
        expect(subject.options).to include(some_option: true)
      end
    end
  end
end
