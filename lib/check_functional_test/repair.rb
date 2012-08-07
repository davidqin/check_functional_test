require 'check_functional_test/output_helper'

module CheckFunctionalTest
  class Repair
    include OutputHelper

    attr_reader :need_failed_case

    def initialize(check)
      generate_missing_test_files(check)
      @need_failed_case = check.need_failed_case
    end

    def generate_missing_test_files(check)
      path = "#{check.rails_path}/test"

      check.missing_test_files.each do |controller_filename, action_list|
        test_file_name = "#{path}/functional/#{controller_filename}_test.rb"
        FileUtils.mkdir_p test_file_name.split(/\//)[0..-2].join("/")
        File.open(test_file_name, "w") { |f| f.write(functional_test_file_template(controller_filename,action_list))}
        report_print "Generate file: ", :green
        puts test_file_name
      end

      nil
    end

    def functional_test_file_template(controller_filename, action_list)
      actions_template = ""
      action_list.each do |action|
        actions_template += one_action_tempalte(action)
      end
      
      class_template = <<-CLS
require 'test_helper'

class #{controller_filename.camelize}Test < ActionController::TestCase

  setup do
  end
#{actions_template}
end
CLS
      class_template
    end

  def one_action_tempalte(action_name)
<<-ACTION

  test "#{action_name}" do
    assert true
  end
ACTION
  end

  end
end