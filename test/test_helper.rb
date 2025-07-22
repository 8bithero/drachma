require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch

  SimpleCov.command_name "test:#{Process.pid}"

  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/lib/tasks/"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors) unless ENV["COVERAGE"]

    fixtures :all
  end
end
