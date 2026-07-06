# frozen_string_literal: true

require "logger"

module RemoteTranslationLoader
  class Configuration
    attr_accessor :sources, :namespace, :dry_run, :logger

    def initialize
      @sources = []
      @namespace = nil
      @dry_run = false
      @logger = Logger.new($stdout)
    end
  end
end
