# frozen_string_literal: true

require_relative "remote_translation_loader/version"
require_relative "remote_translation_loader/errors"
require_relative "remote_translation_loader/configuration"
require_relative "remote_translation_loader/fetchers/base_fetcher"
require_relative "remote_translation_loader/fetchers/http_fetcher"
require_relative "remote_translation_loader/fetchers/file_fetcher"
require_relative "remote_translation_loader/fetchers/s3_fetcher"
require_relative "remote_translation_loader/source_resolver"
require_relative "remote_translation_loader/loader"

module RemoteTranslationLoader
  class << self
    # One-liner convenience: RemoteTranslationLoader.load(["en.yml", "https://.../fr.yml"])
    def load(sources, **options)
      Loader.new(sources).fetch_and_load(**options)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
      configuration
    end

    # Used by the Railtie to fetch+load whatever was set via `.configure`.
    def load_configured_translations
      config = configuration
      return if config.sources.empty?

      Loader.new(config.sources, logger: config.logger)
            .fetch_and_load(dry_run: config.dry_run, namespace: config.namespace)
    end
  end
end

require_relative "remote_translation_loader/railtie" if defined?(Rails::Railtie)
