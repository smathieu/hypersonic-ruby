module Hypersonic
  module Ruby
    class Metric
      attr_reader :name

      def initialize(name, source: nil, duration: nil, &block)
        @name = name
        @duration = duration
        @source = source
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
        config = Hypersonic::Ruby.config
        conn = Faraday.new(:url => config.base_url)
        res = conn.post do |req|
          req.url '/api/v1/metrics'
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-Hypersonic-Project-Key'] = config.project_secret
          req.body = JSON.dump(render_json)
        end

        if res.status != 201
          puts "Failed Request"
          puts res.body
        end
        # TODO handle incorrect error code
      end
    end
  end
end
