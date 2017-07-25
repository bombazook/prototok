module Prototok
  module Utils
    module Paths
      class << self
        def gem_root
          Gem::Specification.find_by_name('prototok').gem_dir
        end
      end
    end
  end
end
