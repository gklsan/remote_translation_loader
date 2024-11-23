# frozen_string_literal: true

require_relative "remote_translation_loader/version"
require_relative "remote_translation_loader/loader"
require_relative "remote_translation_loader/fetchers/base_fetcher"
require_relative "remote_translation_loader/fetchers/http_fetcher"
require_relative "remote_translation_loader/fetchers/file_fetcher"
require_relative "remote_translation_loader/fetchers/s3_fetcher"

module RemoteTranslationLoader
end
