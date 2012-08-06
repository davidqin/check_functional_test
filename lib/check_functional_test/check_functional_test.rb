# rails runner script/check_functional_test.rb

require "ansi/code"

$LOAD_PATH << File.expand_path('../../test', __FILE__)

IGNORE_ACTIONS =  []

class String
  def have?(content)
    length = self.scan(content).length
    if length == 0
      return false
    else
      return true
    end
  end
end

class Array
  def include_expected_test?(expected_test)
    prefix = expected_test

    self.each do |item|
      if item.have?(prefix)
        return true
      end
    end

    return false
  end
end

module CheckFunctionalTest
  class CheckFunctionalTest
    attr_accessor :actions_count
    attr_accessor :expected_tests_count
    attr_accessor :missing_test_files_count
    attr_accessor :missing_action_tests_count
    attr_accessor :strat_chekc_time

    def initialize
      self.actions_count              = 0
      self.expected_tests_count       = 0
      self.missing_test_files_count   = 0
      self.missing_action_tests_count = 0
      self.strat_chekc_time           = Time.now
    end

    def check
      filenames = get_controller_filenames
      filenames.each do |controller_filename|
        check_controller(controller_filename)
      end

      report_result filenames.size
    end

    private

    def get_controller_filenames
      contorller_root_folder      = 'app/controllers'
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
      test_file = "functional/#{controller_filename}_test.rb"
      begin
        require test_file
      rescue LoadError
        report_puts "Can not find the test file: -> #{test_file}"
        self.missing_test_files_count += 1
        return false
      end
      return true
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
        condition_one   = action_name.to_s.have?(/_one_time/)
        condition_two   = action_name.to_s.have?(/_callback_before_/)
        condition_three = IGNORE_ACTIONS.include?([a_class.name.underscore, action_name.to_s])
        condition_one || condition_two || condition_three
      end
    end

    def check_controller_actions(action_list, test_list, controller_filename)
      action_list.each do |action|
        if action_need_test_failed_case(action)
          check_controller_action_test("#{action}_failed", test_list, controller_filename)
          self.expected_tests_count += 1
        end

        check_controller_action_test(action, test_list, controller_filename)
        self.expected_tests_count += 1
      end
    end

    def action_need_test_failed_case(controller_action)
      prefixs = %w(create update)
      prefixs.each do |prefix|
        if controller_action.have?(prefix)
          return true
        end
      end
      return false
    end

    def check_controller_action_test(expected_test, actual_test_list, controller_filename)
      return if actual_test_list.include_expected_test?(expected_test)

      report_puts "#{controller_filename}".camelize, :bold
      report_print "    Missing: ", :red
      report_puts "#{expected_test} test in test/functional/#{controller_filename}_test.rb."
      self.missing_action_tests_count += 1
    end

    def report_result(controllers_count)
      report_puts_separator
      report_puts "Controller: #{controllers_count}   Action: #{self.actions_count}   Expected test: #{self.expected_tests_count}"
      report_puts "Missing test file: #{self.missing_test_files_count}   Missing action test: #{self.missing_action_tests_count}    In %0.9f seconds" % [Time.now - self.strat_chekc_time]
      report_puts_separator
    end

    def report_print(string, effect = nil)
      if effect
        print ANSI.send(effect,string)
      else
        print string
      end
    end

    def report_puts(string, effect = nil)
      if effect
        puts ANSI.send(effect,string)
      else
        puts string
      end
    end

    def report_puts_separator
      color = :green
      color = :red if self.missing_test_files_count != 0 || self.missing_action_tests_count != 0
      separator = "=" * 78
      report_puts separator, color
    end

  end
end

module Test
  module Unit
    class Runner
      @@stop_auto_run = true
    end
  end
end

