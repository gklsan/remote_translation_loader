# frozen_string_literal: true

module RemoteTranslationLoader
  # Given a plain source string, resolves which Fetcher should handle it and
  # what key/path/url to pass to that fetcher's `#fetch`. This lets a single
  # Loader mix HTTP, local file, and S3 sources in one call without the
  # caller having to construct fetchers manually.
  #
  #   s3://my-bucket/path/to/en.yml -> S3Fetcher
  #   http(s)://...                 -> HttpFetcher
  #   anything else                 -> FileFetcher
  class SourceResolver
    S3_URI = %r{\As3://(?<bucket>[^/]+)/(?<key>.+)\z}.freeze
    HTTP_URI = %r{\Ahttps?://}i.freeze

    def initialize
      @s3_fetchers = {}
      @http_fetcher = Fetchers::HttpFetcher.new
      @file_fetcher = Fetchers::FileFetcher.new
    end

    # Returns [fetcher, key] where `fetcher.fetch(key)` retrieves the content.
    def resolve(source)
      str = source.to_s

      if (match = S3_URI.match(str))
        [s3_fetcher_for(match[:bucket]), match[:key]]
      elsif HTTP_URI.match?(str)
        [@http_fetcher, str]
      else
        [@file_fetcher, str]
      end
    end

    private

    def s3_fetcher_for(bucket)
      @s3_fetchers[bucket] ||= Fetchers::S3Fetcher.new(bucket)
    end
  end
end
