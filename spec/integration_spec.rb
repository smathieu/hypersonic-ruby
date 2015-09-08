require 'spec_helper'

module Hypersonic
  module Ruby
    describe "Integration" do
      let(:api_controller_submetric) do
        [
          {
            name: "get :index",
            duration: { value: 1000 },
            source: 'rspec',
          },

          {
            name: "post :create",
            duration: { value: 1000 },
            source: 'rspec',
          },
        ]
      end

      let(:api_controller_metric) do
        [
          {
            name: "ApiController",
            duration: { value: 2000 },
            source: 'rspec',
            metrics: api_controller_submetric,
          }
        ]
      end

      let(:expected_body) do
        {
          metrics: [
            {
              name: "RSpec Run Time",
              duration: { value: 2000 },
              source: 'rspec',
              metrics: api_controller_metric,
            }
          ]
        }
      end

      it "can post metrics to the Hypersonic backend" do
        url = "http://hypersonic.dev/api/v1/metrics"
        stub_request(:post, url)

        metric = Metric.new("RSpec Run Time") do |m|
          m.metric("ApiController") do |m|
            m.metric("get :index") do |m|
              m.duration 1000
              m.source 'rspec'
            end

            m.metric("post :create") do |m|
              m.duration 1000
              m.source 'rspec'
            end

            m.duration 2000
            m.source 'rspec'
          end

          m.duration 2000
          m.source 'rspec'
        end

        metric.save

        assert_requested(:post, url,
          body: expected_body.to_json)
      end
    end
  end
end
