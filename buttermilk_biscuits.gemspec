
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "buttermilk_biscuits/version"

Gem::Specification.new do |spec|
  spec.name          = "buttermilk_biscuits"
  spec.version       = ButtermilkBiscuits::VERSION
  spec.authors       = ["JackMarx"]
  spec.email         = ["seriousfools@gmail.com"]

  spec.summary       = "terminal interface for classroom cookbook app"
  spec.description   = "I have struggled long and hard to get access to my recipes from the terminal, this is the tool that granted my wishes."
  spec.homepage      = "https://github.com/StraightOuttaConstant/buttermilk_biscuits"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end


  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "unirest", "~> 1.1.2"
end










