# frozen_string_literal: true

module RemoteTranslationLoader
  module Fetchers
    class S3Fetcher < BaseFetcher
      def initialize(bucket, s3_client: nil)
        @bucket = bucket
        @s3_client_override = s3_client
      end

      def fetch(key)
        response = s3_client.get_object(bucket: @bucket, key: key)
        parse(response.body.read, format: format_for(key))
      rescue Aws::S3::Errors::ServiceError => e
        raise FetchError, "Failed to fetch #{key} from S3 bucket #{@bucket}: #{e.message}"
      end

      private

      # Building the real Aws::S3::Client (and requiring aws-sdk-s3) is deferred
      # until the first actual fetch, so simply constructing an S3Fetcher never
      # requires the aws-sdk-s3 gem or AWS credentials/region to be configured.
      def s3_client
        @s3_client ||= @s3_client_override || begin
          begin
            require "aws-sdk-s3"
          rescue LoadError
            raise LoadError, "S3Fetcher requires the aws-sdk-s3 gem. Add `gem 'aws-sdk-s3'` to your Gemfile."
          end

          Aws::S3::Client.new
        end
      end
    end
  end
end
