# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prototok/version'

Gem::Specification.new do |spec|
  spec.name          = 'prototok'
  spec.version       = Prototok::VERSION
  spec.authors       = ['Kostrov Alexander']
  spec.email         = ['bombazook@gmail.com']

  spec.summary       = 'Tokens for sane auth'
  spec.description   = 'Easy to use token generation using libsodium and
                        json (using multi_json), message_pack or protobuf'
  spec.homepage      = 'https://github.com/bombazook/prototok'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'rbnacl'
  spec.add_dependency 'multi_json'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'grpc-tools'
  spec.add_development_dependency 'google-protobuf'
  spec.add_development_dependency 'grpc'
end
