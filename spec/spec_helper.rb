require 'bundler/setup'
Bundler.setup

require 'byebug'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.color = true
  config.mock_with :rspec do |r|
    r.syntax = [:expect, :should]
  end
end

def read_fixture(path)
  open("#{File.dirname(__FILE__)}/fixtures/#{path}").read
end

def parsed_fixture(fixture_path)
  analysis_output = read_fixture(fixture_path)
  parser.new(analysis_output).parse
end

require 'uci'
