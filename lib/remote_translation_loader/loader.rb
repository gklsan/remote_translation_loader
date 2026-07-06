require "i18n"
require "logger"

module RemoteTranslationLoader
  class Loader
    # `fetcher:` can be left unset to auto-detect the right fetcher per source
    # (http(s):// -> HttpFetcher, s3://bucket/key -> S3Fetcher, else -> FileFetcher).
    # Pass an explicit fetcher to force every source through it instead.
    def initialize(urls, fetcher: nil, logger: Logger.new($stdout))
      @urls = urls
      @fetcher = fetcher
      @resolver = SourceResolver.new if @fetcher.nil?
      @logger = logger
    end

    def fetch_and_load(dry_run: false, namespace: nil)
      @urls.each do |url|
        content = fetch_content(url)
        validate_translations!(content, url)

        if dry_run
          @logger.info("Simulating loading for #{url}: #{content.inspect}")
        else
          merge_into_i18n(content, namespace: namespace)
        end
      end
    end

    private

    def fetch_content(url)
      if @fetcher
        @fetcher.fetch(url)
      else
        fetcher, key = @resolver.resolve(url)
        fetcher.fetch(key)
      end
    end

    def validate_translations!(translations, source)
      return if translations.is_a?(Hash)

      raise ValidationError, "Invalid translations format for #{source}: expected a Hash, got #{translations.class}"
    end

    def merge_into_i18n(content, namespace: nil)
      content.each do |locale, translations|
        next unless translations.is_a?(Hash)

        translations = { namespace => translations } if namespace
        existing = I18n.backend.send(:translations)[locale.to_sym] || {}
        merged = deep_merge(existing, translations)
        I18n.backend.store_translations(locale.to_sym, merged)
      end
      @logger.info("Translations loaded successfully!")
    end

    def deep_merge(existing, incoming)
      existing.merge(incoming) do |_, old_val, new_val|
        old_val.is_a?(Hash) && new_val.is_a?(Hash) ? deep_merge(old_val, new_val) : new_val
      end
    end
  end
end
