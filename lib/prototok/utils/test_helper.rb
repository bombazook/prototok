module Prototok
  module Utils
    module TestHelper
      def option_combinations
        combinations = (versions + [nil]).map do |v|
          product_versions(v)
        end.flatten.each_slice(5).entries
        combinations.inject({}) do |aggr, options|
          aggr.merge!(itemize_options(prepare_options(options)))
        end
      end

      private

      def prepare_options(o = {})
        options = { version: o[0], op: o[1], encoder: o[2], formatter: o[3], encoder_options: o[4] }
        if options[:encoder].to_s == 'protobuf'
          options[:encoder_options] ||= {}
          payload_proto_path = File.join(
            Prototok::Utils::Paths.gem_root,
            'spec/encoders/protobuf/test_payload.prot'
          )
          options[:encoder_options][:payload_file] = payload_proto_path
        end
        options
      end

      def product_versions(v)
        [v]
          .product(cipher_names(v))
          .product(encoder_names)
          .product(formatter_names)
          .product(encoder_options)
      end

      def itemize_options(keyword_args = {})
        defaulted = keyword_args.each_with_object({}) do |(key, val), obj|
          obj[key] = (val.nil? ? 'default' : val)
        end
        name = defaulted.to_a.map { |i| i.join(' is ') }.join(', ')
        { name => keyword_args.reject { |_k, v| v.nil? } }
      end

      def encoder_names
        item_names('lib/prototok/encoders') + [nil]
      end

      def cipher_names(version = nil)
        version ||= 1
        item_names("lib/prototok/ciphers/V#{version}") + [nil]
      end

      def formatter_names
        item_names('lib/prototok/formatters') + [nil]
      end

      def encoder_options
        [:token, :payload].map do |mode|
          {encoding_mode: mode}
        end + [nil]
      end

      def item_names(subpath)
        items_root = File.join(Paths.gem_root, subpath)
        item_files = Dir.entries(items_root).select { |i| i =~ /.+\.rb/ } || []
        item_files.map { |i| File.basename(i, '.rb') }
      end

      def versions
        item_names('lib/prototok/ciphers').map { |i| i.sub(/^v/, '') }
      end
    end
  end
end
