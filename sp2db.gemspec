
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sp2db/version"

Gem::Specification.new do |spec|
  spec.name          = "sp2db"
  spec.version       = Sp2db::VERSION
  spec.authors       = ["KhiemNS"]
  spec.email         = ["khiemns.k54@gmail.com.com"]

  spec.summary       = "Google Spreadsheet importer for Rails app."
  spec.description   = "Google Spreadsheet importer for Rails app."
  spec.homepage      = "https://github.com/khiemns54/sp2db"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 5.0"
  spec.add_dependency "google_drive", "~> 2.1"
  spec.add_dependency "google-api-client", "~> 0.11"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

end
