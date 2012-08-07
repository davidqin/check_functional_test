require "ansi/code"

module CheckFunctionalTest
  module Helper
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
  end
end
