# frozen_string_literal: true

module RemoteTranslationLoader
  # Zero-config Rails integration. Configure once:
  #
  #   RemoteTranslationLoader.configure do |config|
  #     config.sources = ["https://example.com/en.yml", "s3://bucket/fr.yml"]
  #     config.namespace = "remote"
  #   end
  #
  # and translations are fetched on boot, and refreshed on every reload in
  # development.
  class Railtie < ::Rails::Railtie
    initializer "remote_translation_loader.load_translations" do
      RemoteTranslationLoader.load_configured_translations
    end

    config.to_prepare do
      RemoteTranslationLoader.load_configured_translations if Rails.env.development?
    end
  end
end
