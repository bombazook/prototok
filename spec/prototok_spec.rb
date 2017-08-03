require 'spec_helper'
require 'prototok/utils/test_helper'

RSpec.describe Prototok do
  extend Prototok::Utils::TestHelper

  option_combinations.each do |combination_name, options|
    context combination_name do
      let(:private_key){ described_class.key(**options) }
      let(:public_key){ described_class.key(private_key, **options) rescue nil }
      let(:other_private_key){ described_class.key(**options) }
      let(:other_public_key){ described_class.key(other_private_key, **options) rescue nil }
      let(:keyword_args){ options }
      let(:payload){ {:query => "some query"} }
      if options[:op].to_s == 'encrypted_sign'
        describe '.encode' do
          it 'gets private and remote public key without raising errors' do
            expect{described_class.encode payload, private_key, other_public_key, **options}.not_to raise_error
          end
        end

      else
        describe '.encode' do
          it 'gets private key without raising error' do
            expect{described_class.encode payload, private_key, **options}.not_to raise_error
          end
        end
      end
    end
  end

  describe '.encode' do
    let(:private_key) { described_class.key **keyword_args }
    let(:first_arg) { {} }
    let(:additional_args) { [] }
    let(:keyword_args) { {} }
    let!(:args) { [first_arg, *additional_args, **keyword_args] }

    context '0 arguments' do
      let!(:args) { [] }
      it 'raises an ArgumentError' do
        expect { described_class.encode(*args) }.to raise_error(ArgumentError)
      end
    end

    context '1 argument' do
      it 'raises an exception' do
        expect{ described_class.encode(*args) }.to raise_error(ArgumentError)
      end
    end

    context '1+ argument' do
      let(:additional_args) { [private_key] }
      let(:keyword_args) { { encoder: :json, formatter: :default } }
      let(:encoder_class) { described_class.send(:encoder, keyword_args[:encoder]) }
      let(:cipher_class) { described_class.send(:cipher, **keyword_args) }
      let(:formatter_class) { described_class.send(:formatter, keyword_args[:formatter]) }

      it 'passes :encoder from keyword args to .encoder' do
        expect(described_class).to receive(:encoder).with(keyword_args[:encoder]).and_call_original
        described_class.encode(*args)
      end

      it 'creates an encoder instance passing first arg and keyword args to it' do
        expect(encoder_class).to receive(:new).with(first_arg, keyword_args).and_call_original
        described_class.encode(*args)
      end

      it 'calls #encode on created encoder instance' do
        expect_any_instance_of(encoder_class).to receive(:encode).and_call_original
        described_class.encode(*args)
      end

      it 'passes all keyword args to .cipher method' do
        expect(described_class).to receive(:cipher).with(keyword_args).and_call_original
        described_class.encode(*args)
      end

      it 'creates a cipher instance passing all 2+ positional args to it' do
        expect(cipher_class).to receive(:new).with(*additional_args).and_call_original
        described_class.encode(*args)
      end

      it 'calls #encode with string arg on cipher instance' do
        expect_any_instance_of(cipher_class).to receive(:encode).with(kind_of(String)).and_call_original
        described_class.encode(*args)
      end

      it 'passes :formatter from keyword args to .formatter method' do
        expect(described_class).to receive(:formatter).with(:default).and_call_original
        described_class.encode(*args)
      end

      it 'creates a formatter instance' do
        expect(cipher_class).to receive(:new).and_call_original
        described_class.encode(*args)
      end

      it 'calls #encode on instance returned from .formatter' do
        expect_any_instance_of(formatter_class).to receive(:encode).with(kind_of(String), kind_of(String)).and_call_original
        described_class.encode(*args)
      end

      context 'first argument is encoder instance' do
        let!(:first_arg) { encoder_class.new }
        it 'doesnt create a new encoder instance' do
          expect(encoder_class).to_not receive(:new)
          described_class.encode(*args)
        end

        it 'doesnt call .encoder' do
          expect(described_class).to_not receive(:encoder)
          described_class.encode(*args)
        end
      end
    end
  end

  describe '.decode' do
    let(:private_key) { described_class.key **keyword_args }
    let(:first_arg) { described_class.encode({}, private_key) }
    let(:additional_args) { [] }
    let(:keyword_args) { { encoder: :json } }
    let!(:args) { [first_arg, *additional_args, **keyword_args] }

    context '0 arguments' do
      let!(:args) { [] }
      it 'raises an ArgumentError' do
        expect { described_class.decode(*args) }.to raise_error(ArgumentError)
      end
    end

    context '1+ argument' do
      let(:additional_args) { [private_key] }
      let(:keyword_args) { { encoder: :json, formatter: :default } }
      let(:encoder_class) { described_class.send(:encoder, keyword_args[:encoder]) }
      let(:cipher_class) { described_class.send(:cipher, **keyword_args) }
      let(:formatter_class) { described_class.send(:formatter, keyword_args[:formatter]) }

      it 'passes :formatter from keyword args to .formatter method' do
        expect(described_class).to receive(:formatter).with(:default).and_call_original
        described_class.decode(*args)
      end

      it 'creates a formatter instance' do
        expect(cipher_class).to receive(:new).and_call_original
        described_class.encode(*args)
      end

      it 'calls #decode with token string on instance returned from .formatter' do
        expect_any_instance_of(formatter_class).to receive(:decode).with(first_arg).and_call_original
        described_class.decode(*args)
      end

      it 'passes all keyword args to .cipher method' do
        expect(described_class).to receive(:cipher).with(keyword_args).and_call_original
        described_class.decode(*args)
      end

      it 'creates a cipher instance passing all 2+ positional args to it' do
        expect(cipher_class).to receive(:new).with(*additional_args).and_call_original
        described_class.decode(*args)
      end

      it 'calls #decode with string arg on cipher instance' do
        expect_any_instance_of(cipher_class).to receive(:decode).and_call_original
        described_class.decode(*args)
      end

      it 'passes :encoder from keyword args to .encoder' do
        expect(described_class).to receive(:encoder).with(keyword_args[:encoder]).and_call_original
        described_class.encode(*args)
      end

      it 'calls .decode on received encoder class' do
        expect(encoder_class).to receive(:decode).and_call_original
        described_class.decode(*args)
      end
    end
  end

  describe '.key' do
    let(:positional_args) { [cipher_class.key] }
    let(:keyword_args) { { op: :sign, version: 1 } }
    let(:args) { [*positional_args, **keyword_args] }
    let!(:cipher_class) { described_class.send :cipher, **keyword_args }
    context 'no args' do
      it 'doesnt raise an exception' do
        expect { described_class.key }.to_not raise_error
      end
    end

    it 'calls cipher with keyword arguments' do
      expect(described_class).to receive(:cipher).with(keyword_args).and_call_original
      described_class.key(*args)
    end

    it 'calls .key on received cipher class' do
      expect(cipher_class).to receive(:key).with(*positional_args).and_call_original
      described_class.key(*args)
    end
  end

  describe '.cipher' do
    it 'raises ArgumentError if no cipher with such name found' do
      expect { described_class.send :cipher, op: 'olol' }.to raise_error(ArgumentError)
    end
  end

  describe '.encoder' do
    let(:encoder) { :msgpack }

    it 'raises ArgumentError if no encoder with such name found' do
      expect { described_class.send :encoder, 'olol' }.to raise_error(ArgumentError)
    end
  end

  describe '.formatter' do
    it 'raises ArgumentError if no encoder with such name found' do
      expect { described_class.send :formatter, 'olol' }.to raise_error(ArgumentError)
    end
  end
end
