
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kibana/version"

Gem::Specification.new do |spec|
  spec.name          = "kibana"
  spec.version       = Kibana::VERSION
  spec.authors       = ["victor-aguilars"]
  spec.email         = ["victor.aguilarsnz@gmail.com"]

  spec.summary       = 'Ruby API for Kibana.'
  spec.description   = 'Ruby API for Kibana.'
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  # spec.license       = "MIT"

  # # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  #   spec.metadata["homepage_uri"] = spec.homepage
  #   spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #   spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "2.4.22"
  spec.add_development_dependency "rake", "~> 13.1"
  spec.add_development_dependency "debug", ">= 1.0.0"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "minitest-reporters", "~> 1.6"
  spec.add_dependency "activesupport", '~> 6'
  spec.add_dependency 'faraday', '~> 2'
  spec.add_dependency 'faraday-multipart'
  spec.add_dependency 'oj', '~> 3'
end
