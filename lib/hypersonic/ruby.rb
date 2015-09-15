require "faraday"
require "json"
require "yaml"
require "hypersonic/ruby/version"
require "hypersonic/ruby/metric"
require "hypersonic/ruby/config"

module Hypersonic
  module Ruby
    def self.config
      @config ||= Config.new
    end
  end
end
