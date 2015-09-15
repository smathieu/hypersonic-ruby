module Hypersonic
  module Ruby
    class Config
      class Error < RuntimeError
      end

      CONFIGS = {
        project_secret: nil,
        base_url: "http://hypersonic.dev",
      }

      attr_writer *CONFIGS.keys

      def self.load_from_file(path)
        unless File.exists?(path)
          raise ArgumentError, "No such file #{path}"
        end

        options = YAML.load_file(path)

        unless options
          raise Error, "Missing top level object"
        end

        options = options.fetch('hypersonic') do
          raise Error, "Missing top level object"
        end

        self.new do |config|
          options.each do |key, value|
            method = "#{key}="
            if config.respond_to?(method)
              config.public_send(method, value)
            else
              raise Error, "#{key} is not a valid configuration key"
            end
          end
        end
      end

      def initialize
        yield self if block_given?
      end

      CONFIGS.each do |key, default_value|
        define_method(key) do
          instance_variable_get("@#{key}") || ENV[key_to_env(key)] || default_value
        end
      end

      private

      def key_to_env(key)
        "HYPERSONIC_#{key.upcase}"
      end
    end
  end
end

