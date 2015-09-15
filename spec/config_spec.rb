require 'spec_helper'

module Hypersonic
  module Ruby
    describe Config do
      def with_env(key, value)
        old = ENV[key]
        ENV[key] = value
        yield
      ensure
        ENV[key] = old
      end

      it "gets the project secret from the environment" do
        with_env('HYPERSONIC_PROJECT_SECRET', 'abc') do
          expect(subject.project_secret).to eq('abc')
        end
      end

      it "gets the base url from the environment" do
        with_env('HYPERSONIC_BASE_URL', 'http://www.example.com') do
          expect(subject.base_url).to eq('http://www.example.com')
        end
      end

      it "has a default value for the base_url" do
        expect(subject.base_url).to eq('http://hypersonic.dev')
      end

      describe ".load_from_file" do
        let(:file) { File.join(__dir__, 'fixtures/sample_config.yml') }
        subject { described_class.load_from_file(file) }

        it "loads the project secret" do
          expect(subject.project_secret).to eq('file_abc')
        end

        context "a file that does not exist" do
          let(:file) { "does_not_exist" }

          it "raises an error" do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context "a file that is malformed" do
          let(:file) { File.join(__dir__, 'fixtures/sample_config_invalid.yml') }

          it "raises a config error" do
            expect { subject }.to raise_error(Config::Error)
          end

          context "empty file" do
            let(:file) { File.join(__dir__, 'fixtures/sample_config_invalid_2.yml') }

            it "raises a config error" do
              expect { subject }.to raise_error(Config::Error)
            end
          end

          context "empty file" do
            let(:file) { File.join(__dir__, 'fixtures/sample_config_invalid_3.yml') }

            it "raises a config error" do
              expect { subject }.to raise_error(Config::Error)
            end
          end
        end
      end
    end
  end
end
