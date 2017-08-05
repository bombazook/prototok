require 'spec_helper'
require 'prototok/utils/test_helper'

RSpec.describe Prototok do
  extend Prototok::Utils::TestHelper

  option_combinations.each do |combination_name, options|
    context combination_name do
      let(:private_key){ described_class.key(**options) }
      let(:public_key){ described_class.key(private_key, **options) rescue nil }
      let(:remote_private_key){ described_class.key(**options) }
      let(:remote_public_key){ described_class.key(remote_private_key, **options) rescue nil }
      let(:keyword_args){ options }
      let(:payload){ {:query => "some query"} }

      case options[:op]
      when 'encrypted_sign'
        let(:encode_args){ [payload, private_key, remote_public_key] }
        let(:decode_args){ [token, remote_private_key, public_key] }
        let(:spoiled_decode_args){ [token, remote_private_key, remote_public_key] }
      when 'sign'
        let(:encode_args){ [payload, private_key] }
        let(:decode_args){ [token, public_key] }
        let(:spoiled_decode_args){ [token, remote_public_key] }
      else
        let(:encode_args){ [payload, private_key] }
        let(:decode_args){ [token, private_key] }
        let(:spoiled_decode_args){ [token, remote_private_key] }
      end

      let(:token){ described_class.encode(*encode_args, **options) }

      describe '.encode' do
        it 'gets correct encode args and do not raise error on encode' do
          expect{token}.not_to raise_error
        end

        context 'first argument is encoder instance' do
          let!(:encoder_class) { described_class.send(:encoder, options[:encoder]) }
          let!(:payload) { encoder_class.new }

          it 'doesnt create a new encoder instance' do
            expect(encoder_class).to_not receive(:new)
            described_class.encode(*encode_args, **options)
          end

          it 'doesnt call .encoder' do
            expect(described_class).to_not receive(:encoder)
            described_class.encode(*encode_args, **options)
          end
        end

        it "returns a digit-letter string with delimiter" do
          encoded_result = described_class.encode(*encode_args, **options)
          base_64_regexp = /^[\d\w]+$/
          splitted_result = encoded_result.split(Prototok.config[:token_delimiter])
          expect(splitted_result).to all(match(base_64_regexp))
        end

        it "returns a string of 2 parts with delimiter" do
          encoded_result = described_class.encode(*encode_args, **options)
          base_64_regexp = /^[\d\w]+$/
          splitted_result = encoded_result.split(Prototok.config[:token_delimiter])
          expect(splitted_result.size).to be_eql 2
        end
      end

      describe '.decode' do
        it 'gets remote private key and public key and decode without raising errors' do
          expect{described_class.decode *decode_args, **options}.not_to raise_error
        end

        it 'returns an encoder instance' do
          expect(described_class.decode *decode_args, **options).to be_kind_of(Prototok::Encoders::Base)
        end

        it 'raises RbNaCl errors on using spoiled keys' do
          expect do
            described_class.decode *spoiled_decode_args, **options
          end.to raise_error{|e| expect([RbNaCl::BadSignatureError, RbNaCl::BadAuthenticatorError, RbNaCl::CryptoError]).to include e.class}
        end

        it 'allows to access original value attributes from payload (using string based notation)' do
          result = described_class.decode *decode_args, **options
          expect(result.payload['query']).to be_eql(payload[:query])
        end

        context 'with header attributes token generation' do
          let(:options_with_header){ options.merge(header: {created_at: Time.now.to_i} )  }
          let(:token){ described_class.encode(*encode_args, **options_with_header) }
          it 'allows to access header attributes' do
            result = described_class.decode *decode_args, **options
            expect(result.created_at).to be_eql(options_with_header[:header][:created_at])
          end
        end

        context 'string without delimiter given' do
          let(:token){ described_class.encode(*encode_args, **options).sub('.', "") }
          it 'raises Prototok::Errors::FormatError' do
            expect{described_class.decode *decode_args, **options}.to raise_error(Prototok::Errors::FormatError)
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
