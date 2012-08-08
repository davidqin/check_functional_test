require 'optparse'

module CheckFunctionalTest
  class Command

    def self.main(*argv)
      new.main(*argv)
    end

    def option_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: check_functional_test [options] path"

        opts.on("-r", "--repair", "Generate missing Tests Files!") do
          @repire = true
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
    end

    # Run command.
    def main(*argv)
      option_parser.parse!(argv)
      if @repire
        CheckFunctionalTest::Repair.new(CheckFunctionalTest::Check.new.check)
      else
        CheckFunctionalTest::Check.new.check_and_report
      end
    end

  end
end