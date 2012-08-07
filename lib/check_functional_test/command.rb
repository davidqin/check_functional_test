require 'optparse'
require 'pry'

module CheckFunctionalTest

  class Command

    def self.main(*argv)
      new.main(*argv)
    end

    def initialize
    end

    def option_parser
      OptionParser.new do |opts|

        opts.banner = "Turn - Pretty Unit Test Runner for Ruby"

        opts.separator " "
        opts.separator "SYNOPSIS"
        opts.separator "  turn [OPTIONS] [RUN MODE] [OUTPUT MODE] [TEST GLOBS ...]"

        opts.separator " "
        opts.separator "GENERAL OPTIONS"

        opts.on('-I', '--loadpath=PATHS', "add paths to $LOAD_PATH") do |path|
          @loadpath.concat(path.split(':'))
        end

        opts.on('-r', '--require=LIBS', "require libraries") do |lib|
          @requires.concat(lib.split(':'))
        end

        opts.on('-n', '--name=PATTERN', "only run tests that match PATTERN") do |pattern|
          if pattern =~ /\/(.*)\//
            @pattern = Regexp.new($1)
          else
            @pattern = Regexp.new(pattern, Regexp::IGNORECASE)
          end
        end

        opts.on('-c', '--case=PATTERN', "only run test cases that match PATTERN") do |pattern|
          if pattern =~ /\/(.*)\//
            @matchcase = Regexp.new($1)
          else
            @matchcase = Regexp.new(pattern, Regexp::IGNORECASE)
          end
        end

        opts.on('-m', '--mark=SECONDS', "Mark test if it exceeds runtime threshold.") do |int|
          @mark = int.to_i
        end

        opts.on('-b', '--backtrace', '--trace INT', "Limit the number of lines of backtrace.") do |int|
          @trace = int
        end

        opts.on('--natural', "Show natualized test names.") do |bool|
          @natural = bool
        end

        opts.on('-v', '--verbose', "Show extra information.") do |bool|
          @verbose = bool
        end

        opts.on('--[no-]ansi', "Force use of ANSI codes on or off.") do |bool|
          @ansi = bool
        end

        # Turn does not support Test::Unit 2.0+
        #opts.on('-u', '--testunit', "Force use of TestUnit framework") do
        #  @framework = :testunit
        #end

        opts.on('--log', "log results to a file") do #|path|
          @log = true # TODO: support path/file
        end

        opts.on('--live', "do not use local load path") do
          @live = true
        end

        opts.separator " "
        opts.separator "RUN MODES"

        opts.on('--normal', "run all tests in a single process [default]") do
          @runmode = nil
        end

        opts.on('--solo', "run each test in a separate process") do
          @runmode = :solo
        end

        opts.on('--cross', "run each pair of test files in a separate process") do
          @runmode = :cross
        end

        #opts.on('--load', "") do
        #end

        opts.separator " "
        opts.separator "OUTPUT MODES"

        opts.on('--outline', '-O', "turn's original case/test outline mode [default]") do
          @outmode = :outline
        end

        opts.on('--progress', '-P', "indicates progress with progress bar") do
          @outmode = :progress
        end

        opts.on('--dotted', '-D', "test-unit's traditonal dot-progress mode") do
          @outmode = :dotted
        end

        opts.on('--pretty', '-R', '-T', "new pretty output mode") do
          @outmode = :pretty
        end

        opts.on('--cue', '-C', "cue for action on each failure/error") do
          @outmode = :cue
        end

        opts.on('--marshal', '-M', "dump output as YAML (normal run mode only)") do
          @runmode = :marshal
          @outmode = :marshal
        end

        opts.separator " "
        opts.separator "COMMAND OPTIONS"

        opts.on('--debug', "turn debug mode on") do
          $DEBUG   = true
        end

        opts.on('--warn', "turn warnings on") do
          $VERBOSE = true
        end

        opts.on_tail('--version', "display version") do
          puts VERSION
          exit
        end

        opts.on_tail('-h', '--help', "display this help information") do
          puts opts
          exit
        end
      end
    end

    # Run command.
    def main(*argv)
      binding.pry
      CheckFunctionalTest::Check.new.check
    end

  end

end