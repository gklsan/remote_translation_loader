# frozen_string_literal: true

require 'aws-sdk-s3'

module RemoteTranslationLoader
  module Fetchers
    class S3Fetcher < BaseFetcher
      def initialize(s3_client = Aws::S3::Client.new)
        @s3_client = s3_client
      end

      def fetch(bucket, key)
        response = @s3_client.get_object(bucket: bucket, key: key)
        parse(response.body.read)
      end
    end
  end
end
