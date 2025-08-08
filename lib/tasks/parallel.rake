# typed: false
# frozen_string_literal: true

namespace :parallel do
  desc 'Setup test databases for parallel tests'
  task setup: :environment do
    require 'parallel_tests'

    # Create test databases for parallel tests
    ParallelTests::Tasks.run_in_parallel(['rake', 'db:create', 'db:schema:load'])
  end
end
