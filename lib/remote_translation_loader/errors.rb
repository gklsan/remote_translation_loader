# frozen_string_literal: true

module RemoteTranslationLoader
  class Error < StandardError; end

  # Raised when a fetcher can't retrieve content from its source
  # (network failure, missing file, S3 error, etc.).
  class FetchError < Error; end

  # Raised when fetched content can't be parsed as YAML/JSON.
  class ParseError < Error; end

  # Raised when parsed content isn't a valid translations hash.
  class ValidationError < Error; end
end
