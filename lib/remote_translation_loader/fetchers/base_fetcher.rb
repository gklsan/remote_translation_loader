# frozen_string_literal: true

require "yaml"
require "json"

module RemoteTranslationLoader
  module Fetchers
    class BaseFetcher
      def fetch(_source)
        raise NotImplementedError, "Subclasses must implement the `fetch` method"
      end

      def parse(content, format: :yaml)
        case format
        when :json
          JSON.parse(content)
        else
          YAML.safe_load(content, aliases: true)
        end
      rescue Psych::SyntaxError, Psych::DisallowedClass, JSON::ParserError => e
        raise ParseError, "Failed to parse content: #{e.message}"
      end

      # Infers :json vs :yaml from a source's file extension. Defaults to :yaml
      # (covers .yml/.yaml and extension-less sources like plain URLs).
      def format_for(source)
        File.extname(source.to_s).delete_prefix(".").downcase == "json" ? :json : :yaml
      end
    end
  end
end
