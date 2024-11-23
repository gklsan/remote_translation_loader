require 'i18n'

module RemoteTranslationLoader
  class Loader
    def initialize(urls, fetcher: Fetchers::HttpFetcher.new)
      @urls = urls
      @fetcher = fetcher
    end

    def fetch_and_load(dry_run: false, namespace: nil)
      @urls.each do |url|
        content = @fetcher.fetch(url)
        validate_translations!(content)

        if dry_run
          puts "Simulating loading for #{url}: #{content.inspect}"
        else
          merge_into_i18n(content, namespace: namespace)
        end
      end
    end

    private

    def validate_translations!(translations)
      raise "Invalid translations format!" unless translations.is_a?(Hash)
    end

    def merge_into_i18n(content, namespace: nil)
      content.each do |locale, translations|
        next unless translations.is_a?(Hash)

        translations = { namespace => translations } if namespace
        existing = I18n.backend.send(:translations)[locale.to_sym] || {}
        merged = deep_merge(existing, translations)
        I18n.backend.store_translations(locale.to_sym, merged)
      end
      puts "Translations loaded successfully!"
    end

    def deep_merge(existing, incoming)
      existing.merge(incoming) do |_, old_val, new_val|
        old_val.is_a?(Hash) && new_val.is_a?(Hash) ? deep_merge(old_val, new_val) : new_val
      end
    end
  end
end
