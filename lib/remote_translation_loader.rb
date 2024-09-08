# frozen_string_literal: true

require_relative "remote_translation_loader/version"

require 'http'
require 'yaml'
require 'i18n'

module RemoteTranslationLoader
  class Loader
    def initialize(urls)
      @urls = urls
    end

    def fetch_and_load
      @urls.each do |url|
        yml_content = fetch_yaml(url)
        merge_into_i18n(yml_content)
      end
    end

    private

    def fetch_yaml(url)
      response = HTTP.get(url)
      raise "Failed to fetch YAML from #{url}" unless response.status.success?

      begin
        YAML.safe_load(response.body.to_s)
      rescue Psych::SyntaxError => e
        raise "Failed to parse YAML from #{url}: #{e.message}"
      end
    end

    def merge_into_i18n(yml_content)
      yml_content.each do |locale, remote_translations|
        if remote_translations.is_a?(Hash)
          existing_translations = I18n.backend.send(:translations)[locale.to_sym] || {}
          merged_translations = deep_merge(existing_translations, remote_translations)

          I18n.backend.store_translations(locale.to_sym, merged_translations)
        else
          raise "Invalid data format for locale #{locale}"
        end
      end
    end

    def deep_merge(existing, incoming)
      existing.merge(incoming) do |key, oldval, newval|
        oldval.is_a?(Hash) && newval.is_a?(Hash) ? deep_merge(oldval, newval) : newval
      end
    end
  end
end
