# frozen_string_literal: true

module RemoteTranslationLoader
  module Fetchers
    class BaseFetcher
      def fetch(_source)
        raise NotImplementedError, "Subclasses must implement the `fetch` method"
      end

      def parse(content)
        YAML.safe_load(content)
      rescue Psych::SyntaxError => e
        raise "Failed to parse content: #{e.message}"
      end
    end
  end
end
