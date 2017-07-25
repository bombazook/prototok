require 'digest/sha2'
module Prototok
  module Utils
    module Protoc
      class << self
        def cache
          @cache ||= []
        end

        def process path
          path = File.expand_path path
          if !path || !File.exist?(path)
            raise ArgumentError, "protobuf proto file is missing"
          end
          input = File.read(path)
          digest = Digest::SHA256.hexdigest(input)
          unless cache.include? digest
            temp = Tempfile.new digest
            temp.write input
            temp.rewind
            dirname = File.dirname(temp)
            output_rb = temp.path + '_pb.rb'
            begin
              exec_cmd = "protoc #{temp.path} --ruby_out=#{dirname} --proto_path=#{dirname}"
              `#{exec_cmd}`
              puts "#{exec_cmd}"
              load output_rb
            ensure
              cache << digest
              FileUtils.rm output_rb
            end
          else
            false
          end
        end
      end
    end
  end
end
