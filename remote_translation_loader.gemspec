# frozen_string_literal: true

require_relative "lib/remote_translation_loader/version"

Gem::Specification.new do |spec|
  spec.name        = 'remote_translation_loader'
  spec.version     = RemoteTranslationLoader::VERSION
  spec.summary     = 'Fetches and loads remote YAML translation files into Rails I18n'
  spec.description = 'The remote_translation_loader gem allows you to fetch YAML translation files from remote sources and dynamically load them into your Rails application’s I18n translations without writing them to local files.'
  spec.authors     = ["Gokul (gklsan)"]
  spec.email       = ["pgokulmca@gmail.com"]
  spec.homepage    = 'https://github.com/gklsan/remote_translation_loader'
  spec.license     = 'MIT'

  spec.files       = Dir['lib/**/*.rb'] + Dir['README.md'] + Dir['LICENSE']
  spec.require_paths = ['lib']
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'http', '~> 5.0'
  spec.add_dependency 'yaml', '0.3.0'
  spec.add_development_dependency 'rspec', '~> 3.13.0'
  spec.add_development_dependency 'i18n', '~> 1.14.5'
end
