# frozen_string_literal: true

require_relative "lib/cronitor/active_job/version"

Gem::Specification.new do |spec|
  spec.name = "cronitor_activejob"
  spec.version = Cronitor::ActiveJob::VERSION
  spec.authors = ["Kevin Tom"]
  spec.email = ["kevintom@gmail.com"]

  spec.summary = "ActiveJob integration with Cronitor."
  spec.description = "Instrument ActiveJob jobs with Cronitor to monitor lifecycle events around the perform method."
  spec.homepage = "https://github.com/cronitor/cronitor-activejob"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.files = Dir["README.md", "LICENSE.txt", "lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "cronitor", "~> 4.0"

  spec.add_development_dependency "activejob"
  spec.add_development_dependency "activesupport"
end
