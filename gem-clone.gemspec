Gem::Specification.new do |spec|
  spec.name          = "gem-clone"
  spec.version       = "0.4.1"
  spec.authors       = ["Hiroshi SHIBATA"]
  spec.email         = ["hsbt@ruby-lang.org"]

  spec.summary       = "A RubyGems plugin to clone gem repositories"
  spec.description   = "Clone gem repositories by fetching source code URLs from gem metadata"
  spec.homepage      = "https://github.com/hsbt/gem-clone"
  spec.license       = "MIT"

  spec.files         = Dir.glob("lib/**/*") + %w[README.md]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"
end
