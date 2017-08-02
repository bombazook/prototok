require 'digest/sha2'
require 'tempfile'

module Prototok
  module Utils
    module Protoc
      class << self
        def cache
          @cache ||= Set.new
        end

        def process(path)
          path = File.expand_path path
          if !path || !File.exist?(path)
            raise ArgumentError, 'protobuf proto file is missing'
          end
          input = File.read(path)
          digest = Digest::SHA256.hexdigest(input)
          if cache.include? digest # not threadsafe!
            false
          else
            temp = ::Tempfile.new digest
            temp.write input
            temp.rewind
            load_proto temp, digest
          end
        end

        private

        def load_proto(proto, digest)
          dirname = File.dirname(proto.path)
          output_rb = proto.path + '_pb.rb'
          begin
            `protoc #{proto.path} --ruby_out=#{dirname} --proto_path=#{dirname}`
            load output_rb
          ensure
            cache.add digest
            FileUtils.rm output_rb
          end
        end
      end
    end
  end
end
