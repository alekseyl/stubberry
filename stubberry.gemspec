require_relative 'lib/stubberry/version'

Gem::Specification.new do |spec|
  spec.name          = "stubberry"
  spec.version       = Stubberry::VERSION
  spec.authors       = ["alekseyl"]
  spec.email         = ["leshchuk@gmail.com"]

  spec.summary       = %q{Ultimate collection of sweet stub methods for ruby test suits. Lets stub! }
  spec.description   = %q{This a ultimate set of stub extensions. Suggest any reasonable subbing and I'll try to merge it. It will start with: stub_must, stub_must_not, stub_if_def and many more }
  spec.homepage      = "https://github.com/alekseyl/stubberry"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alekseyl/stubberry"
  spec.metadata["changelog_uri"] = "https://github.com/alekseyl/stubberry"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.5'
  spec.add_development_dependency "activerecord", ">= 6.1"

  spec.add_development_dependency "bundler", ">= 1"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'sqlite3'


  spec.add_development_dependency "ruby_jard"
end
