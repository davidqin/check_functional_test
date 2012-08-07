require "rails"
require 'check_functional_test/helper'
require 'test/unit'

IGNORE_ACTIONS = []

class Array
  def include_expected_test?(expected_test)
    prefix = expected_test

    self.each do |item|
      if item.match(prefix)
        return true
      end
    end

    return false
  end
end

module CheckFunctionalTest
  class Check
    include Helper

    attr_reader   :rails_path
    attr_accessor :controllers_count
    attr_accessor :actions_count
    attr_accessor :expected_tests_count
    attr_accessor :missing_test_files
    attr_accessor :missing_test_action
    attr_accessor :missing_action_tests_count
    attr_accessor :strat_chekc_time

    def initialize
      @rails_path = "#{Rails.root.to_path}"
      $LOAD_PATH << "#{rails_path}/test"

      self.controllers_count          = 0
      self.actions_count              = 0
      self.expected_tests_count       = 0
      self.missing_action_tests_count = 0
      self.missing_test_files         = {}
      self.missing_test_action        = {}
      self.strat_chekc_time           = Time.now

      Test::Unit::Runner.class_variable_set "@@stop_auto_run", true
    end

    def check_and_report
      check
      report_result
    end

    def check
      filenames = get_controller_filenames
      filenames.each do |controller_filename|
        check_controller(controller_filename)
      end
      self.controllers_count = filenames.size
      self
    end

    private

    def get_controller_filenames
      contorller_root_folder      = "#{rails_path}/app/controllers"
      ignore_controller_filenames = ['application_controller']
      absolute_filenames          = Dir["#{contorller_root_folder}/**/*.rb"]

      relative_filenames = []
      absolute_filenames.each do |file|
        relative_filenames << file.sub("#{contorller_root_folder}/", '').sub(".rb", '')
      end

      filenames = relative_filenames - ignore_controller_filenames
      return filenames
    end

    def check_controller(controller_filename)
      return unless check_functional_test_file(controller_filename)

      controller_class = get_controller_class(controller_filename)
      test_class       = get_functional_test_class(controller_filename)
      action_list      = get_class_actions(controller_class)
      action_test_list = get_class_actions(test_class)

      self.actions_count += action_list.size
      check_controller_actions(action_list, action_test_list, controller_filename)
    end

    def check_functional_test_file(controller_filename)
      test_file = "#{rails_path}/test/functional/#{controller_filename}_test.rb"
      begin
        require test_file
      rescue LoadError
        record_missing_test_files(controller_filename, test_file)
        return false
      end
      return true
    end

    def record_missing_test_files(controller_filename, test_file)
      controller_class = get_controller_class(controller_filename)
      action_list      = get_class_actions(controller_class)
      self.missing_test_files[controller_filename] = []
      action_list.each do |action_name|
        self.missing_test_files[controller_filename] << action_name
      end
    end

    def get_controller_class(controller_filename)
      controller_filename.camelize.constantize
    end

    def get_functional_test_class(controller_filename)
      test_file_name = controller_filename + "_test"
      test_file_name.camelize.constantize
    end

    def get_class_actions(a_class)
      all_public_actions = a_class.public_instance_methods(false)
      actions = remove_ignore_actions(all_public_actions, a_class)
      actions.map! {|action| action.to_s}
    end

    def remove_ignore_actions(actions, a_class)
      actions.delete_if do |action_name|
        condition_one   = action_name.to_s.match(/_one_time/)
        condition_two   = action_name.to_s.match(/_callback_before_/)
        condition_three = IGNORE_ACTIONS.include?([a_class.name.underscore, action_name.to_s])
        condition_one || condition_two || condition_three
      end
    end

    def check_controller_actions(action_list, test_list, controller_filename)
      action_list.each do |action|
        check_controller_action_test(action, test_list, controller_filename)
        self.expected_tests_count += 1
      end
    end

    def check_controller_action_test(expected_test, actual_test_list, controller_filename)
      return if actual_test_list.include_expected_test?(expected_test)
      self.missing_test_action[controller_filename] ||= []
      self.missing_test_action[controller_filename] << expected_test
      self.missing_action_tests_count += 1
    end

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