require 'spec_helper'

module Hypersonic
  describe Ruby do
    describe ".config" do
      subject(:config) { described_class.config }

      it "loads the yaml file" do
        expect(config.project_secret).to eq('s3cr3t')
      end
    end
  end
end

