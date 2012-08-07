require 'check_functional_test/helper'

module CheckFunctionalTest
  class Repire
    include Helper

    def initialize(check)
      generate_missing_test_files(check)
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
      action_template = ""
      action_list.each do |action|
        action_template += <<-ACTION
        test "#{action}" do
          assert true
        end

        ACTION
      end
      class_template = <<-CLS
      require 'test_helper'

      class #{controller_filename.camelize}Test < ActionController::TestCase

        setup do
        end

        #{action_template}
      end
      CLS
      class_template
    end

  end
end