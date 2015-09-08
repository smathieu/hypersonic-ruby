module Hypersonic
  module Ruby
    class Metric
      attr_reader :name

      def initialize(name, &block)
        @name = name
        @submetrics = []
        yield self
      end

      def metric(name, &block)
        @submetrics << self.class.new(name, &block)
      end

      [:duration, :source].each do |method|
        define_method(method) do |value = nil|
          if value.nil?
            instance_variable_get("@#{method}")
          else
            instance_variable_set("@#{method}", value)
          end
        end
      end

      def as_json
        json = {
          name: name,
          duration: {
            value: duration,
          },
          source: source
        }

        unless @submetrics.empty?
          json[:metrics] = @submetrics.map(&:as_json)
        end

        json
      end

      def render_json
        {metrics: [as_json]}
      end

      def save
        conn = Faraday.new(:url => hypersonic_url)
        conn.post do |req|
          req.url '/api/v1/metrics'
          req.headers['Content-Type'] = 'application/json'
          req.body = render_json.to_json
        end
      end

      def hypersonic_url
        "http://hypersonic.dev"
      end
    end
  end
end
