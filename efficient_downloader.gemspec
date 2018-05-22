
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "efficient_downloader/version"

Gem::Specification.new do |spec|
  spec.name          = "efficient_downloader"
  spec.version       = EfficientDownloader::VERSION
  spec.authors       = ["Carlos Martinez"]
  spec.email         = ["carlosjmtz@gmail.com"]

  spec.summary       = "An easy and efficient way to download things in Ruby"
  spec.description   = %q{A wrapper for Net::HTTP that provides a nicer syntax to download files chunk by chunk and write to a local path.}
  spec.homepage      = "https://github.com/carlosmartinez/efficient_downloader"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
