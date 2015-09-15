require "faraday"
require "json"
require "yaml"
require "hypersonic/ruby/version"
require "hypersonic/ruby/metric"
require "hypersonic/ruby/config"

module Hypersonic
  module Ruby
    CONFIG_FILE = 'hypersonic.yml'
    def self.config
      @config ||= init_config
    end

    private
    def self.init_config
      if File.exists?(CONFIG_FILE)
        Config.load_from_file(CONFIG_FILE)
      else
        Config.new
      end
    end
  end
end
