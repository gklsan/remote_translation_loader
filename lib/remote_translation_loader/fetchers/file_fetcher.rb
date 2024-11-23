# frozen_string_literal: true

require 'http'

module RemoteTranslationLoader
  module Fetchers
    class HttpFetcher < BaseFetcher
      def fetch(url)
        response = HTTP.get(url)
        raise "Failed to fetch data from #{url}" unless response.status.success?

        parse(response.body.to_s)
      end
    end
  end
end
