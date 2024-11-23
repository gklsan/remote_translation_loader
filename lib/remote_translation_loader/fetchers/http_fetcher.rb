# frozen_string_literal: true

module RemoteTranslationLoader
  module Fetchers
    class FileFetcher < BaseFetcher
      def fetch(path)
        raise "File not found: #{path}" unless File.exist?(path)

        parse(File.read(path))
      end
    end
  end
end
