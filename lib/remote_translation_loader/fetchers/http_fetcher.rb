# frozen_string_literal: true

require "http"

module RemoteTranslationLoader
  module Fetchers
    class HttpFetcher < BaseFetcher
      DEFAULT_RETRIES = 3
      DEFAULT_TIMEOUT = 10 # seconds
      RETRYABLE_ERRORS = [HTTP::Error, HTTP::TimeoutError, HTTP::ConnectionError].freeze

      def initialize(retries: DEFAULT_RETRIES, timeout: DEFAULT_TIMEOUT)
        @retries = retries
        @timeout = timeout
      end

      def fetch(url)
        response = with_retries(url) { HTTP.timeout(@timeout).get(url) }
        raise FetchError, "Failed to fetch data from #{url} (status #{response.status})" unless response.status.success?

        parse(response.body.to_s, format: format_for(url))
      end

      private

      def with_retries(url)
        attempt = 0
        begin
          attempt += 1
          yield
        rescue *RETRYABLE_ERRORS => e
          raise FetchError, "Failed to fetch data from #{url}: #{e.message}" if attempt > @retries

          sleep(2**(attempt - 1) * 0.1)
          retry
        end
      end
    end
  end
end
