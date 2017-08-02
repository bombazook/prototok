require 'spec_helper'

RSpec.describe Prototok::Encoders::Base do
  let(:args) { [] }
  let(:keyword_options) { {} }
  subject { described_class.new(*args, **keyword_options) }

  describe '#initialize' do
    context 'with :encoder_options' do
      let(:keyword_options) { { encoder_options: { some_option: true } } }
      it 'sets options from keyword :encoder_options to options' do
        expect(subject.options).to include(some_option: true)
      end
    end

    context 'with :header' do
      let(:keyword_options) { { header: { jti: '123', not_before: 123 } } }
      it 'sets each element to attributes' do
        expect(subject).to have_attributes(keyword_options[:header])
      end

      context 'incorrect :header options' do
        let(:keyword_options) { { header: { chacha: 'kavardak' } } }
        it 'raises error if unsupported option given' do
          expect { subject }.to raise_error(NoMethodError)
        end
      end
    end

    context 'with payload' do
      let(:args) { ['payload'] }
      it 'sets first argument to payload attribute' do
        expect(subject.payload).to be_eql(args.first)
      end
    end
  end
end
