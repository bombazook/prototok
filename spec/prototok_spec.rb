require 'spec_helper'
require 'prototok/utils/test_helper'

RSpec.describe Prototok do
  extend Prototok::Utils::TestHelper

  option_combinations.each do |combination_name, options|
    context combination_name do
      let(:private_key) { described_class.key(**options) }
      let(:public_key) do
        begin
          described_class.key(private_key, **options)
        rescue
          nil
        end
      end
      let(:remote_private_key) { described_class.key(**options) }
      let(:remote_public_key) do
        begin
          described_class.key(remote_private_key, **options)
        rescue
          nil
        end
      end
      let(:keyword_args) { options }
      let(:payload) { { query: 'some query' } }

      case options[:op]
      when 'encrypted_sign'
        let(:encode_args) { [payload, private_key, remote_public_key] }
        let(:decode_args) { [token, remote_private_key, public_key] }
        let(:spoiled_decode_args) do
          [token, remote_private_key, remote_public_key]
        end
      when 'sign'
        let(:encode_args) { [payload, private_key] }
        let(:decode_args) { [token, public_key] }
        let(:spoiled_decode_args) { [token, remote_public_key] }
      else
        let(:encode_args) { [payload, private_key] }
        let(:decode_args) { [token, private_key] }
        let(:spoiled_decode_args) { [token, remote_private_key] }
      end

      let(:token) { described_class.encode(*encode_args, **options) }
      let(:decode_result) { described_class.decode(*decode_args, **options) }

      describe '.key' do
        it 'doesnt raise an exception' do
          expect { described_class.key(**options) }.to_not raise_error
        end
      end

      describe '.cipher' do
        it 'doesnt raise an exception' do
          expect { described_class.send :cipher, **options }.to_not raise_error
        end
      end

      describe '.formatter' do
        it 'doesnt raise an exception' do
          expect do
            described_class.send :formatter, options[:formatter]
          end.to_not raise_error
        end
      end

      describe '.encode' do
        let(:delimiter) { Prototok.config[:token_delimiter] }
        it 'gets correct encode args and do not raise error on encode' do
          expect { token }.not_to raise_error
        end

        it 'returns a digit-letter string with delimiter' do
          encoded_result = described_class.encode(*encode_args, **options)
          token_part_regexp = /^[\d\w]+$/
          splitted_result = encoded_result.split(delimiter)
          expect(splitted_result).to all(match(token_part_regexp))
        end

        it 'returns a string of 2 parts with delimiter' do
          encoded_result = described_class.encode(*encode_args, **options)
          splitted_result = encoded_result.split(delimiter)
          expect(splitted_result.size).to be_eql 2
        end

        context '0 arguments' do
          let(:encode_args) { [] }
          it 'raises an ArgumentError' do
            expect { token }.to raise_error(ArgumentError)
          end
        end

        context '1 argument' do
          let(:encode_args) { [] }
          it 'raises an ArgumentError' do
            expect { token }.to raise_error(ArgumentError)
          end
        end

        context 'payload is Prototok::Token' do
          let!(:payload) { Prototok::Token.new }
          let!(:payload_hash) { payload.to_h }
          it 'do not create new token' do
            token
            expect(Prototok::Token).to_not receive(:new)
          end

          it 'remains original token untouched' do
            token
            expect(payload.to_h).to be_eql(payload_hash)
          end
        end
      end

      describe '.decode' do
        it 'remote private key and public key decode without raising' do
          expect { decode_result }.not_to raise_error
        end

        if options.dig(:encoder_options, :encoding_mode).to_s != 'payload'
          it 'returns a Token instance' do
            expect(decode_result).to be_kind_of(Prototok::Token)
          end
        end

        it 'raises RbNaCl errors on using spoiled keys' do
          expect do
            described_class.decode(*spoiled_decode_args, **options)
          end.to(raise_error do |e|
            expect([
                     RbNaCl::BadSignatureError,
                     RbNaCl::BadAuthenticatorError,
                     RbNaCl::CryptoError
                   ]).to include e.class
          end)
        end

        it 'allows to access original value attributes from payload' do
          if options.dig(:encoder_options, :encoding_mode).to_s != 'payload'
            expect(decode_result.payload['query']).to be_eql(payload[:query])
          else
            expect(decode_result['query']).to be_eql(payload[:query])
          end
        end

        context 'with header attributes token generation' do
          let(:options_with_header) do
            options.merge(header: { created_at: Time.now })
          end
          let(:token) do
            described_class.encode(*encode_args, **options_with_header)
          end
          if options.dig(:encoder_options, :encoding_mode).to_s != 'payload'
            it 'allows to access header attributes' do
              original_created_at = options_with_header[:header][:created_at]
              expect(decode_result.created_at).to be_eql(original_created_at)
            end
          else
            it 'just ignores header' do
              expect(decode_result.to_h.keys)
                .to_not include(:created_at, 'created_at')
            end
          end
        end

        context 'string without delimiter given' do
          let(:token) do
            described_class.encode(*encode_args, **options).sub('.', '')
          end
          it 'raises Prototok::Errors::FormatError' do
            expect do
              decode_result
            end.to raise_error(Prototok::Errors::FormatError)
          end
        end

        context '0 arguments' do
          let(:decode_args) { [] }
          it 'raises an ArgumentError' do
            expect { decode_result }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end

  describe '.cipher' do
    it 'raises ArgumentError if no cipher with such name found' do
      expect do
        described_class.send :cipher, op: 'olol'
      end.to raise_error(ArgumentError)
    end
  end

  describe '.formatter' do
    it 'raises ArgumentError if no encoder with such name found' do
      expect do
        described_class.send :formatter, 'olol'
      end.to raise_error(ArgumentError)
    end
  end
end
