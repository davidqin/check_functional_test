require 'check_functional_test/output_helper'

module CheckFunctionalTest
  module Report
    include OutputHelper
    
    def report_result
      missing_test_files.each do |test_file, actions|
        report_puts "Can not find the test file: -> test/functional/#{test_file}_test.rb"
      end

      missing_test_action.each do |controller_filename, expected_tests|
        report_print "#{controller_filename}".camelize, :bold
        puts  "  in test/functional/#{controller_filename}_test.rb."
        expected_tests.each do |expected_test|
          report_print "    Missing: ", :red
          report_puts "#{expected_test} action test!"
        end
      end

      report_puts_separator
      report_puts "Controller: #{controllers_count}   Action: #{self.actions_count}   Expected test: #{self.expected_tests_count}"
      report_puts "Missing test file: #{self.missing_test_files.count}   Missing action test: #{self.missing_action_tests_count}    In %0.9f seconds" % [Time.now - self.strat_chekc_time]
      report_puts_separator

      if self.missing_test_files.count != 0
        report_puts "You can execute \"rake func:test:repair\" to generate missing test files!", :green
      end
    end

    def test_missing?
      self.missing_test_files.count != 0 || self.missing_action_tests_count != 0
    end

    def report_puts_separator
      color = :green
      color = :red if test_missing?
      separator = "=" * 78
      report_puts separator, color
    end
  end
end